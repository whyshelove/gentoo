# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel-kernel-utils.eclass
# @SUPPORTED_EAPIS: 7
# @BLURB: Utility functions related to rhel Kernels
# @DESCRIPTION:
# This eclass provides various utility functions related to rhel Kernels.

if [[ ! ${_RHEL_KERNEL_UTILS} ]]; then

case "${EAPI:-0}" in
	0|1|2|3|4|5|6)
		die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}"
		;;
	7)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

# @FUNCTION: rhel-kernel_build_initramfs
# @USAGE: <output> <version>
# @DESCRIPTION:
# Build an initramfs for the kernel.  <output> specifies the absolute
# path where initramfs will be created, while <version> specifies
# the kernel version, used to find modules.
#
# Note: while this function uses dracut at the moment, other initramfs
# variants may be supported in the future.
rhel-kernel_build_initramfs() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 2 ]] || die "${FUNCNAME}: invalid arguments"
	local output=${1}
	local version=${2}

	local rel_image_path=$(rhel-kernel_get_image_path)
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
		ppc64)
			# ./ is required because of ${image_path%/*}
			# substitutions in the code
			echo ./vmlinux
			;;
		s390)
			echo arch/s390/boot/bzImage
			;;
		*)
			die "${FUNCNAME}: unsupported ARCH=${ARCH}"
			;;
	esac
}

# @FUNCTION: rhel-kernel_install_kernel
# @USAGE: <version> <image> <system.map>
# @DESCRIPTION:
# Install kernel using installkernel tool.  <version> specifies
# the kernel version, <image> full path to the image, <system.map>
# full path to System.map.
rhel-kernel_install_kernel() {
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
		image=${initrd}.uefi
		mv "${initrd}" "${image}" || die
		# put an empty file in place of initrd.  installing a duplicate
		# file would waste disk space, and removing it entirely provokes
		# kernel-install to regenerate it via dracut.
		> "${initrd}"
	fi

	ebegin "Installing the kernel via installkernel"
	# note: .config is taken relatively to System.map;
	# initrd relatively to bzImage
	installkernel "${version}" "${image}" "${map}"
	eend ${?} || die -n "Installing the kernel failed"
}

# @FUNCTION: rhel-kernel_reinstall_initramfs
# @USAGE: <kv-dir> <kv-full>
# @DESCRIPTION:
# Rebuild and install initramfs for the specified rhel-kernel.
# <kv-dir> is the kernel source directory (${KV_DIR} from linux-info),
# while <kv-full> is the full kernel version (${KV_FULL}).
# The function will determine whether <kernel-dir> is actually
# a rhel-kernel, and whether initramfs was used.
#
# This function is to be used in pkg_postinst() of ebuilds installing
# kernel modules that are included in the initramfs.
rhel-kernel_reinstall_initramfs() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 2 ]] || die "${FUNCNAME}: invalid arguments"
	local kernel_dir=${1}
	local ver=${2}

	local image_path=${kernel_dir}/$(rhel-kernel_get_image_path)
	local initramfs_path=${image_path%/*}/initrd
	if [[ ! -f ${image_path} ]]; then
		eerror "Kernel install missing, image not found:"
		eerror "  ${image_path}"
		eerror "Initramfs will not be updated.  Please reinstall your kernel."
		return
	fi
	if [[ ! -f ${initramfs_path} ]]; then
		einfo "No initramfs found at ${initramfs_path}"
		return
	fi

	rhel-kernel_build_initramfs "${initramfs_path}" "${ver}"
	rhel-kernel_install_kernel "${ver}" "${image_path}" \
		"${kernel_dir}/System.map"
}

cp_vmlinux()
{
  eu-strip --remove-comment -o "$2" "$1"
}

InitBuildVars() {
    # Initialize the kernel .config file and create some variables that are
    # needed for the actual build process.

    Flavour=$1
    Flav=${Flavour:++${Flavour}}

    # Pick the right kernel config file
    Config=${MY_P}-${_target_cpu}${Flavour:+-${Flavour}}.config
    DevelDir=/usr/src/kernels/${KVERREL}${Flav}

    KernelVer=${K_PVD}.${_target_cpu}${Flav}

    # make sure EXTRAVERSION says what we want it to say
    release=${MY_PR}.${DIST}
    perl -p -i -e "s/^EXTRAVERSION.*/EXTRAVERSION = -${release}.${_target_cpu}${Flav}/" Makefile

    emake -s "${MAKEARGS[@]}" mrproper

    use savedconfig || cp configs/$Config .config

	restore_config .config
	[[ -f .config ]] || die "Ebuild error: please copy default config into .config"

    if use signkernel || use signmodules; then
	cp ${WORKDIR}/x509.genkey certs/.
    fi

    Arch=`head -1 .config | cut -b 3-`
    echo USING ARCH=$Arch

    KCFLAGS="${kcflags}"

    # add kpatch flags for base kernel
    if [ "$Flavour" == "" ]; then
        KCFLAGS="$KCFLAGS ${kpatch_kcflags}"
    fi
}

_pesign(){
    _pesign_nssdir=/etc/pki/pesign-rh-test
    _pesign_cert='Red Hat Test Certificate'
    /usr/bin/pesign -c "${_pesign_cert}" \
        --certdir ${_pesign_nssdir} -i ${1} -o ${2} -s || die
}

BuildKernel() {
    MakeTarget=$1
    KernelImage=$2
    Flavour=$4
    DoVDSO=$3
    Flav=${Flavour:++${Flavour}}
    InstallName=${5:-vmlinuz}

    # When the bootable image is just the ELF kernel, strip it.
    # We already copy the unstripped file into the debuginfo package.
    if [ "$KernelImage" = vmlinux ]; then
        CopyKernel=cp_vmlinux
    else
        CopyKernel=cp
    fi

    InitBuildVars $Flavour

    echo BUILDING A KERNEL FOR ${Flavour} ${_target_cpu}...

    emake -s "${MAKEARGS[@]}" oldnoconfig >/dev/null
    emake -s "${MAKEARGS[@]}" KCFLAGS="$KCFLAGS" WITH_GCOV="${with_gcov:-0}" $MakeTarget

    if use modules; then
	emake -s "${MAKEARGS[@]}" KCFLAGS="$KCFLAGS" WITH_GCOV="${with_gcov:-0}" modules || die
    fi

    if use arm64; then
        emake -s "${MAKEARGS[@]}" dtbs dtbs_install INSTALL_DTBS_PATH=${ED}/${image_install_path}/dtb-$KernelVer
        cp -r ${ED}/${image_install_path}/dtb-$KernelVer ${ED}/lib/modules/$KernelVer/dtb
        find arch/$Arch/boot/dts -name '*.dtb' -type f | xargs rm -f
    fi
}

perf_make=(
    emake EXTRA_CFLAGS="${OPT_FLAGS}" LDFLAGS="${LDFLAGS}" -C tools/perf V=1 NO_PERF_READ_VDSO32=1 WERROR=0 NO_LIBUNWIND=1 HAVE_CPLUS_DEMANGLE=1 NO_GTK2=1 NO_STRLCPY=1 NO_BIONIC=1 LIBBPF_DYNAMIC=1 LIBTRACEEVENT_DYNAMIC=1 ${perf_build_extra_opts} prefix="${EPREFIX}/usr" PYTHON=${EPYTHON}
)

InstallKernel(){
    # Start installing the results
    dodir /${image_install_path} /lib/modules/$KernelVer
    insinto /boot && newins .config config-$KernelVer && newins System.map System.map-$KernelVer
    insinto /lib/modules/$KernelVer && newins .config config && doins System.map

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
                    _pesign $SignImage vmlinuz.tmp ${secureboot_ca_0} ${secureboot_key_0} ${pesign_name_0}
                    _pesign vmlinuz.tmp vmlinuz.signed ${secureboot_ca_1} ${secureboot_key_1} ${pesign_name_1}
                    rm vmlinuz.tmp
                    ;;
            s390|ppc64)
                    if [ -x /usr/bin/rpmsign ]; then
                        rpmsign --key "${pesign_name_0}" --lkmsign $SignImage --output vmlinuz.signed
                    elif use modules; then
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
#    echo "Creating hmac file: ${ED}/${image_install_path}/.vmlinuz-$KernelVer.hmac"
    ls -l ${ED}/${image_install_path}/$InstallName-$KernelVer
#    sha512hmac ${ED}/${image_install_path}/$InstallName-$KernelVer | sed -e "s,${ED},," > ${ED}/${image_install_path}/.vmlinuz-$KernelVer.hmac;
#    cp ${ED}/${image_install_path}/.vmlinuz-$KernelVer.hmac ${ED}/lib/modules/$KernelVer/.vmlinuz.hmac

    if use modules; then
        # Override $(mod-fw) because we don't want it to install any firmware
        # we'll get it from the linux-firmware package and we don't want conflicts
        emake -s "${MAKEARGS[@]}" INSTALL_MOD_PATH=${ED} modules_install KERNELRELEASE=$KernelVer mod-fw=
    fi

    use gcov && find . \( -name '*.gcno' -o -name '*.[chS]' \) -exec install -D '{}' "${ED}/$(pwd)/{}" \;

    if [ $DoVDSO -ne 0 ]; then
        emake -s "${MAKEARGS[@]}" INSTALL_MOD_PATH=${ED} vdso_install KERNELRELEASE=$KernelVer
        if [ ! -s ldconfig-kernel.conf ]; then
            echo > ldconfig-kernel.conf "\
            # Placeholder file, no vDSO hwcap entries used in this kernel."
        fi
        insopts -m0444 && insinto /etc/ld.so.conf.d
        newins ldconfig-kernel.conf ${MY_PN}-$KernelVer.conf
        rm -rf ${ED}/lib/modules/$KernelVer/vdso/.build-id
    fi

    rm -f ${ED}/lib/modules/$KernelVer/{build,source}
    # dirs for additional modules per module-init-tools, kbuild/modules.txt
    dodir /lib/modules/$KernelVer/{build,updates,weak-updates}
    dosym build /lib/modules/$KernelVer/source

    # first copy everything
    cp --parents `find  -type f -name "Makefile*" -o -name "Kconfig*"` ${ED}/lib/modules/$KernelVer/build
    insinto /lib/modules/$KernelVer/build && doins -r Module.symvers System.map .config
    [ -s Module.markers ] && doins Module.markers 

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

    if [ -f tools/objtool/objtool ]; then
      cp -a tools/objtool/objtool ${ED}/lib/modules/$KernelVer/build/tools/objtool/ || :
    fi
    if [ -d arch/$Arch/scripts ]; then
      cp -a arch/$Arch/scripts ${ED}/lib/modules/$KernelVer/build/arch/%{_arch} || :
    fi
    if [ -f arch/$Arch/*lds ]; then
      cp -a arch/$Arch/*lds ${ED}/lib/modules/$KernelVer/build/arch/%{_arch}/ || :
    fi
    if [ -f arch/%{asmarch}/kernel/module.lds ]; then
      cp -a --parents arch/%{asmarch}/kernel/module.lds ${ED}/lib/modules/$KernelVer/build/
    fi
    rm -f ${ED}/lib/modules/$KernelVer/build/scripts/*.o
    rm -f ${ED}/lib/modules/$KernelVer/build/scripts/*/*.o

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
        cp -a --parents arch/x86/entry/syscalls/syscall_32.tbl ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/entry/syscalls/syscalltbl.sh ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/entry/syscalls/syscallhdr.sh ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/entry/syscalls/syscall_64.tbl ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs_32.c ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs_64.c ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs.c ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs_common.c ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/tools/relocs.h ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents tools/include/tools/le_byteshift.h ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/purgatory.c ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/stack.S ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/setup-x86_64.S ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/purgatory/entry64.S ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/boot/string.h ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/boot/string.c ${ED}/lib/modules/$KernelVer/build/
        cp -a --parents arch/x86/boot/ctype.h ${ED}/lib/modules/$KernelVer/build/
    fi
    # Make sure the Makefile and version.h have a matching timestamp so that
    # external modules can be built
    touch -r ${ED}/lib/modules/$KernelVer/build/Makefile ${ED}/lib/modules/$KernelVer/build/include/generated/uapi/linux/version.h

    # Copy .config to include/config/auto.conf so "make prepare" is unnecessary.
    cp ${ED}/lib/modules/$KernelVer/build/.config ${ED}/lib/modules/$KernelVer/build/include/config/auto.conf

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
    if use realtime; then
        collect_modules_list kvm \
        'kvm_init|kvmgt_init'
    fi

    # detect missing or incorrect license tags
    ( find ${ED}/lib/modules/$KernelVer -name '*.ko' | xargs modinfo -l | \
        grep -E -v 'GPL( v2)?$|Dual BSD/GPL$|Dual MPL/GPL$|GPL and additional rights$' ) && die

    # remove files that will be auto generated by depmod at rpm -i time
    pushd ${ED}/lib/modules/$KernelVer/
        rm -f modules.{alias*,builtin.bin,dep*,*map,symbols*,devname,softdep}
    popd

    #if use modules; then
	#    mod-blacklist='${WORKDIR}/mod-blacklist.sh'
	    # Identify modules in the kernel-modules-extras package
	 #   ${mod-blacklist} ${ED} lib/modules/$KernelVer "${WORKDIR}/mod-extra.list"
	    # Identify modules in the kernel-modules-internal package
	  #  ${mod-blacklist} ${ED} lib/modules/$KernelVer "${WORKDIR}/mod-internal.list" internal

	   # if use realtime; then
		# Identify modules in the kernel-rt-kvm package
		#${mod-blacklist} ${ED} lib/modules/$KernelVer "${WORKDIR}/mod-kvm.list" kvm
	    #fi
    #fi
    #
    # Generate the kernel-core and kernel-modules files lists
    #

    # Copy the System.map file for depmod to use, and create a backup of the
    # full module tree so we can restore it after we're done filtering
    cp System.map ${ED}/.
    pushd ${ED}
    mkdir restore
    cp -r lib/modules/$KernelVer/* restore/.

    if use modules; then
	    # don't include anything going into kernel-modules-extra in the file lists
	    xargs rm -rf < mod-extra.list
	    # don't include anything going int kernel-modules-internal in the file lists
	    xargs rm -rf < mod-internal.list

	    if use realtime; then
		# don't include anything going into kernel-rt-kvm in the file lists
		xargs rm -rf < mod-kvm.list
	    fi
    fi

    if use modules; then
        # Find all the module files and filter them out into the core and
        # modules lists.  This actually removes anything going into -modules
        # from the dir.
        find lib/modules/$KernelVer/kernel -name *.ko | sort -n > modules.list
        cp ${WORKDIR}/filter-*.sh .
        ${WORKDIR}/filter-modules.sh modules.list ${_target_cpu}
        rm filter-*.sh

        # Run depmod on the resulting module tree and make sure it isn't broken
        depmod -b . -aeF ./System.map $KernelVer &> depmod.out
        if [ -s depmod.out ]; then
            echo "Depmod failure"
            cat depmod.out
            die
        else
            rm depmod.out
        fi
    else
        # Ensure important files/directories exist to let the packaging succeed
        echo '%%defattr(-,-,-)' > modules.list
        echo '%%defattr(-,-,-)' > k-d.list
        mkdir -p lib/modules/$KernelVer/kernel
        # Add files usually created by make modules, needed to prevent errors
        # thrown by depmod during package installation
        touch lib/modules/$KernelVer/modules.order
        touch lib/modules/$KernelVer/modules.builtin
    fi

    # remove files that will be auto generated by depmod at rpm -i time
    pushd ${ED}/lib/modules/$KernelVer/
        rm -f modules.{alias*,builtin.bin,dep*,*map,symbols*,devname,softdep}
    popd

    # Go back and find all of the various directories in the tree.  We use this
    # for the dir lists in kernel-core
    find lib/modules/$KernelVer/kernel -mindepth 1 -type d | sort -n > module-dirs.list

    # Cleanup
    rm System.map
    cp -r restore/* lib/modules/$KernelVer/.
    rm -rf restore
    popd

    # Make sure the files lists start with absolute paths or rpmbuild fails.
    # Also add in the dir entries
    #if use modules; then
	#sed -e 's/^lib*/\/lib/' -${zipsed} ${ED}/k-d.list > ../${MY_PN}${Flavour:+-${Flavour}}-modules.list
	#sed -e 's/^lib*/%dir \/lib/' ${zipsed} ${ED}/module-dirs.list > ../${MY_PN}${Flavour:+-${Flavour}}-core.list
	#sed -e 's/^lib*/\/lib/' ${zipsed} ${ED}/modules.list >> ../${MY_PN}${Flavour:+-${Flavour}}-core.list
	#sed -e 's/^lib*/\/lib/' ${zipsed} ${ED}/mod-extra.list >> ../${MY_PN}${Flavour:+-${Flavour}}-modules-extra.list
	#sed -e 's/^lib*/\/lib/' ${zipsed} ${ED}/mod-internal.list >> ../${MY_PN}${Flavour:+-${Flavour}}-modules-internal.list
    #fi

    #use realtime && sed -e 's/^lib*/\/lib/' ${zipsed} ${ED}/mod-kvm.list >> ../${MY_PN}${Flavour:+-${Flavour}}-kvm.list

    # Cleanup
    rm -f ${ED}/{k-d,modules,module-dirs,mod-extra,mod-internal}.list
    use realtime && rm -f ${ED}/mod-kvm.list

    if use signmodules; then
        # Save the signing keys so we can sign the modules in __modsign_install_post
        cp certs/signing_key.pem certs/signing_key.pem.sign${Flav}
        cp certs/signing_key.x509 certs/signing_key.x509.sign${Flav}
    fi

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
      bpftool btf dump file vmlinux format c > ${ED}/$DevelDir/vmlinux.h
    fi

    # prune junk from kernel-devel
    find ${ED}/usr/src/kernels -name ".*.cmd" -exec rm -f {} \;

    # build a BLS config for this kernel
    ${WORKDIR}/generate_bls_conf.sh "$KernelVer" "${ED}"

    # Red Hat UEFI Secure Boot CA cert, which can be used to authenticate the kernel
    dodir ${_datadir}/doc/kernel-keys/$KernelVer
    if use arm64 || use amd64; then
        insinto ${_datadir}/doc/kernel-keys/$KernelVer
        newins ${secureboot_ca_0} kernel-signing-ca-20200609.cer
        newins ${secureboot_ca_1} kernel-signing-ca-20140212.cer
        dosym kernel-signing-ca-20200609.cer ${_datadir}/doc/kernel-keys/$KernelVer/kernel-signing-ca.cer

   else
        insinto ${_datadir}/doc/kernel-keys/$KernelVer
        newins ${secureboot_ca_0} kernel-signing-ca.cer
   fi

	if use s390 || use ppc64; then
	    if use modules; then
		    if [ -x /usr/bin/rpmsign ]; then
		        insinto ${_datadir}/doc/kernel-keys/$KernelVer
		        newins ${secureboot_key_0} ${signing_key_filename}
		    else
		        insinto ${_datadir}/doc/kernel-keys/$KernelVer
		        newins certs/signing_key.x509.sign${Flav} kernel-signing-ca.cer
		        openssl x509 -in certs/signing_key.pem.sign${Flav} -outform der -out \
		                {ED}${_datadir}/doc/kernel-keys/$KernelVer/${signing_key_filename}
		        fperms 0644 ${_datadir}/doc/kernel-keys/$KernelVer/${signing_key_filename}
		    fi
	    fi
	fi

    if use ipaclones; then
        MAXPROCS=$(echo ${makeops} | sed -n 's/-j\s*\([0-9]\+\)/\1/p')
        if [ -z "$MAXPROCS" ]; then
            MAXPROCS=1
        fi
        if [ "$Flavour" == "" ]; then
            mkdir -p ${ED}/$DevelDir-ipaclones
            find . -name '*.ipa-clones' | xargs -i{} -r -n 1 -P $MAXPROCS install -m 644 -D "{}" "${ED}/$DevelDir-ipaclones/{}"
        fi
    fi
}

_RHEL_KERNEL_UTILS=1
fi
