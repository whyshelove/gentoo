# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel-kernel-build.eclass
# @MAINTAINER:
# Distribution Kernel Project <dist-kernel@gentoo.org>
# @AUTHOR:
# Michał Górny <mgorny@gentoo.org>
# @SUPPORTED_EAPIS: 8
# @PROVIDES: kernel-install
# @BLURB: Build mechanics for Distribution Kernels
# @DESCRIPTION:
# This eclass provides the logic to build a Distribution Kernel from
# source and install it.  Post-install and test logic is inherited
# from kernel-install.eclass.
#
# The ebuild must take care of unpacking the kernel sources, copying
# an appropriate .config into them (e.g. in src_prepare()) and setting
# correct S.  The eclass takes care of respecting savedconfig, building
# the kernel and installing it along with its modules and subset
# of sources needed to build external modules.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ ! ${_KERNEL_BUILD_ECLASS} ]]; then
_KERNEL_BUILD_ECLASS=1

PYTHON_COMPAT=( python3_{9..12} )
if [[ ${KERNEL_IUSE_MODULES_SIGN} ]]; then
	# If we have enabled module signing IUSE
	# then we can also enable secureboot IUSE
	KERNEL_IUSE_SECUREBOOT=1
	inherit secureboot
fi

inherit multiprocessing python-any-r1 savedconfig toolchain-funcs rhel-kernel-install rhel9

BDEPEND="
	${PYTHON_DEPS}
	app-arch/cpio
	sys-devel/bc
	sys-devel/flex
	virtual/libelf
	app-alternatives/yacc
	arm? ( sys-apps/dtc )
	arm64? ( sys-apps/dtc )
	riscv? ( sys-apps/dtc )
        signkernel? ( app-crypt/pesign dev-libs/nss[utils] )
	signmodules? ( app-crypt/pesign dev-libs/nss[utils] )
	dev-util/pahole
	!sys-kernel/linux-firmware[initramfs]
"

IUSE="+strip"

# @ECLASS_VARIABLE: KERNEL_IUSE_MODULES_SIGN
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# If set to a non-null value, adds IUSE=modules-sign and required
# logic to manipulate the kernel config while respecting the
# MODULES_SIGN_HASH, MODULES_SIGN_CERT, and MODULES_SIGN_KEY  user
# variables.

# @ECLASS_VARIABLE: MODULES_SIGN_HASH
# @USER_VARIABLE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Used with USE=modules-sign.  Can be set to hash algorithm to use
# during signature generation (CONFIG_MODULE_SIG_SHA256).
#
# Valid values: sha512,sha384,sha256,sha224,sha1
#
# Default if unset: sha512

# @ECLASS_VARIABLE: MODULES_SIGN_KEY
# @USER_VARIABLE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Used with USE=modules-sign.  Can be set to the path of the private
# key in PEM format to use, or a PKCS#11 URI (CONFIG_MODULE_SIG_KEY).
#
# If path is relative (e.g. "certs/name.pem"), it is assumed to be
# relative to the kernel build directory being used.
#
# If the key requires a passphrase or PIN, the used kernel sign-file
# utility recognizes the KBUILD_SIGN_PIN environment variable.  Be
# warned that the package manager may store this value in binary
# packages, database files, temporary files, and possibly logs.  This
# eclass unsets the variable after use to mitigate the issue (notably
# for shared binary packages), but use this with care.
#
# Default if unset: certs/signing_key.pem

# @ECLASS_VARIABLE: MODULES_SIGN_CERT
# @USER_VARIABLE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Used with USE=modules-sign.  Can be set to the path of the public
# key in PEM format to use. Must be specified if MODULES_SIGN_KEY
# is set to a path of a file that only contains the private key.

if [[ ${KERNEL_IUSE_MODULES_SIGN} ]]; then
	IUSE+=" modules-sign"
	REQUIRED_USE="secureboot? ( modules-sign )"
	BDEPEND+="
		modules-sign? ( dev-libs/openssl )
	"
fi



# @FUNCTION: rhel-kernel-build_pkg_setup
# @DESCRIPTION:
# Call python-any-r1 and secureboot pkg_setup
rhel-kernel-build_pkg_setup() {
	python-any-r1_pkg_setup
	if [[ ${KERNEL_IUSE_MODULES_SIGN} ]]; then
		secureboot_pkg_setup
	fi

export _target_cpu=$(rhel-kernel-install_get_qemu_arch)

if [[ ${subrelease} ]]; then
	K_PRD=${MY_PR}.${subrelease}.${DIST}
else
	K_PRD=${MY_PR}.${DIST}
fi

K_PVF=${PV/_p*}-${K_PRD}

if [[ ${subrelease} ]]; then
	KVERREL=${K_PVF}${DSUFFIX}.${_target_cpu}
else
	KVERREL=${K_PVF}.${_target_cpu}
fi

if [[ ${subrelease} ]]; then
	S=${WORKDIR}/kernel-${K_PVF}${DSUFFIX}/linux-${K_PVF}.${_target_cpu}
else
	S=${WORKDIR}/kernel-${K_PVF}/linux-${K_PVF}.${_target_cpu}
fi

    export make_target=bzImage
    export hdrarch=${_target_cpu}
    export asmarch=${_target_cpu}
    export image_install_path=boot
    export modsign_cmd="${WORKDIR}"/mod-sign.sh
    use gcov && export with_gcov=1
    use vdso && export _use_vdso=1
    use ipaclones && ( use amd64 || use ppc64 ) && export kpatch_kcflags=-fdump-ipa-clones
    use debug && export debuginfodir=/usr/lib/debug

    secureboot_ca_0=${_datadir}/pki/sb-certs/secureboot-ca-${_target_cpu}.cer
    secureboot_key_0=${_datadir}/pki/sb-certs/secureboot-kernel-${_target_cpu}.cer

	if use arm64 || use amd64; then
		pesign_name_0=redhatsecureboot501
	fi

	case ${ARCH} in
		amd64|x86)
			export asmarch=x86
			[[ ${ARCH} == x86 ]] && export hdrarch=i386
			;;
		arm64)
			export perf_build_extra_opts='CORESIGHT=1'
			export asmarch=arm64
			export hdrarch=arm64
			export make_target=Image.gz
			;;
		ppc64)
			export asmarch=powerpc
			export hdrarch=powerpc
			export make_target=vmlinux
			export kernel_image_elf=1
			export kcflags=-O3
			export signing_key_filename=kernel-signing-ppc.cer
			;;
		s390)
			export asmarch=s390
			export hdrarch=s390
			export vmlinux_decompressor=arch/s390/boot/compressed/vmlinux
			export signing_key_filename=kernel-signing-s390.cer
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	export kernel_image=$(rhel-kernel_get_image_path)
	export all_arch_configs=${MY_P}-${_target_cpu}*.config
}

# @FUNCTION: rhel-kernel-build_src_configure
# @DESCRIPTION:
# Prepare the toolchain for building the kernel, get the default .config
# or restore savedconfig, and get build tree configured for modprep.
rhel-kernel-build_src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	# force ld.bfd if we can find it easily
	local LD="$(tc-getLD)"
	if type -P "${LD}.bfd" &>/dev/null; then
		LD+=.bfd
	fi

	filter-lto

	tc-export_build_env
	MAKEARGS=(
		V=1

		HOSTCC="$(tc-getBUILD_CC)"
		HOSTCXX="$(tc-getBUILD_CXX)"
		HOSTCFLAGS="${BUILD_CFLAGS}"
		HOSTLDFLAGS="${BUILD_LDFLAGS}"

		CROSS_COMPILE=${CHOST}-
		AS="$(tc-getAS)"
		CC="$(tc-getCC)"
		LD="${LD}"
		AR="$(tc-getAR)"
		NM="$(tc-getNM)"
		STRIP="$(tc-getSTRIP)"
		OBJCOPY="$(tc-getOBJCOPY)"
		OBJDUMP="$(tc-getOBJDUMP)"

		ARCH=`head -1 "configs/${MY_P}-${_target_cpu}.config" | cut -b 3-`
	)

	if type -P xz &>/dev/null ; then
		export XZ_OPT="-T$(makeopts_jobs) --memlimit-compress=50% -q"
	fi

	if type -P zstd &>/dev/null ; then
		export ZSTD_NBTHREADS="$(makeopts_jobs)"
	fi

	# pigz/pbzip2/lbzip2 all need to take an argument, not an env var,
	# for their options, which won't work because of how the kernel build system
	# uses the variables (e.g. passes directly to tar as an executable).
	if type -P pigz &>/dev/null ; then
		MAKEARGS+=( KGZIP="pigz" )
	fi

	if type -P pbzip2 &>/dev/null ; then
		MAKEARGS+=( KBZIP2="pbzip2" )
	elif type -P lbzip2 &>/dev/null ; then
		MAKEARGS+=( KBZIP2="lbzip2" )
	fi
}

# @FUNCTION: rhel-kernel-build_src_compile
# @DESCRIPTION:
# Compile the kernel sources.
rhel-kernel-build_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"


	use debug && BuildKernel $make_target $kernel_image ${_use_vdso:-0} debug

	use zfcpdump && BuildKernel $make_target $kernel_image ${_use_vdso:-0} zfcpdump

	use up && BuildKernel $make_target $kernel_image ${_use_vdso:-0}

    if use perf; then
        # perf
        # make sure check-headers.sh is executable
        chmod +x tools/perf/check-headers.sh
        ${perf_make[@]} DESTDIR="${ED}" all

	# libperf
	make -C tools/lib/perf V=1
    fi

    if use tools; then
        if use arm64 || use amd64 || use ppc64; then
            # cpupower
            # make sure version-gen.sh is executable.
            chmod +x tools/power/cpupower/utils/version-gen.sh
            tools_make -C tools/power/cpupower CPUFREQ_BENCH=false DEBUG=false
            if use amd64; then
                pushd tools/power/cpupower/debug/x86_64
                tools_make centrino-decode powernow-k8-decode
                popd
                pushd tools/power/x86/x86_energy_perf_policy/
                tools_make
                popd
                pushd tools/power/x86/turbostat
                tools_make
                popd
                pushd tools/power/x86/intel-speed-select
                tools_make
                popd
                pushd tools/arch/x86/intel_sdsi
                tools_make
                popd
            fi
        fi
        pushd tools/thermal/tmon/
        tools_make
        popd
        pushd tools/iio/
        tools_make
        popd
        pushd tools/gpio/
        tools_make
        popd
        # build VM tools
        pushd tools/vm/
        tools_make slabinfo page_owner_sort
        popd
	pushd tools/verification/rv/
	tools_make
	popd
	pushd tools/tracing/rtla
	tools_make
	popd
    fi

	if [ -f $DevelDir/vmlinux.h ]; then
	  _VMLINUX_H=$DevelDir/vmlinux.h
	fi

    if use bpf; then
        pushd tools/bpf/bpftool
        emake EXTRA_CFLAGS="${OPT_FLAGS}" EXTRA_LDFLAGS="${LDFLAGS}" DESTDIR="${ED}" VMLINUX_H="${_VMLINUX_H}" V=1
        popd
    fi
}

# @FUNCTION: rhel-kernel-build_src_test
# @DESCRIPTION:
# Test the built kernel via qemu.  This just wraps the logic
# from kernel-install.eclass with the correct paths.
rhel-kernel-build_src_test() {
	debug-print-function ${FUNCNAME} "${@}"
	local targets=( modules_install )
	# on arm or arm64 you also need dtb
	if use arm || use arm64 || use riscv; then
		targets+=( dtbs_install )
	fi

	emake O="${WORKDIR}"/build "${MAKEARGS[@]}" \
		INSTALL_MOD_PATH="${T}" "${targets[@]}"

	local dir_ver=${PV}${KV_LOCALVERSION}
	local relfile=${WORKDIR}/build/include/config/kernel.release
	local module_ver
	module_ver=$(<"${relfile}") || die

	kernel-install_test "${module_ver}" \
		"${WORKDIR}/build/$(dist-kernel_get_image_path)" \
		"${T}/lib/modules/${module_ver}"
}

# @FUNCTION: rhel-kernel-build_src_install
# @DESCRIPTION:
# Install the built kernel along with subset of sources
# into /usr/src/linux-${PV}.  Install the modules.  Save the config.
rhel-kernel-build_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	InstallKernel

    if use perf; then
        # perf tool binary and supporting scripts/binaries
        ${perf_make[@]} DESTDIR="${ED}" lib=${_lib} install-bin
        # remove the 'trace' symlink.
        rm -f "${ED}"${_bindir}/trace

        # remove examples
        rm -rf "${ED}"/usr/lib/perf/{examples,include}

        # python-perf extension
        ${perf_make[@]} DESTDIR="${ED}" install-python_ext

        # perf man pages (note: implicit rpm magic compresses them later)
        dodir ${_mandir}/man1
        ${perf_make[@]} DESTDIR="${ED}" install-man

	# remove any tracevent files, eg. its plugins still gets built and installed,
	# even if we build against system's libtracevent during perf build (by setting
	# LIBTRACEEVENT_DYNAMIC=1 above in perf_make macro). Those files should already
	# ship with libtraceevent package.
	rm -rf "${ED}"${_libdir}/traceevent

	# libperf
	make -C tools/lib/perf DESTDIR="${ED}" prefix=${_prefix} libdir=${_libdir} V=1 install
	rm -f "${ED}"${_libdir}/libperf.a
    fi

    if use tools; then
        if use arm64 || use amd64 || use ppc64; then
            emake -C tools/power/cpupower DESTDIR="${ED}" libdir=${_libdir} mandir=${_mandir} CPUFREQ_BENCH=false install
	    rm -f "${ED}"${_libdir}/*.{a,la}
            if use amd64; then
                pushd tools/power/cpupower/debug/x86_64
                dobin centrino-decode powernow-k8-decode
                popd
                dodir ${_mandir}/man8
                pushd tools/power/x86/x86_energy_perf_policy
                tools_make DESTDIR="${ED}" install
                popd
                pushd tools/power/x86/turbostat
                tools_make DESTDIR="${ED}" install
                popd
                pushd tools/power/x86/intel-speed-select
                tools_make DESTDIR="${ED}" install
                popd
                pushd tools/arch/x86/intel_sdsi
                tools_make DESTDIR="${ED}" install
                popd
            fi
            fperms  0755 ${_libdir}/libcpupower.so*
            insinto ${_sysconfdir}/sysconfig
            newins "${WORKDIR}"/'cpupower.config' cpupower
            systemd_dounit "${WORKDIR}"/'cpupower.service'
        fi
        pushd tools/thermal/tmon
        tools_make INSTALL_ROOT="${ED}" install
        popd
        pushd tools/iio
        tools_make DESTDIR="${ED}" install
        popd
        pushd tools/gpio
        tools_make DESTDIR="${ED}" install
        popd
        insinto ${_sysconfdir}/logrotate.d && newins "${WORKDIR}"/'kvm_stat.logrotate' kvm_stat
        pushd tools/kvm/kvm_stat
        emake INSTALL_ROOT="${ED}" install-tools
        emake INSTALL_ROOT="${ED}" install-man
        systemd_dounit "${WORKDIR}"/'kvm_stat.service'
        popd

	# install VM tools
	pushd tools/vm/
	newbin slabinfo page_owner_sort
	popd

	pushd tools/verification/rv/
	tools_make DESTDIR="${ED}" install
	popd

	pushd tools/tracing/rtla/
	tools_make DESTDIR="${ED}" install
	rm -f "${ED}"${_bindir}/{hwnoise,osnoise}
	rm -f "${ED}"${_bindir}/timerlat
	(cd "${ED}"

		ln -sf rtla ./${_bindir}/hwnoise
		ln -sf rtla ./${_bindir}/osnoise
		ln -sf rtla ./${_bindir}/timerlat
	)
	popd
    fi

	# We don't call InitBuildVars in install section so $DevelDir
	# variable is not defined. Using the $DevelDir definition
	# directly.
	if [ -f /usr/src/kernels/${KVERREL}/vmlinux.h ]; then
	   _VMLINUX_H=/usr/src/kernels/${KVERREL}/vmlinux.h
	fi

    if use bpf; then
        pushd tools/bpf/bpftool
        emake prefix="${EPREFIX}/usr" bash_compdir=${_sysconfdir}/bash_completion.d/ mandir=${_mandir} install doc-install
        popd

	# bpf-helpers.7 manpage has been moved under samples
	# a01d935b2e09 ("tools/bpf: Remove bpf-helpers from bpftool docs")
	pushd tools/testing/selftests/bpf
	  emake -f Makefile.docs DESTDIR="${ED}" mandir=${_mandir} docs-install
	popd
    fi

	# strip empty directories
	find "${D}" -type d -empty -exec rmdir {} + || die

	save_config .config

	# Use the kernel build system to strip, this ensures the modules
	# are stripped *before* they are signed or compressed.
	local strip_args
	if use strip; then
		strip_args="--strip-unneeded"
	fi
	# Modules were already stripped by the kernel build system
	dostrip -x /lib/modules

    if use signmodules; then
  	echo "**** signmodules. ****"
        use debug && ${modsign_cmd} certs/signing_key.pem.sign+debug certs/signing_key.x509.sign+debug "${ED}"/lib/modules/${KVERREL}+debug/
        use up && ${modsign_cmd} certs/signing_key.pem.sign certs/signing_key.x509.sign "${ED}"/lib/modules/${KVERREL}/
    fi

    if use zipmodules; then
   	echo "**** zipmodules. ****"
        find "${ED}"/lib/modules/ -type f -name '*.ko' | xargs -n 16 -P$(makeopts_jobs) -r xz;
    fi
}

# @FUNCTION: rhel-kernel-build_pkg_postinst
# @DESCRIPTION:
# Combine postinst from kernel-install and savedconfig eclasses.
rhel-kernel-build_pkg_postinst() {
	rhel-kernel-install_pkg_postinst
	savedconfig_pkg_postinst

	if [[ -d "/boot/efi/EFI/gentoo" ]]; then
	   if ! [[ -f /boot/efi/EFI/gentoo/grub.cfg ]]; then
		grub-mkconfig -o /boot/efi/EFI/gentoo/grub.cfg || die
	   fi
	elif [[ -d "/boot/grub" ]]; then
	   if ! [[ -f /boot/grub/grub.cfg ]]; then
		grub-mkconfig -o /boot/grub/grub.cfg || die
	   fi
	fi

	if [[ ${KERNEL_IUSE_MODULES_SIGN} ]]; then
		if use modules-sign && [[ -z ${MODULES_SIGN_KEY} ]]; then
			ewarn
			ewarn "MODULES_SIGN_KEY was not set, this means the kernel build system"
			ewarn "automatically generated the signing key. This key was installed"
			ewarn "in ${EROOT}/usr/src/linux-${PV}${KV_LOCALVERSION}/certs"
			ewarn "and will also be included in any binary packages."
			ewarn "Please take appropriate action to protect the key!"
			ewarn
			ewarn "Recompiling this package causes a new key to be generated. As"
			ewarn "a result any external kernel modules will need to be resigned."
			ewarn "Use emerge @module-rebuild, or manually sign the modules as"
			ewarn "described on the wiki [1]"
			ewarn
			ewarn "Consider using the MODULES_SIGN_KEY variable to use an external key."
			ewarn
			ewarn "[1]: https://wiki.gentoo.org/wiki/Signed_kernel_module_support"
		fi
	fi
}

# @FUNCTION: rhel-kernel-build_merge_configs
# @USAGE: [distro.config...]
# @DESCRIPTION:
# Merge the config files specified as arguments (if any) into
# the '.config' file in the current directory, then merge
# any user-supplied configs from ${BROOT}/etc/kernel/config.d/*.config.
# The '.config' file must exist already and contain the base
# configuration.
rhel-kernel-build_merge_configs() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ -f .config ]] || die "${FUNCNAME}: .config does not exist"
	has .config "${@}" &&
		die "${FUNCNAME}: do not specify .config as parameter"

	local shopt_save=$(shopt -p nullglob)
	shopt -s nullglob
	local user_configs=( "${BROOT}"/etc/kernel/config.d/*.config )
	shopt -u nullglob

	local merge_configs=( "${@}" )

	if [[ ${KERNEL_IUSE_MODULES_SIGN} ]]; then
		if use modules-sign; then
			: "${MODULES_SIGN_HASH:=sha512}"
			cat <<-EOF > "${WORKDIR}/modules-sign.config" || die
				## Enable module signing
				CONFIG_MODULE_SIG=y
				CONFIG_MODULE_SIG_ALL=y
				CONFIG_MODULE_SIG_FORCE=y
				CONFIG_MODULE_SIG_${MODULES_SIGN_HASH^^}=y
			EOF
			if [[ -e ${MODULES_SIGN_KEY} && -e ${MODULES_SIGN_CERT} &&
				${MODULES_SIGN_KEY} != ${MODULES_SIGN_CERT} &&
				${MODULES_SIGN_KEY} != pkcs11:* ]]
			then
				cat "${MODULES_SIGN_CERT}" "${MODULES_SIGN_KEY}" > "${T}/kernel_key.pem" || die
				MODULES_SIGN_KEY="${T}/kernel_key.pem"
			fi
			if [[ ${MODULES_SIGN_KEY} == pkcs11:* || -r ${MODULES_SIGN_KEY} ]]; then
				echo "CONFIG_MODULE_SIG_KEY=\"${MODULES_SIGN_KEY}\"" \
					>> "${WORKDIR}/modules-sign.config"
			elif [[ -n ${MODULES_SIGN_KEY} ]]; then
				die "MODULES_SIGN_KEY=${MODULES_SIGN_KEY} not found or not readable!"
			fi
			merge_configs+=( "${WORKDIR}/modules-sign.config" )
		fi
	fi

	if [[ ${#user_configs[@]} -gt 0 ]]; then
		elog "User config files are being applied:"
		local x
		for x in "${user_configs[@]}"; do
			elog "- ${x}"
		done
		merge_configs+=( "${user_configs[@]}" )
	fi

	./scripts/kconfig/merge_config.sh -m -r \
		.config "${merge_configs[@]}"  || die
}

fi

EXPORT_FUNCTIONS pkg_setup src_configure src_compile src_test src_install pkg_postinst
