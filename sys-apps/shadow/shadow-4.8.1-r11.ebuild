# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic rhel

DESCRIPTION="Utilities to deal with user accounts"
HOMEPAGE="https://github.com/shadow-maint/shadow"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="acl bcrypt cracklib nls selinux skey split-usr +su xattr"
# Taken from the man/Makefile.am file.
LANGS=( cs da de es fi fr hu id it ja ko pl pt_BR ru sv tr zh_CN zh_TW )

REQUIRED_USE="?? ( cracklib )"

BDEPEND="
	app-arch/xz-utils
	sys-devel/gettext
"
COMMON_DEPEND="
	virtual/libcrypt:=
	acl? ( sys-apps/acl:0= )
	>=sys-process/audit-2.6:0=
	cracklib? ( >=sys-libs/cracklib-2.7-r3:0= )
	nls? ( virtual/libintl )
	skey? ( sys-auth/skey:0= )
	selinux? (
		>=sys-libs/libselinux-1.28:0=
		sys-libs/libsemanage:0=
	)
	xattr? ( sys-apps/attr:0= )
"
DEPEND="${COMMON_DEPEND}
	dev-util/itstool
	>=sys-kernel/linux-headers-4.14
"
RDEPEND="${COMMON_DEPEND}
	su? ( !sys-apps/util-linux[su(-)] )
"

src_prepare() {
	default
	eautoreconf
	#elibtoolize
}

src_configure() {
	append-cflags -fpie
	export LDFLAGS="-pie -Wl,-z,relro -Wl,-z,now"
	local myeconfargs=(
		--disable-account-tools-setuid
		--enable-shared
     		--enable-shadowgrp
		--enable-man
		--with-audit
		--with-sha-crypt
		--with-btrfs
	        --with-group-name-max-length=32
		--without-tcb
		--without-libpam
		$(use_enable nls)
		$(use_with acl)
		$(use_with bcrypt)
		$(use_with cracklib libcrack)
		$(use_with elibc_glibc nscd)
		$(use_with selinux)
		$(use_with skey)
		$(use_with su)
		$(use_with xattr attr)
	)
	econf "${myeconfargs[@]}"

	has_version 'sys-libs/uclibc[-rpc]' && sed -i '/RLOGIN/d' config.h #425052

	if use nls ; then
		local l langs="po" # These are the pot files.
		for l in ${LANGS[*]} ; do
			has ${l} ${LINGUAS-${l}} && langs+=" ${l}"
		done
		sed -i "/^SUBDIRS = /s:=.*:= ${langs}:" man/Makefile || die
	fi
}

set_login_opt() {
	local comment="" opt=${1} val=${2}
	if [[ -z ${val} ]]; then
		comment="#"
		sed -i \
			-e "/^${opt}\>/s:^:#:" \
			"${ED}"/etc/login.defs || die
	else
		sed -i -r \
			-e "/^#?${opt}\>/s:.*:${opt} ${val}:" \
			"${ED}"/etc/login.defs
	fi
	local res=$(grep "^${comment}${opt}\>" "${ED}"/etc/login.defs)
	einfo "${res:-Unable to find ${opt} in /etc/login.defs}"
}

src_install() {
	emake DESTDIR="${D}" suidperms=4711 gnulocaledir="${D}"${_datadir}/locale MKINSTALLDIRS=`pwd`/mkinstalldirs install

	# Remove libshadow and libmisc; see bug 37725 and the following
	# comment from shadow's README.linux:
	#   Currently, libshadow.a is for internal use only, so if you see
	#   -lshadow in a Makefile of some other package, it is safe to
	#   remove it.
	rm -f "${ED}"/{,usr/}$(get_libdir)/lib{misc,shadow}.{a,la}

	insinto /etc
	newins ${WORKDIR}/shadow-utils.login.defs login.defs

	insopts -m0600
	doins etc/login.access etc/limits

	# needed for 'useradd -D'
	insinto /etc/default
	insopts -m0600
	newins ${WORKDIR}/shadow-utils.useradd useradd

	if use split-usr ; then
		# move passwd to / to help recover broke systems #64441
		# We cannot simply remove this or else net-misc/scponly
		# and other tools will break because of hardcoded passwd
		# location
		dodir /bin
		mv "${ED}"/usr/bin/passwd "${ED}"/bin/ || die
		dosym ../../bin/passwd /usr/bin/passwd
	fi

	dodir ${_includedir}/shadow
	insinto ${_includedir}/shadow && doins libsubid/subid.h

	dosym useradd ${_sbindir}/adduser

	set_login_opt CREATE_HOME yes
	set_login_opt MAIL_CHECK_ENAB no
	set_login_opt SU_WHEEL_ONLY yes
	set_login_opt CRACKLIB_DICTPATH /usr/lib/cracklib_dict
	set_login_opt LOGIN_RETRIES 3
	set_login_opt ENCRYPT_METHOD SHA512

	# Remove manpages that are handled by other packages
	find "${ED}"/usr/share/man \
		'(' -name id.1 -o -name passwd.5 -o -name getspnam.3 ')' \
		-delete

	cd "${S}" || die
	dodoc ChangeLog NEWS TODO
	newdoc README README.download
	cd doc || die
	dodoc HOWTO README* WISHLIST *.txt

	# Remove binaries we don't use.
	rm ${ED}${_bindir}/chfn
	rm ${ED}${_bindir}/chsh
	rm ${ED}${_bindir}/expiry
	rm ${ED}${_bindir}/passwd
	rm ${ED}${_bindir}/faillog
	rm ${ED}${_sysconfdir}/login.access
	rm ${ED}${_sysconfdir}/limits
	rm ${ED}${_sbindir}/logoutd
	rm ${ED}${_mandir}/man1/chfn.*
	rm ${ED}${_mandir}/*/man1/chfn.*
	rm ${ED}${_mandir}/man1/chsh.*
	rm ${ED}${_mandir}/*/man1/chsh.*
	rm ${ED}${_mandir}/man1/expiry.*
	rm ${ED}${_mandir}/*/man1/expiry.*
	rm ${ED}${_mandir}/man1/groups.*
	rm ${ED}${_mandir}/*/man1/groups.*
	rm ${ED}${_mandir}/man1/login.*
	rm ${ED}${_mandir}/*/man1/login.*
	rm ${ED}${_mandir}/man1/passwd.*
	rm ${ED}${_mandir}/*/man1/passwd.*
	rm ${ED}${_mandir}/man1/su.*
	rm ${ED}${_mandir}/*/man1/su.*
	rm ${ED}${_mandir}/man5/limits.*
	rm ${ED}${_mandir}/*/man5/limits.*
	rm ${ED}${_mandir}/man5/login.access.*
	rm ${ED}${_mandir}/*/man5/login.access.*
	rm ${ED}${_mandir}/man5/porttime.*
	rm ${ED}${_mandir}/*/man5/porttime.*
	rm ${ED}${_mandir}/man5/suauth.*
	rm ${ED}${_mandir}/*/man5/suauth.*
	rm ${ED}${_mandir}/man8/logoutd.*
	rm ${ED}${_mandir}/*/man8/logoutd.*
	rm ${ED}${_mandir}/man8/nologin.*
	rm ${ED}${_mandir}/*/man8/nologin.*
	rm ${ED}${_mandir}/man5/faillog.*
	rm ${ED}${_mandir}/*/man5/faillog.*
	rm ${ED}${_mandir}/man8/faillog.*
	rm ${ED}${_mandir}/*/man8/faillog.*
}

pkg_preinst() {
	rm -f "${EROOT}"/etc/pam.d/system-auth.new \
		"${EROOT}/etc/login.defs.new"
}

pkg_postinst() {
	# Enable shadow groups.
	if [ ! -f "${EROOT}"/etc/gshadow ] ; then
		if grpck -r -R "${EROOT}" 2>/dev/null ; then
			grpconv -R "${EROOT}"
		else
			ewarn "Running 'grpck' returned errors.  Please run it by hand, and then"
			ewarn "run 'grpconv' afterwards!"
		fi
	fi

	[[ ! -f "${EROOT}"/etc/subgid ]] &&
		touch "${EROOT}"/etc/subgid
	[[ ! -f "${EROOT}"/etc/subuid ]] &&
		touch "${EROOT}"/etc/subuid

	einfo "The 'adduser' symlink to 'useradd' has been dropped."
}
