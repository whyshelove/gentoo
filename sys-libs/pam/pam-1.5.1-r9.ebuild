# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Avoid QA warnings
# Can reconsider w/ EAPI 8 and IDEPEND, bug #810979
TMPFILES_OPTIONAL=1

inherit autotools db-use fcaps flag-o-matic toolchain-funcs usr-ldscript multilib-minimal rhel9

MY_P="Linux-${PN^^}-${PV}"
DESCRIPTION="Linux-PAM (Pluggable Authentication Modules)"
HOMEPAGE="https://github.com/linux-pam/linux-pam"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"
IUSE="audit berkdb debug nis selinux"

BDEPEND="
	dev-libs/libxslt
	sys-devel/flex
	sys-devel/gettext
	virtual/pkgconfig
	app-alternatives/yacc
"

DEPEND="
	virtual/libcrypt:=[${MULTILIB_USEDEP}]
	>=virtual/libintl-0-r1[${MULTILIB_USEDEP}]
	audit? ( >=sys-process/audit-2.2.2[${MULTILIB_USEDEP}] )
	berkdb? ( >=sys-libs/db-4.8.30-r1:=[${MULTILIB_USEDEP}] )
	selinux? ( >=sys-libs/libselinux-2.2.2-r4[${MULTILIB_USEDEP}] )
	nis? ( net-libs/libnsl:=[${MULTILIB_USEDEP}]
	>=net-libs/libtirpc-0.2.4-r2:=[${MULTILIB_USEDEP}] )"

RDEPEND="${DEPEND}"

PDEPEND=">=sys-auth/pambase-20200616"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.5.1-musl.patch
	"${FILESDIR}"/${PN}-1.5.2-clang-15-configure-implicit-func.patch
)

src_prepare() {
	default
	touch ChangeLog || die
	eautoreconf
}

multilib_src_configure() {
	# Do not let user's BROWSER setting mess us up. #549684
	unset BROWSER

	# This whole weird has_version libxcrypt block can go once
	# musl systems have libxcrypt[system] if we ever make
	# that mandatory. See bug #867991.
	if use elibc_musl && ! has_version sys-libs/libxcrypt[system] ; then
		# Avoid picking up symbol-versioned compat symbol on musl systems
		export ac_cv_search_crypt_gensalt_rn=no

		# Need to avoid picking up the libxcrypt headers which define
		# CRYPT_GENSALT_IMPLEMENTS_AUTO_ENTROPY.
		cp "${ESYSROOT}"/usr/include/crypt.h "${T}"/crypt.h || die
		append-cppflags -I"${T}"
	fi

	local myconf=(
		CC_FOR_BUILD="$(tc-getBUILD_CC)"
		--with-db-uniquename=-$(db_findver sys-libs/db)
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog
		--enable-securedir="${EPREFIX}"/$(get_libdir)/security
		--includedir="${EPREFIX}"/usr/include/security
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		--enable-pie
		--enable-unix
		--disable-prelude
		--disable-doc
		--disable-regenerate-docu
		--disable-static
		--disable-Werror
		--disable-rpath
		--enable-vendordir="${EPREFIX}"${_datadir}
		$(use_enable audit)
		$(use_enable berkdb db)
		$(use_enable debug)
		$(use_enable nis)
		$(use_enable selinux)
		--enable-isadir='.' #464016
		)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_compile() {
	MAKEOPTS="-j1"

	emake -C po update-gmo
	emake sepermitlockdir="/run/sepermit" LDCONFIG=:
}

multilib_src_install() {
	emake DESTDIR="${D}" install \
		sepermitlockdir="/run/sepermit"

	rm -rf ${D}${_datadir}/doc/Linux-PAM
	# Included in setup package
	#rm -f ${D}${_sysconfdir}/environment

	_moduledir="${EPREFIX}"/$(get_libdir)/security
	_pamconfdir=${_sysconfdir}/pam.d
	_pamvendordir=${_datadir}/pam.d

	#dosym ${_moduledir} ${_libdir}/security

	# Install default configuration files.
	diropts -m 0755 && dodir ${_pamvendordir} ${_sysconfdir}/motd.d /usr/lib/motd.d ${_moduledir}
	insinto ${_pamconfdir}

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
	#newtmpfiles "${WORKDIR}"/pamtmp.conf pam.conf

	gen_usr_ldscript -a pam pam_misc pamc
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete || die

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
	tmpfiles_process

	ewarn "Some software with pre-loaded PAM libraries might experience"
	ewarn "warnings or failures related to missing symbols and/or versions"
	ewarn "after any update. While unfortunate this is a limit of the"
	ewarn "implementation of PAM and the software, and it requires you to"
	ewarn "restart the software manually after the update."
	ewarn ""
	ewarn "You can get a list of such software running a command like"
	ewarn "  lsof / | grep -E -i 'del.*libpam\\.so'"
	ewarn ""
	ewarn "Alternatively, simply reboot your system."

	# The pam_unix module needs to check the password of the user which requires
	# read access to /etc/shadow only.
	fcaps cap_dac_override sbin/unix_chkpwd
}
