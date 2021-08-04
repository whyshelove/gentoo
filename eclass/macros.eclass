# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: macros.eclass

_fixperms="/bin/chmod -Rf a+rX,u+w,g-w,o-w"

_rpmconfigdir=/usr/lib/rpm
rpmmacrodir=${_rpmconfigdir}/macros.d
rpmluadir=${_rpmconfigdir}/lua
rubygems_dir=${_datadir}/rubygems

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

systemd_post(){
	if [ $1 -eq 1 ] ; then 
		# Initial installation 
		systemctl --no-reload preset  &>/dev/null
	fi 
}

systemd_preun(){
	if [ $1 -eq 0 ] ; then 
		# Package removal, not upgrade 
		systemctl --no-reload disable --now  &>/dev/null
	fi
}

systemd_postun_with_restart(){
	if [ $1 -ge 1 ] ; then 
		# Package upgrade, not uninstall 
		systemctl try-restart  &>/dev/null
	fi 
}

systemd_user_post(){
	if [ $1 -eq 1 ] ; then 
		# Initial installation 
		systemctl --no-reload preset \--global  &>/dev/null
	fi 
}
