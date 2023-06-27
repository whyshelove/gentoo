# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: macros.eclass

inherit flag-o-matic

if [[ ${_hardened_build} != "undefine" ]]; then
	if [[ ${_strip_cflags} != "undefine" ]]; then
		_hardening_cflags="-specs=/usr/lib/rpm/redhat/redhat-hardened-cc1"
	fi

	if [[ ${_strip_ldflags} != "undefine" ]]; then
		_hardening_ldflags="-Wl,-z,now -specs=/usr/lib/rpm/redhat/redhat-hardened-ld"
	fi
fi

if [[ ${_annotated_build} != "undefine" ]]; then
	_annobin_cflags="-specs=/usr/lib/rpm/redhat/redhat-annobin-cc1"
fi

if [[ ${_strict_symbol_defs_build} == "enable" ]]; then
	_ld_symbols_flags="-Wl,-z,defs"
fi

_hardened_cflags="${_hardening_cflags}"
_hardened_ldflags="${_hardening_ldflags}"

_annotated_cflags="${_annobin_cflags}"

__global_compiler_flags="-O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS ${_hardened_cflags} -fstack-protector-strong ${_annotated_cflags}"

optflags="${__global_compiler_flags} -m64 -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection"

fflags="-I/usr/lib64/gfortran/modules"

_fixperms="/bin/chmod -Rf a+rX,u+w,g-w,o-w"

_rpmconfigdir=/usr/lib/rpm
rpmmacrodir=${_rpmconfigdir}/macros.d
_rpmmacrodir=${_rpmconfigdir}/macros.d
rpmluadir=${_rpmconfigdir}/lua
rpm_macros_dir=$(d=${_rpmconfigdir}/macros.d; [ -d $d ] || d=${_sysconfdir}/rpm; echo $d)

_usr=/usr
_var=/var
buildroot="${ED}"
RPM_BUILD_ROOT="${ED}"

_prefix=/usr
_exec_prefix=${_prefix}
_bindir=${_exec_prefix}/bin
_sbindir=${_exec_prefix}/sbin
_libexecdir=${_exec_prefix}/libexec
_datarootdir=${_prefix}/share
_datadir=${_datarootdir}
_docdir=${_datadir}/doc
_pkgdocdir=${_docdir}/${PN}
_sysconfdir=/etc
_sharedstatedir=/var/lib
_localstatedir=/var
_lib=lib64
_libdir=${_prefix}/lib64
_includedir=${_prefix}/include
_infodir=${_datarootdir}/info
_mandir=${_datarootdir}/man
_initddir=${_sysconfdir}/rc.d/init.d

_systemd_util_dir=${_prefix}/lib/systemd
_unitdir=${_prefix}/lib/systemd/system
_userunitdir=${_prefix}/lib/systemd/user
_presetdir=/lib/systemd/system-preset

build_cflags(){
	append-cflags ${optflags} "$@"

	return 0
}

build_cxxflags(){
	append-cxxflags ${optflags} "$@"

	return 0
}

build_ldflags(){
	append-ldflags '-Wl,-z,relro' ${_ld_symbols_flags} ${_hardened_ldflags} ${_annotated_cflags} "$@"

	return 0
}

set_build_flags(){
	[[ ${_build_flags} == "undefine" ]] && return 0
	append-flags ${optflags}
	append-fflags ${fflags}
	build_ldflags

	return 0
}

	case ${PN} in
		rpm | dmidecode | zstd | unzip | pigz | perl | tree | keyutils | nvme-cli | pciutils | dmidecode | efibootmgr | os-prober | binutils* \
		| nspr | nss | gdb | libsepol | libutempter | crash | ninja | trace-cmd | ipcalc) build_cflags; build_ldflags ;;
		efivar ) build_cflags -flto; build_ldflags -flto ;;
		boost ) OPT_FLAGS="-fno-strict-aliasing -Wno-unused-local-typedefs -Wno-deprecated-declarations"
			build_cflags $OPT_FLAGS; build_cxxflags $OPT_FLAGS; build_ldflags ;;
		shadow) build_cflags -fpie; build_ldflags -pie  '-Wl,-z,now' ;;
		dos2unix | zlib ) build_ldflags ;;
		squashfs-tools | openssh ) build_cflags ;;
		liburing | libcap )  ;;
		*) set_build_flags ;;
	esac

rubygems_dir=${_datadir}/rubygems

# @FUNCTION: get_efi_arch
get_efi_arch() {
	debug-print-function ${FUNCNAME} "${@}"

	case ${ARCH} in
		amd64)
			echo x64
			;;
		x86)
			echo ia32
			;;
		arm64)
			echo aa64
			;;
		*)
			die "${FUNCNAME}: unsupported ARCH=${ARCH}"
			;;
	esac
}

_pesign() {
	_pesign_cert='Red Hat Test Certificate'
	_target_cpu=$(get_efi_arch)

	${_libexecdir}/pesign/pesign-rpmbuild-helper \
	${_target_cpu} \
	"/usr/bin/pesign" \
	"/usr/bin/pesign-client" \
	--client-token "OpenSC Card (Fedora Signer)" \
	--cert "${_pesign_cert}" \
	--rhelver "9" \
	--rhelcert ${5} \
	--rhelcafile ${3} \
	--rhelcertfile ${4} \
	--in ${1} \
	--out ${2} \
	--sign || die
}

systemd_post(){
	# Initial installation 
	[[ $# -eq 0 ]] && set -- ${A}
	systemctl enable "$@"
}

systemd_preun(){
	# Package removal, not upgrade 
	[[ $# -eq 0 ]] && set -- ${A}
	systemctl disable "$@"
}

systemd_postun_with_restart(){
	# Package upgrade, not uninstall
	[[ $# -eq 0 ]] && set -- ${A} 
	systemctl restart "$@"
}

systemd_user_post(){
	# Initial installation 
	[[ $# -eq 0 ]] && set -- ${A}
	systemctl --user enable "$@"
}
