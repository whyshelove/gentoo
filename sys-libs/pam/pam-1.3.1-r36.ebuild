# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DSUFFIX="_10"
inherit autotools db-use fcaps multilib-minimal toolchain-funcs usr-ldscript rhel8

DESCRIPTION="Linux-PAM (Pluggable Authentication Modules)"
HOMEPAGE="https://github.com/linux-pam/linux-pam"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~amd64-linux ~x86-linux"
IUSE="audit berkdb cracklib debug nis +pie selinux static-libs"

BDEPEND="app-text/docbook-xml-dtd:4.1.2
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xml-dtd:4.4
	app-text/docbook-xml-dtd:4.5
	dev-libs/libxslt
	sys-devel/flex
	sys-devel/gettext
	virtual/pkgconfig[${MULTILIB_USEDEP}]"

DEPEND="
	virtual/libcrypt:=[${MULTILIB_USEDEP}]
	>=virtual/libintl-0-r1[${MULTILIB_USEDEP}]
	audit? ( >=sys-process/audit-2.2.2[${MULTILIB_USEDEP}] )
	berkdb? ( >=sys-libs/db-4.8.30-r1:=[${MULTILIB_USEDEP}] )
	cracklib? ( >=sys-libs/cracklib-2.9.1-r1[${MULTILIB_USEDEP}] )
	selinux? ( >=sys-libs/libselinux-2.2.2-r4[${MULTILIB_USEDEP}] )
	nis? ( >=net-libs/libtirpc-0.2.4-r2[${MULTILIB_USEDEP}] )"

RDEPEND="${DEPEND}
	dev-libs/libpwquality"

PDEPEND="sys-auth/pambase"

S="${WORKDIR}/Linux-PAM-${PV}"

src_prepare() {
	default
	eapply "${FILESDIR}/${PN}-remove-browsers.patch"
	touch ChangeLog || die
	eautoreconf
}

multilib_src_configure() {
	# Do not let user's BROWSER setting mess us up. #549684
	unset BROWSER

	# Disable automatic detection of libxcrypt; we _don't_ want the
	# user to link libxcrypt in by default, since we won't track the
	# dependency and allow to break PAM this way.

	export ac_cv_header_xcrypt_h=no

	local myconf=(
		--with-db-uniquename=-$(db_findver sys-libs/db)
		--enable-securedir="${EPREFIX}"/$(get_libdir)/security
		--libdir=/usr/$(get_libdir)
		--disable-prelude
		--disable-rpath
		$(use_enable audit)
		$(use_enable berkdb db)
		$(use_enable cracklib)
		$(use_enable debug)
		$(use_enable nis)
		$(use_enable pie)
		$(use_enable static-libs static)
		$(use_enable selinux)
		--enable-isadir='.' #464016
		)
	ECONF_SOURCE="${S}" econf ${myconf[@]}
}

multilib_src_compile() {
	MAKEOPTS="-j1"

	emake -C po update-gmo
	emake sepermitlockdir="${EPREFIX}/run/sepermit"
}

multilib_src_install() {
	emake DESTDIR="${D}" install \
		sepermitlockdir="${EPREFIX}/run/sepermit"

	rm -rf ${D}${_datadir}/doc/Linux-PAM

	keepdir /var/run/console /var/run
	_moduledir="${EPREFIX}"/$(get_libdir)/security
	_pamconfdir=${_sysconfdir}/pam.d
	_pamvendordir=${_datadir}/pam.d

	# Install default configuration files.
	diropts -m 0755 && dodir ${_pamconfdir} ${_pamvendordir} ${_sysconfdir}/motd.d /usr/lib/motd.d ${_moduledir}
	insinto ${_pamconfdir}/

	for pamconf in other system-auth password-auth fingerprint-auth smartcard-auth config-util postlogin ; do
		newins "${WORKDIR}"/${pamconf}.pamd ${pamconf}
	done
	
	insopts -m0600
	newins /dev/null opasswd

	# Temporary compat link
	use selinux && dosym ${_moduledir}/pam_sepermit.so ${_moduledir}/pam_selinux_permit.so

	for phase in auth acct passwd session ; do
		dosym ${_moduledir}/pam_unix.so ${_moduledir}/pam_unix_${phase}.so 
	done

	# Install the file for autocreation of /var/run subdirectories on boot
	insinto ${_prefix}/lib/tmpfiles.d/
	newins "${WORKDIR}"/pamtmp.conf pam.conf

	fperms 4755 /sbin/pam_timestamp_check
	fperms 4755 /sbin/unix_chkpwd

	gen_usr_ldscript -a pam pam_misc pamc
}

multilib_src_install_all() {
	mkdir -p doc/txts
	for readme in modules/pam_*/README ; do
		cp -f ${readme} doc/txts/README.`dirname ${readme} | sed -e 's|^modules/||'`
	done

	rm -rf doc/txts/README.pam_tally*
	rm -rf doc/sag/html/*pam_tally*

	find "${ED}" -type f -name '*.la' -delete || die

	# Duplicate doc file sets.
	rm -fr ${D}/usr/share/doc/pam

	# tmpfiles.eclass is impossible to use because
	# there is the pam -> tmpfiles -> systemd -> pam dependency loop

	dodir /usr/lib/tmpfiles.d

	cat ->>  "${D}"/usr/lib/tmpfiles.d/${CATEGORY}-${PN}.conf <<-_EOF_
		d /run/faillock 0755 root root
	_EOF_
	use selinux && cat ->>  "${D}"/usr/lib/tmpfiles.d/${CATEGORY}-${PN}-selinux.conf <<-_EOF_
		d /run/sepermit 0755 root root
	_EOF_

	local page

	for page in doc/man/*.{3,5,8} modules/*/*.{5,8} ; do
		doman ${page}
	done
}

pkg_postinst() {
	ewarn "Some software with pre-loaded PAM libraries might experience"
	ewarn "warnings or failures related to missing symbols and/or versions"
	ewarn "after any update. While unfortunate this is a limit of the"
	ewarn "implementation of PAM and the software, and it requires you to"
	ewarn "restart the software manually after the update."
	ewarn ""
	ewarn "You can get a list of such software running a command like"
	ewarn "  lsof / | egrep -i 'del.*libpam\\.so'"
	ewarn ""
	ewarn "Alternatively, simply reboot your system."

	# The pam_unix module needs to check the password of the user which requires
	# read access to /etc/shadow only.
	fcaps cap_dac_override sbin/unix_chkpwd
}
