# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel-kernel-build.eclass
# @SUPPORTED_EAPIS: 7
# @BLURB: Build mechanics for rhel Kernels
# @DESCRIPTION:
# This eclass provides the logic to build a rhel Kernel from
# source and install it.  Post-install and test logic is inherited
# from rhel-kernel-install.eclass.

if [[ ! ${_KERNEL_BUILD_ECLASS} ]]; then

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

PYTHON_COMPAT=( python3_{6..10} )

inherit multiprocessing python-any-r1 savedconfig toolchain-funcs rhel-kernel-install rhel8

BDEPEND="
	${PYTHON_DEPS}
	app-arch/cpio
	sys-devel/bc
	sys-devel/flex
	virtual/libelf
	virtual/yacc
        signkernel? ( app-crypt/pesign dev-libs/nss[utils] )
	signmodules? ( app-crypt/pesign dev-libs/nss[utils] )
"

_target_cpu=$(rhel-kernel-install_get_qemu_arch)

if [[ ${subrelease} ]]; then
	K_PRD=${MY_PR}.${subrelease}.${DIST}
else
	K_PRD=${MY_PR}.${DIST}
fi

K_PVF=${PV/_p*}-${K_PRD}
KDSUFFIX="_$(ver_cut 5)"

if [[ ${subrelease} ]]; then
	KVERREL=${K_PVF}${KDSUFFIX}.${_target_cpu}
	S=${WORKDIR}/kernel-${K_PVF}${KDSUFFIX}/linux-${K_PVF}.${_target_cpu}
else
	KVERREL=${K_PVF}.${_target_cpu}
	S=${WORKDIR}/kernel-${K_PVF}/linux-${K_PVF}.${_target_cpu}
fi

rhel-kernel-build_pkg_setup() {
    export make_target=bzImage
    export hdrarch=${_target_cpu}
    export asmarch=${_target_cpu}
    export image_install_path=boot
    export modsign_cmd="${WORKDIR}"/mod-sign.sh
    use gcov && export with_gcov=1
    use vdso && export with_vdso_install=1
    use ipaclones && ( use amd64 || use ppc64 ) && export kpatch_kcflags=-fdump-ipa-clones
    use debug && export debuginfodir=/usr/lib/debug

    	# released_kernel
	S10=${WORKDIR}/redhatsecurebootca3.cer
	S11=${WORKDIR}/redhatsecurebootca2.cer
	S12=${WORKDIR}/redhatsecureboot201.cer
	S13=${WORKDIR}/redhatsecureboot501.cer

	secureboot_ca_0=${S10}

	if use arm64 || use amd64; then
		secureboot_key_0=${S13}
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
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	export kernel_image=$(rhel-kernel_get_image_path)
	export all_arch_configs=${MY_P}-${_target_cpu}*.config

    if use realtime; then
        rttag='%%RTTAG%%'
        rtbuild='%%RTBUILD%%'
    fi
}

# @FUNCTION: rhel-kernel-build_src_configure
# @DESCRIPTION:
# Prepare the toolchain for building the kernel.
rhel-kernel-build_src_configure() {
	debug-print-function ${FUNCNAME} "${@}"

	# force ld.bfd if we can find it easily
	local LD="$(tc-getLD)"
	if type -P "${LD}.bfd" &>/dev/null; then
		LD+=.bfd
	fi

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
		STRIP=":"
		OBJCOPY="$(tc-getOBJCOPY)"
		OBJDUMP="$(tc-getOBJDUMP)"

		# we need to pass it to override colliding Gentoo envvar
		ARCH=`head -1 "configs/${MY_P}-${_target_cpu}.config" | cut -b 3-`
	)
}

# @FUNCTION: rhel-kernel-build_src_compile
# @DESCRIPTION:
# Compile the kernel sources.
rhel-kernel-build_src_compile() {
	debug-print-function ${FUNCNAME} "${@}"

	use debug && BuildKernel $make_target $kernel_image ${with_vdso_install:-0} debug

	use zfcpdump && BuildKernel $make_target $kernel_image ${with_vdso_install:-0} zfcpdump

	use up && BuildKernel $make_target $kernel_image ${with_vdso_install:-0}

    if use realtime; then
        # perf
        # make sure check-headers.sh is executable
        chmod +x tools/perf/check-headers.sh
        ${perf_make[@]} DESTDIR="${ED}" all
    fi

    if use tools; then
        if use arm64 || use amd64 || use ppc64; then
            # cpupower
            # make sure version-gen.sh is executable.
            chmod +x tools/power/cpupower/utils/version-gen.sh
            emake -C tools/power/cpupower CPUFREQ_BENCH=false DEBUG=false
            if use amd64; then
                pushd tools/power/cpupower/debug/x86_64
                emake centrino-decode powernow-k8-decode
                popd
                pushd tools/power/x86/x86_energy_perf_policy/
                emake
                popd
                pushd tools/power/x86/turbostat
                emake
                popd
                pushd tools/power/x86/intel-speed-select
                emake CFLAGS+="-D_GNU_SOURCE -Iinclude -I/usr/include/libnl3"
                popd
                pushd tools/arch/x86/intel_sdsi
                emake
                popd
            fi
        fi
        pushd tools/thermal/tmon/
        emake
        popd
        pushd tools/iio/
        emake
        popd
        pushd tools/gpio/
        emake
        popd
        # build VM tools
        pushd tools/vm/
        emake slabinfo page_owner_sort
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
# from rhel-kernel-install.eclass with the correct paths.
rhel-kernel-build_src_test() {
	debug-print-function ${FUNCNAME} "${@}"
	local targets=( modules_install )
	# on arm or arm64 you also need dtb
	if use arm || use arm64; then
		targets+=( dtbs_install )
	fi

	emake O="${WORKDIR}"/build "${MAKEARGS[@]}" \
		INSTALL_MOD_PATH="${T}" "${targets[@]}"

	local ver="${PV/_p*}${KV_LOCALVERSION}"
	kernel-install_test "${ver}" \
		"${WORKDIR}/build/$(dist-kernel_get_image_path)" \
		"${T}/lib/modules/${ver}"
}

# @FUNCTION: rhel-kernel-build_src_install
# @DESCRIPTION:
# Install the built kernel along with subset of sources
# Install the modules.
rhel-kernel-build_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	InstallKernel

    if use perf; then
        # perf tool binary and supporting scripts/binaries
        ${perf_make[@]} DESTDIR="${ED}" lib=${_lib} install-bin
        # remove the 'trace' symlink.
        rm -f "${ED}"${_bindir}/trace

        # remove examples
        rm -rf "${ED}"/usr/lib/examples/perf
        # remove the stray header file that somehow got packaged in examples
        rm -rf "${ED}"/usr/lib/include/perf/bpf/bpf.h

        # remove perf-bpf examples
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
    fi

    if use tools; then
        if use arm64 || use amd64 || use ppc64; then
            emake -C tools/power/cpupower DESTDIR="${ED}" libdir=${_libdir} mandir=${_mandir} CPUFREQ_BENCH=false install
            if use amd64; then
                pushd tools/power/cpupower/debug/x86_64
                dobin centrino-decode powernow-k8-decode
                popd
                dodir ${_mandir}/man8
                pushd tools/power/x86/x86_energy_perf_policy
                emake DESTDIR="${ED}" install
                popd
                pushd tools/power/x86/turbostat
                emake DESTDIR="${ED}" install
                popd
                pushd tools/power/x86/intel-speed-select
                emake CFLAGS+="-D_GNU_SOURCE -Iinclude -I/usr/include/libnl3" DESTDIR="${ED}" install
                popd
                pushd tools/arch/x86/intel_sdsi
                emake DESTDIR="${ED}" install
                popd
            fi
            fperms  0755 ${_libdir}/libcpupower.so*
            insinto ${_sysconfdir}/sysconfig
            newins "${WORKDIR}"/'cpupower.config' cpupower
            systemd_dounit "${WORKDIR}"/'cpupower.service'
        fi
        pushd tools/thermal/tmon
        emake INSTALL_ROOT="${ED}" install
        popd
        pushd tools/iio
        emake DESTDIR="${ED}" install
        popd
        pushd tools/gpio
        emake DESTDIR="${ED}" install
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

    if use signmodules; then
  	echo "**** signmodules. ****"
        use debug && ${modsign_cmd} certs/signing_key.pem.sign+debug certs/signing_key.x509.sign+debug "${ED}"/lib/modules/${KVERREL}+debug/
        use up && ${modsign_cmd} certs/signing_key.pem.sign certs/signing_key.x509.sign "${ED}"/lib/modules/${KVERREL}/
    fi

    if use zipmodules; then
   	echo "**** zipmodules. ****"
        find "${ED}"/lib/modules/ -type f -name '*.ko' | "${WORKDIR}"/parallel_xz.sh $MAKEOPTS;
	find "${ED}"/lib/modules/ -type f -name '*.ko' | xargs rm -f;
    fi
}

# @FUNCTION: rhel-kernel-build_pkg_postinst
# @DESCRIPTION:
# Combine postinst from kernel-install and savedconfig eclasses.
rhel-kernel-build_pkg_postinst() {
	rhel-kernel-install_pkg_postinst

	if [[ -d "/boot/efi/EFI/gentoo" ]]; then
	   if ! [[ -f /boot/efi/EFI/gentoo/grub.cfg ]]; then
		grub-mkconfig -o /boot/efi/EFI/gentoo/grub.cfg || die
	   fi
	elif [[ -d "/boot/grub" ]]; then
	   if ! [[ -f /boot/grub/grub.cfg ]]; then
		grub-mkconfig -o /boot/grub/grub.cfg || die
	   fi
	fi

	# savedconfig_pkg_postinst
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

	if [[ ${#user_configs[@]} -gt 0 ]]; then
		elog "User config files are being applied:"
		local x
		for x in "${user_configs[@]}"; do
			elog "- ${x}"
		done
	fi

	./scripts/kconfig/merge_config.sh -m -r \
		.config "${@}" "${user_configs[@]}" || die
}

_KERNEL_BUILD_ECLASS=1
fi

EXPORT_FUNCTIONS pkg_setup src_configure src_compile src_test src_install pkg_postinst
