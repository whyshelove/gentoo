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

__global_compiler_flags="-g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches ${_hardened_cflags} ${_annotated_cflags}"

optflags="${__global_compiler_flags} -fasynchronous-unwind-tables -fstack-clash-protection"
[[ $(tc-arch) == "amd64" ]] && optflags+=" -m64 -fcf-protection"

fflags="-I/usr/lib64/gfortran/modules"

_fixperms="/bin/chmod -Rf a+rX,u+w,g-w,o-w"

_rpmconfigdir=/usr/lib/rpm
rpmmacrodir=${_rpmconfigdir}/macros.d
_rpmmacrodir=${_rpmconfigdir}/macros.d
rpmluadir=${_rpmconfigdir}/lua
rpm_macros_dir=$(d=${rpmmacrodir}; [ -d $d ] || d=${_sysconfdir}/rpm; echo $d)

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
_udevrulesdir=/lib/udev/rules.d

rubygems_dir=${_datadir}/rubygems

build_cflags(){
	append-cflags ${optflags} "$@"

	return 0
}

build_cxxflags(){
	append-cxxflags ${optflags} "$@"

	return 0
}

build_ldflags(){
	append-ldflags '-Wl,-z,relro' ${_ld_symbols_flags} ${_hardened_ldflags} "$@"

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
		rpm | tree | keyutils | nvme-cli | pciutils | dmidecode | efibootmgr | os-prober | binutils* \
		| gdb | libsepol | libutempter | crash | ninja | trace-cmd | ipcalc) build_cflags; build_ldflags ;;
		efivar ) build_cflags -flto; build_ldflags -flto ;;
		boost ) OPT_FLAGS="-fno-strict-aliasing -Wno-unused-local-typedefs -Wno-deprecated-declarations"
			build_cflags $OPT_FLAGS; build_cxxflags $OPT_FLAGS; build_ldflags ;;
		shadow) build_cflags -fpie; build_ldflags -pie  '-Wl,-z,now' ;;
		lmdb | zlib ) build_ldflags ;;
		gdb ) build_cxxflags ;;
		squashfs-tools | numactl ) build_cflags ;;
		liburing | libcap | dos2unix | pesign )  ;;
		*) set_build_flags ;;
	esac

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

# @FUNCTION: get_arch
# @DESCRIPTION:
get_arch() {
	debug-print-function ${FUNCNAME} "${@}"

	case ${ARCH} in
		amd64)
			echo x86_64
			;;
		x86)
			echo i386
			;;
		arm|ppc|ppc64|riscv|sparc|sparc64)
			echo ${ARCH}
		;;
		arm64)
			echo aarch64
			;;
		*)
			die "${FUNCNAME}: unsupported ARCH=${ARCH}"
			;;
	esac
}

_pesign() {
	_pesign_cert='Red Hat Test Certificate'
	_pesign_nssdir="/etc/pki/pesign-rh-test"

	/usr/bin/pesign -c "${_pesign_cert}" \
		--certdir ${_pesign_nssdir} -i ${1} -o ${2} -s || die
			
  if [ ! -s -o ${2} ]; then
    if [ -e "${2}" ]; then
      rm -f ${2}
    fi
    exit 1
  fi		
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
