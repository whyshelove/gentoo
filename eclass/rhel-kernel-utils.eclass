# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel-kernel-utils.eclass
# @MAINTAINER:
# Distribution Kernel Project <dist-kernel@gentoo.org>
# @AUTHOR:
# Michał Górny <mgorny@gentoo.org>
# @SUPPORTED_EAPIS: 7 8
# @BLURB: Utility functions related to Distribution Kernels
# @DESCRIPTION:
# This eclass provides various utility functions related to Distribution
# Kernels.

# @ECLASS_VARIABLE: KERNEL_IUSE_SECUREBOOT
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# If set to a non-null value, inherits secureboot.eclass
# and allows signing of generated kernel images.

if [[ ! ${_RHEL_KERNEL_UTILS} ]]; then

case ${EAPI} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ ${KERNEL_IUSE_SECUREBOOT} ]]; then
	inherit secureboot
fi

# @FUNCTION: dist-kernel_build_initramfs
# @USAGE: <output> <version>
# @DESCRIPTION:
# Build an initramfs for the kernel.  <output> specifies the absolute
# path where initramfs will be created, while <version> specifies
# the kernel version, used to find modules.
#
# Note: while this function uses dracut at the moment, other initramfs
# variants may be supported in the future.
dist-kernel_build_initramfs() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 2 ]] || die "${FUNCNAME}: invalid arguments"
	local output=${1}
	local version=${2}

	local rel_image_path=$(dist-kernel_get_image_path)
	local image=${output%/*}/${rel_image_path##*/}

	local args=(
		--force
		# if uefi=yes is used, dracut needs to locate the kernel image
		--kernel-image "${image}"

		# positional arguments
		"${output}" "${version}"
	)

	ebegin "Building initramfs via dracut"
	dracut "${args[@]}"
	eend ${?} || die -n "Building initramfs failed"
}

# @FUNCTION: rhel-kernel_get_image_path
# @DESCRIPTION:
# Get relative kernel image path specific to the current ${ARCH}.
rhel-kernel_get_image_path() {
	case ${ARCH} in
		amd64|x86)
			echo arch/x86/boot/bzImage
			;;
		arm64)
			echo arch/arm64/boot/Image.gz
			;;
		arm)
			echo arch/arm/boot/zImage
			;;
		hppa|ppc|ppc64|sparc)
			# https://www.kernel.org/doc/html/latest/powerpc/bootwrapper.html
			# ./ is required because of ${image_path%/*}
			# substitutions in the code
			echo ./vmlinux
			;;
		riscv)
			echo arch/riscv/boot/Image.gz
			;;
		*)
			die "${FUNCNAME}: unsupported ARCH=${ARCH}"
			;;
	esac
}

cp_vmlinux()
{
  eu-strip --remove-comment -o "$2" "$1"
}

InitBuildVars() {
    # Initialize the kernel .config file and create some variables that are
    # needed for the actual build process.

    Flavour=$1

    # Pick the right kernel config file
    Config=${MY_P}-${_target_cpu}${Variant:+-${Variant}}.config
    DevelDir=/usr/src/kernels/${KVERREL}${Variant:++${Variant}}

    KernelVer=${KVERREL}${Variant:++${Variant}}

    # make sure EXTRAVERSION says what we want it to say
    pkgrelease=${K_PRD}${DSUFFIX}
    perl -p -i -e "s/^EXTRAVERSION.*/EXTRAVERSION = -${pkgrelease}.${_target_cpu}${Variant:++${Variant}}/" Makefile

    # if pre-rc1 devel kernel, must fix up PATCHLEVEL for our versioning scheme
    # if we are post rc1 this should match anyway so this won't matter
    #patchlevel=$(ver_cut 2)
    #perl -p -i -e "s/^PATCHLEVEL.*/PATCHLEVEL = ${patchlevel}/" Makefile

    tools_make mrproper

    use savedconfig || cp configs/$Config .config

	restore_config .config
	[[ -f .config ]] || die "Ebuild error: please copy default config into .config"

    if use signkernel || use signmodules; then
	cp configs/x509.genkey certs/.
    fi

    Arch=`head -1 "configs/${MY_P}-${_target_cpu}.config" | cut -b 3-`
    echo USING ARCH=$Arch

    KCFLAGS="${kcflags}"

    # add kpatch flags for base kernel
    if [ "$Variant" == "" ]; then
        KCFLAGS="$KCFLAGS ${kpatch_kcflags}"
    fi
}

tools_make() {
	emake -s "${MAKEARGS[@]}" "${@}"
}

BuildKernel() {
    MakeTarget=$1
    KernelImage=$2
    DoVDSO=$3
    Variant=$4
    InstallName=${5:-vmlinuz}

    # When the bootable image is just the ELF kernel, strip it.
    # We already copy the unstripped file into the debuginfo package.
    if [ "$KernelImage" = vmlinux ]; then
        CopyKernel=cp_vmlinux
    else
        CopyKernel=cp
    fi

    InitBuildVars $Variant

    echo BUILDING A KERNEL FOR ${Variant} ${_target_cpu}...

    tools_make olddefconfig >/dev/null

   # This ensures build-ids are unique to allow parallel debuginfo
    perl -p -i -e "s/^CONFIG_BUILD_SALT.*/CONFIG_BUILD_SALT=\"${KVERREL}\"/" .config
    tools_make KCFLAGS="$KCFLAGS" WITH_GCOV="${with_gcov:-0}" $MakeTarget $sparse_mflags

    if use modules; then
	tools_make KCFLAGS="$KCFLAGS" WITH_GCOV="${with_gcov:-0}" modules $sparse_mflags || die
    fi

    if use arm64; then
        tools_make dtbs INSTALL_DTBS_PATH=${ED}/${image_install_path}/dtb-$KernelVer
        tools_make dtbs_install INSTALL_DTBS_PATH=${ED}/${image_install_path}/dtb-$KernelVer
        cp -r ${ED}/${image_install_path}/dtb-$KernelVer ${ED}/lib/modules/$KernelVer/dtb
    	find arch/$Arch/boot/dts -name '*.dtb' -type f -delete
    fi
}

perf_make=(
    emake EXTRA_CFLAGS="${OPT_FLAGS}" LDFLAGS="${LDFLAGS} -Wl,-E" -C tools/perf V=1 NO_PERF_READ_VDSO32=1 WERROR=0 NO_LIBUNWIND=1 HAVE_CPLUS_DEMANGLE=1 NO_GTK2=1 NO_STRLCPY=1 NO_BIONIC=1 LIBBPF_DYNAMIC=1 LIBTRACEEVENT_DYNAMIC=1 ${perf_build_extra_opts} prefix="${EPREFIX}/usr" PYTHON=${EPYTHON}
)

InstallKernel(){
    # Start installing the results
    dodir /${debuginfodir}/${image_install_path} /lib/modules/$KernelVer/{,systemtap}
    insinto /boot
    newins .config config-$KernelVer
    newins System.map System.map-$KernelVer

    insinto /lib/modules/$KernelVer
    newins .config config
    doins System.map

    if [ -f arch/$Arch/boot/zImage.stub ]; then
        cp arch/$Arch/boot/zImage.stub ${ED}/${image_install_path}/zImage.stub-$KernelVer || :
        cp arch/$Arch/boot/zImage.stub ${ED}/lib/modules/$KernelVer/zImage.stub-$KernelVer || :
    fi

    if use signkernel; then
        if [ "$KernelImage" = vmlinux ]; then
            # We can't strip and sign $KernelImage in place, because
            # we need to preserve original vmlinux for debuginfo.
            # Use a copy for signing.
            $CopyKernel $KernelImage $KernelImage.tosign
            KernelImage=$KernelImage.tosign
            CopyKernel=cp
        fi

        # Sign the image if we're using EFI
        # aarch64 kernels are gziped EFI images
        KernelExtension=${KernelImage##*.}
        if [ "$KernelExtension" == "gz" ]; then
            SignImage=${KernelImage%.*}
        else
            SignImage=$KernelImage
        fi

        case ${ARCH} in
            amd64|arm64)
                    _pesign $SignImage vmlinuz.signed ${secureboot_ca_0} ${secureboot_key_0} ${pesign_name_0}
                    ;;
            s390|ppc64)
                    if [ -x /usr/bin/rpm-sign ]; then
                        rpmsign --key "${pesign_name_0}" --lkmsign $SignImage --output vmlinuz.signed
                    elif use modules && use signmodules; then
                        chmod +x scripts/sign-file
                        ./scripts/sign-file -p sha256 certs/signing_key.pem certs/signing_key.x509 $SignImage vmlinuz.signed
                    else
                        mv $SignImage vmlinuz.signed
                    fi
                    ;;
            *)
                die "Unsupported arch ${ARCH}"
            ;;
        esac

        if [ ! -s vmlinuz.signed ]; then
            die "pesigning failed"
        fi

        mv vmlinuz.signed $SignImage
        if [ "$KernelExtension" == "gz" ]; then
            gzip -f9 $SignImage
        fi
    fi

    $CopyKernel $KernelImage "${ED}"/${image_install_path}/$InstallName-$KernelVer

    fperms 0755 /${image_install_path}/$InstallName-$KernelVer
    cp ${ED}/${image_install_path}/$InstallName-$KernelVer ${ED}/lib/modules/$KernelVer/$InstallName

   # hmac sign the kernel for FIPS
   # echo "Creating hmac file: "${ED}"/%{image_install_path}/.vmlinuz-$KernelVer.hmac"
   # ls -l "${ED}"/${image_install_path}/$InstallName-$KernelVer
   # (cd "${ED}"/${image_install_path} && sha512hmac $InstallName-$KernelVer) > "${ED}"/${image_install_path}/.vmlinuz-$KernelVer.hmac;
   # cp "${ED}"/${image_install_path}/.vmlinuz-$KernelVer.hmac "${ED}"/lib/modules/$KernelVer/.vmlinuz.hmac

    if use modules; then
        # Override $(mod-fw) because we don't want it to install any firmware
        # we'll get it from the linux-firmware package and we don't want conflicts
        tools_make INSTALL_MOD_PATH=${ED} modules_install KERNELRELEASE=$KernelVer mod-fw=
    fi


    # install gcov-needed files to $BUILDROOT/$BUILD/...:
    #   gcov_info->filename is absolute path
    #   gcno references to sources can use absolute paths (e.g. in out-of-tree builds)
    #   sysfs symlink targets (set up at compile time) use absolute paths to BUILD dir
    use gcov && find . \( -name '*.gcno' -o -name '*.[chS]' \) -exec install -D '{}' "${ED}/$(pwd)/{}" \;

    # add an a noop %%defattr statement 'cause rpm doesn't like empty file list files
    echo '%%defattr(-,-,-)' > ../kernel${Variant:+-${Variant}}-ldsoconf.list
    if [ $DoVDSO -ne 0 ]; then
        tools_make INSTALL_MOD_PATH=${ED} vdso_install KERNELRELEASE=$KernelVer
        if [ -s ldconfig-kernel.conf ]; then
	     insopts -m0444
	     insinto /etc/ld.so.conf.d
	     newins ldconfig-kernel.conf ${MY_PN}-$KernelVer.conf
	     echo /etc/ld.so.conf.d/kernel-$KernelVer.conf >> ../kernel${Variant:+-${Variant}}-ldsoconf.list
        fi

        rm -rf ${ED}/lib/modules/$KernelVer/vdso/.build-id
    fi

    # And save the headers/makefiles etc for building modules against
    #
    # This all looks scary, but the end result is supposed to be:
    # * all arch relevant include/ files
    # * all Makefile/Kconfig files
    # * all script/ files

    rm -f ${ED}/lib/modules/$KernelVer/{build,source}
    # dirs for additional modules per module-init-tools, kbuild/modules.txt
    dodir /lib/modules/$KernelVer/{build,updates,weak-updates}
    dosym build /lib/modules/$KernelVer/source

    # CONFIG_KERNEL_HEADER_TEST generates some extra files in the process of
    # testing so just delete
    find . -name *.h.s -delete

    # first copy everything
    cp --parents `find  -type f -name "Makefile*" -o -name "Kconfig*"` ${ED}/lib/modules/$KernelVer/build

    if [ ! -e Module.symvers ]; then
        touch Module.symvers
    fi

    insinto /lib/modules/$KernelVer/build
    doins -r Module.symvers System.map .config

    if [ -s Module.markers ]; then
      doins Module.markers 
    fi

    # create the kABI metadata for use in packaging
    # NOTENOTE: the name symvers is used by the rpm backend
    # NOTENOTE: to discover and run the /usr/lib/rpm/fileattrs/kabi.attr
    # NOTENOTE: script which dynamically adds exported kernel symbol
    # NOTENOTE: checksums to the rpm metadata provides list.
    # NOTENOTE: if you change the symvers name, update the backend too
    echo "**** GENERATING kernel ABI metadata ****"
    gzip -c9 < Module.symvers > ${ED}/boot/symvers-$KernelVer.gz
    cp ${ED}/boot/symvers-$KernelVer.gz ${ED}/lib/modules/$KernelVer/symvers.gz

    # then drop all but the needed Makefiles/Kconfig files
    rm -rf ${ED}/lib/modules/$KernelVer/build/{Documentation,scripts,include}
 
    cp -a scripts ${ED}/lib/modules/$KernelVer/build
    rm -rf ${ED}/lib/modules/$KernelVer/build/scripts/{tracing,"spdxcheck.py"}

    # Files for 'make scripts' to succeed with kernel-devel.
    dodir lib/modules/$KernelVer/build/{"security/selinux/include","tools/include/tools"}
    cp -a --parents security/selinux/include/classmap.h ${ED}/lib/modules/$KernelVer/build
    cp -a --parents security/selinux/include/initial_sid_to_string.h ${ED}/lib/modules/$KernelVer/build

    cp -a --parents tools/include/tools/be_byteshift.h ${ED}/lib/modules/$KernelVer/build
    cp -a --parents tools/include/tools/le_byteshift.h ${ED}/lib/modules/$KernelVer/build

    # Files for 'make prepare' to succeed with kernel-devel.
    cp -a --parents tools/include/linux/compiler* "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/include/linux/types.h "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/build/Build.include "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/build/Build "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/build/fixdep.c "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/objtool/sync-check.sh "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/bpf/resolve_btfids/main.c "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/bpf/resolve_btfids/Build "${ED}"/lib/modules/$KernelVer/build

    cp --parents security/selinux/include/policycap_names.h "${ED}"/lib/modules/$KernelVer/build
    cp --parents security/selinux/include/policycap.h "${ED}"/lib/modules/$KernelVer/build

    cp -a --parents tools/include/asm-generic "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/include/linux "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/include/uapi/asm "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/include/uapi/asm-generic "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/include/uapi/linux "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/include/vdso "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/scripts/utilities.mak "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/lib/subcmd "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/lib/*.c "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/objtool/*.[ch] "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/objtool/Build "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/objtool/include/objtool/*.h "${ED}"/lib/modules/$KernelVer/build
    cp -a --parents tools/lib/bpf "${ED}"/lib/modules/$KernelVer/build
    cp --parents tools/lib/bpf/Build "${ED}"/lib/modules/$KernelVer/build

    if [ -f tools/objtool/objtool ]; then
      cp -a tools/objtool/objtool ${ED}/lib/modules/$KernelVer/build/tools/objtool/ || :
    fi
    if [ -f tools/objtool/fixdep ]; then
      cp -a tools/objtool/fixdep "${ED}"/lib/modules/$KernelVer/build/tools/objtool/ || :
    fi
    if [ -d arch/$Arch/scripts ]; then
      cp -a arch/$Arch/scripts ${ED}/lib/modules/$KernelVer/build/arch/$Arch || :
    fi
    if [ -f arch/$Arch/*lds ]; then
      cp -a arch/$Arch/*lds ${ED}/lib/modules/$KernelVer/build/arch/$Arch/ || :
    fi
    if [ -f arch/${asmarch}/kernel/module.lds ]; then
      cp -a --parents arch/${asmarch}/kernel/module.lds ${ED}/lib/modules/$KernelVer/build/
    fi
    find ${ED}/lib/modules/$KernelVer/build/scripts \( -iname "*.o" -o -iname "*.cmd" \) -exec rm -f {} +

   if use ppc64; then
        cp -a --parents arch/powerpc/lib/crtsavres.[So] ${ED}/lib/modules/$KernelVer/build/
    fi
    if [ -d arch/${asmarch}/include ]; then
      cp -a --parents arch/${asmarch}/include ${ED}/lib/modules/$KernelVer/build/
    fi
   if use arm64; then
        # arch/arm64/include/asm/xen references arch/arm
        cp -a --parents arch/arm/include/asm/xen ${ED}/lib/modules/$KernelVer/build/
        # arch/arm64/include/asm/opcodes.h references arch/arm
        cp -a --parents arch/arm/include/asm/opcodes.h ${ED}/lib/modules/$KernelVer/build/
    fi
    cp -a include ${ED}/lib/modules/$KernelVer/build/include
    if use amd64; then
        # files for 'make prepare' to succeed with kernel-devel
        cp -a --parents arch/x86/entry/syscalls/syscall_32.tbl "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/entry/syscalls/syscall_64.tbl "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs_32.c "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs_64.c "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs.c "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs_common.c "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs.h "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/purgatory.c "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/stack.S "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/setup-x86_64.S "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/entry64.S "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/boot/string.h "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/boot/string.c "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/boot/ctype.h "${ED}"/lib/modules/$KernelVer/build/

        cp -a --parents scripts/syscalltbl.sh "${ED}"/lib/modules/$KernelVer/build/
        cp -a --parents scripts/syscallhdr.sh "${ED}"/lib/modules/$KernelVer/build/

        cp -a --parents tools/arch/x86/include/asm "${ED}"/lib/modules/$KernelVer/build
        cp -a --parents tools/arch/x86/include/uapi/asm "${ED}"/lib/modules/$KernelVer/build
        cp -a --parents tools/objtool/arch/x86/lib "${ED}"/lib/modules/$KernelVer/build
        cp -a --parents tools/arch/x86/lib/ "${ED}"/lib/modules/$KernelVer/build
        cp -a --parents tools/arch/x86/tools/gen-insn-attr-x86.awk "${ED}"/lib/modules/$KernelVer/build
        cp -a --parents tools/objtool/arch/x86/ "${ED}"/lib/modules/$KernelVer/build
    fi
    # Clean up intermediate tools files
    find "${ED}"/lib/modules/$KernelVer/build/tools \( -iname "*.o" -o -iname "*.cmd" \) -exec rm -f {} +

    # Make sure the Makefile, version.h, and auto.conf have a matching
    # timestamp so that external modules can be built
    touch -r "${ED}"/lib/modules/$KernelVer/build/Makefile \
        "${ED}"/lib/modules/$KernelVer/build/include/generated/uapi/linux/version.h \
        "${ED}"/lib/modules/$KernelVer/build/include/config/auto.conf

    if use debug; then
	    eu-readelf -n vmlinux | grep "Build ID" | awk '{print $NF}' > vmlinux.id
	    cp vmlinux.id "${ED}"/lib/modules/$KernelVer/build/vmlinux.id

	    #
	    # save the vmlinux file for kernel debugging into the kernel-debuginfo rpm
	    #
	    mkdir -p "${ED}"${debuginfodir}/lib/modules/$KernelVer
	    cp vmlinux "${ED}"${debuginfodir}/lib/modules/$KernelVer
   fi

    find ${ED}/lib/modules/$KernelVer -name "*.ko" -type f >modnames

    # mark modules executable so that strip-to-file can strip them
    xargs --no-run-if-empty chmod u+x < modnames

    # Generate a list of modules for block and networking.

    grep -F /drivers/ modnames | xargs --no-run-if-empty nm -upA |
    sed -n 's,^.*/\([^/]*\.ko\):  *U \(.*\)$,\1 \2,p' > drivers.undef

    collect_modules_list()
    {
      sed -r -n -e "s/^([^ ]+) \\.?($2)\$/\\1/p" drivers.undef |
        LC_ALL=C sort -u > ${ED}/lib/modules/$KernelVer/modules.$1
      if [ ! -z "$3" ]; then
        sed -r -e "/^($3)\$/d" -i ${ED}/lib/modules/$KernelVer/modules.$1
      fi
    }

    collect_modules_list networking \
      'register_netdev|ieee80211_register_hw|usbnet_probe|phy_driver_register|rt(l_|2x00)(pci|usb)_probe|register_netdevice'
    collect_modules_list block \
      'ata_scsi_ioctl|scsi_add_host|scsi_add_host_with_dma|blk_alloc_queue|blk_init_queue|register_mtd_blktrans|scsi_esp_register|scsi_register_device_handler|blk_queue_physical_block_size' 'pktcdvd.ko|dm-mod.ko'
    collect_modules_list drm \
      'drm_open|drm_init'
    collect_modules_list modesetting \
      'drm_crtc_init'

    # detect missing or incorrect license tags
    ( find ${ED}/lib/modules/$KernelVer -name '*.ko' | xargs modinfo -l | \
        grep -E -v 'GPL( v2)?$|Dual BSD/GPL$|Dual MPL/GPL$|GPL and additional rights$' ) && die

    remove_depmod_files()
    {
        # remove files that will be auto generated by depmod at rpm -i time
        pushd "${ED}"/lib/modules/$KernelVer/
            rm -f modules.{alias,alias.bin,builtin.alias.bin,builtin.bin} \
                  modules.{dep,dep.bin,devname,softdep,symbols,symbols.bin}
        popd
    }

    remove_depmod_files

#    if use modules; then
#	mod_blacklist="${WORKDIR}"/mod-blacklist.sh
#	# Identify modules in the kernel-modules-extras package
#	${mod_blacklist} "${ED}" lib/modules/$KernelVer $(realpath configs/mod-extra.list)
#	# Identify modules in the kernel-modules-internal package
#	${mod_blacklist} "${ED}" lib/modules/$KernelVer "${WORKDIR}/mod-internal.list" internal
#	# Identify modules in the kernel-modules-partner package
#	${mod_blacklist}mod-denylist "${ED}" lib/modules/$KernelVer "${WORKDIR}/mod-partner.list" partner

#        # don't include anything going into kernel-modules-extra in the file lists
#        xargs rm -rf < mod-extra.list
#        # don't include anything going int kernel-modules-internal in the file lists
#        xargs rm -rf < mod-internal.list

#        # don't include anything going int kernel-modules-partner in the file lists
#        xargs rm -rf < mod-partner.list
#    fi
#    #
#    # Generate the kernel-core and kernel-modules files lists
#    #

#    # Copy the System.map file for depmod to use, and create a backup of the
#    # full module tree so we can restore it after we're done filtering
#    cp System.map "${ED}"/.
#    cp configs/filter-{modules,${Arch}}.sh "${ED}"/.

#pushd "${ED}"
#    mkdir restore
#    cp -r lib/modules/$KernelVer/* restore/.

#    if use modules; then
#        # Find all the module files and filter them out into the core and
#        # modules lists.  This actually removes anything going into -modules
#        # from the dir.
#        find lib/modules/$KernelVer/kernel -name *.ko | sort -n > modules.list
#        ./filter-modules.sh modules.list ${Arch}
#        rm filter-*.sh

#        # Run depmod on the resulting module tree and make sure it isn't broken
#        depmod -b . -aeF ./System.map $KernelVer &> depmod.out
#        if [ -s depmod.out ]; then
#            cat depmod.out
#            die "Depmod failure"
#        else
#            rm depmod.out
#        fi
#    else
#        # Ensure important files/directories exist to let the packaging succeed
#        echo '%%defattr(-,-,-)' > modules.list
#        echo '%%defattr(-,-,-)' > k-d.list
#        mkdir -p lib/modules/$KernelVer/kernel
#        # Add files usually created by make modules, needed to prevent errors
#        # thrown by depmod during package installation
#        touch lib/modules/$KernelVer/modules.order
#        touch lib/modules/$KernelVer/modules.builtin
#    fi

#    remove_depmod_files

#    # Go back and find all of the various directories in the tree.  We use this
#    # for the dir lists in kernel-core
#    find lib/modules/$KernelVer/kernel -mindepth 1 -type d | sort -n > module-dirs.list

#    # Cleanup
#    rm System.map
#    # Just "cp -r" can be very slow: here, it rewrites _existing files_
#    # with open(O_TRUNC). Many filesystems synchronously wait for metadata
#    # update for such file rewrites (seen in strace as final close syscall
#    # taking a long time). On a rotational disk, cp was observed to take
#    # more than 5 minutes on ext4 and more than 15 minutes (!) on xfs.
#    # With --remove-destination, we avoid this, and copying
#    # (with enough RAM to cache it) takes 5 seconds:
#    cp -r --remove-destination restore/* lib/modules/$KernelVer/.
#    rm -rf restore
#popd

    # Move the devel headers out of the root file system
    dodir /usr/src/kernels
    mv ${ED}/lib/modules/$KernelVer/build ${ED}/$DevelDir

    # This is going to create a broken link during the build, but we don't use
    # it after this point.  We need the link to actually point to something
    # when kernel-devel is installed, and a relative link doesn't work across
    # the F17 UsrMove feature.
    ln -sf $DevelDir ${ED}/lib/modules/$KernelVer/build

    # Generate vmlinux.h and put it to kernel-devel path
    if use bpf; then
       # Build the bootstrap bpftool to generate vmlinux.h
       make -C tools/bpf/bpftool bootstrap
       tools/bpf/bpftool/bootstrap/bpftool btf dump file vmlinux format c > ${ED}/$DevelDir/vmlinux.h
    fi

    # prune junk from kernel-devel
    find ${ED}/usr/src/kernels -name ".*.cmd" -exec rm -f {} \;

    # Red Hat UEFI Secure Boot CA cert, which can be used to authenticate the kernel
    if use arm64 || use amd64; then
        insinto ${_datadir}/doc/kernel-keys/$KernelVer
        newins ${secureboot_ca_0} kernel-signing-ca.cer
   fi

    if use signmodules; then
        # Save the signing keys so we can sign the modules in __modsign_install_post
        cp certs/signing_key.pem certs/signing_key.pem.sign${Variant:++${Variant}}
        cp certs/signing_key.x509 certs/signing_key.x509.sign${Variant:++${Variant}}

	if use s390 || use ppc64; then
		if [ -x /usr/bin/rpm-sign ]; then
		   insinto ${_datadir}/doc/kernel-keys/$KernelVer
		   newins certs/signing_key.x509.sign${Variant:++${Variant}} kernel-signing-ca.cer
		   openssl x509 -in certs/signing_key.pem.sign${Variant:++${Variant}} -outform der -out \
			${ED}${_datadir}/doc/kernel-keys/$KernelVer/${signing_key_filename}
		   fperms 0644 ${_datadir}/doc/kernel-keys/$KernelVer/${signing_key_filename}
		fi
	fi
    fi

    if use ipaclones; then
        #MAXPROCS=$(echo ${MAKEOPTS} | sed -n 's/-j\s*\([0-9]\+\)/\1/p')
        MAXPROCS=$(makeopts_jobs)
        if [ -z "$MAXPROCS" ]; then
            MAXPROCS=1
        fi
        if [ "$Variant" == "" ]; then
            mkdir -p ${ED}/$DevelDir-ipaclones
            find . -name '*.ipa-clones' | xargs -i{} -r -n 1 -P $MAXPROCS install -m 644 -D "{}" "${ED}/$DevelDir-ipaclones/{}"
        fi
    fi
}

# @FUNCTION: dist-kernel_install_kernel
# @USAGE: <version> <image> <system.map>
# @DESCRIPTION:
# Install kernel using installkernel tool.  <version> specifies
# the kernel version, <image> full path to the image, <system.map>
# full path to System.map.
dist-kernel_install_kernel() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 3 ]] || die "${FUNCNAME}: invalid arguments"
	local version=${1}
	local image=${2}
	local map=${3}

	# if dracut is used in uefi=yes mode, initrd will actually
	# be a combined kernel+initramfs UEFI executable.  we can easily
	# recognize it by PE magic (vs cpio for a regular initramfs)
	local initrd=${image%/*}/initrd
	local magic
	[[ -s ${initrd} ]] && read -n 2 magic < "${initrd}"
	if [[ ${magic} == MZ ]]; then
		einfo "Combined UEFI kernel+initramfs executable found"
		# install the combined executable in place of kernel
		image=${initrd%/*}/uki.efi
		mv "${initrd}" "${image}" || die
		# We moved the generated initrd, prevent dracut from running again
		# https://github.com/dracutdevs/dracut/pull/2405
		shopt -s nullglob
		local plugins=()
		for file in "${EROOT}"/etc/kernel/install.d/*.install; do
			plugins+=( "${file}" )
		done
		for file in "${EROOT}"/usr/lib/kernel/install.d/*.install; do
			if ! has "${file##*/}" 50-dracut.install 51-dracut-rescue.install "${plugins[@]##*/}"; then
					plugins+=( "${file}" )
			fi
		done
		shopt -u nullglob
		export KERNEL_INSTALL_PLUGINS="${KERNEL_INSTALL_PLUGINS} ${plugins[@]}"

		if [[ ${KERNEL_IUSE_SECUREBOOT} ]]; then
			# Ensure the uki is signed if dracut hasn't already done so.
			secureboot_sign_efi_file "${image}"
		fi
	fi

	ebegin "Installing the kernel via installkernel"
	# note: .config is taken relatively to System.map;
	# initrd relatively to bzImage
	installkernel "${version}" "${image}" "${map}"
	eend ${?} || die -n "Installing the kernel failed"
}

# @FUNCTION: dist-kernel_reinstall_initramfs
# @USAGE: <kv-dir> <kv-full>
# @DESCRIPTION:
# Rebuild and install initramfs for the specified dist-kernel.
# <kv-dir> is the kernel source directory (${KV_DIR} from linux-info),
# while <kv-full> is the full kernel version (${KV_FULL}).
# The function will determine whether <kernel-dir> is actually
# a dist-kernel, and whether initramfs was used.
#
# This function is to be used in pkg_postinst() of ebuilds installing
# kernel modules that are included in the initramfs.
dist-kernel_reinstall_initramfs() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 2 ]] || die "${FUNCNAME}: invalid arguments"
	local kernel_dir=${1}
	local ver=${2}

	local image_path=${kernel_dir}/$(dist-kernel_get_image_path)
	local initramfs_path=${image_path%/*}/initrd
	if [[ ! -f ${image_path} ]]; then
		eerror "Kernel install missing, image not found:"
		eerror "  ${image_path}"
		eerror "Initramfs will not be updated.  Please reinstall your kernel."
		return
	fi
	if [[ ! -f ${initramfs_path} && ! -f ${initramfs_path%/*}/uki.efi ]]; then
		einfo "No initramfs or uki found at ${image_path}"
		return
	fi

	dist-kernel_build_initramfs "${initramfs_path}" "${ver}"
	dist-kernel_install_kernel "${ver}" "${image_path}" \
		"${kernel_dir}/System.map"
}

_RHEL_KERNEL_UTILS=1
fi
