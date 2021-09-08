# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic multilib multilib-minimal autotools pam java-pkg-opt-2 db-use systemd toolchain-funcs tmpfiles rhel8

SASLAUTHD_CONF_VER="2.1.26"

DESCRIPTION="The Cyrus SASL (Simple Authentication and Security Layer)"
HOMEPAGE="https://www.cyrusimap.org/sasl/"
#SRC_URI="ftp://ftp.cyrusimap.org/cyrus-sasl/${P}.tar.gz"
#SRC_URI="https://github.com/cyrusimap/${PN}/releases/download/${P}/${P}.tar.gz"

LICENSE="BSD-with-attribution"
SLOT="2"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="authdaemond berkdb gdbm kerberos ldapdb openldap mysql pam postgres sample selinux sqlite srp ssl static-libs urandom"

CDEPEND="
	net-mail/mailbase
	virtual/libcrypt:=
	authdaemond? ( || ( net-mail/courier-imap mail-mta/courier ) )
	berkdb? ( >=sys-libs/db-4.8.30-r1:=[${MULTILIB_USEDEP}] )
	gdbm? ( >=sys-libs/gdbm-1.10-r1:=[${MULTILIB_USEDEP}] )
	kerberos? ( >=virtual/krb5-0-r1[${MULTILIB_USEDEP}] )
	openldap? ( >=net-nds/openldap-2.4.38-r1[${MULTILIB_USEDEP}] )
	mysql? ( dev-db/mysql-connector-c:0=[${MULTILIB_USEDEP}] )
	pam? ( >=sys-libs/pam-0-r1[${MULTILIB_USEDEP}] )
	postgres? ( dev-db/postgresql:* )
	sqlite? ( >=dev-db/sqlite-3.8.2:3[${MULTILIB_USEDEP}] )
	ssl? (
		>=dev-libs/openssl-1.0.1h-r2:0=[${MULTILIB_USEDEP}]
	)
	java? ( >=virtual/jdk-1.6:= )"

REQUIRED_USE="ldapdb? ( openldap )"

RDEPEND="
	${CDEPEND}
	selinux? ( sec-policy/selinux-sasl )"

DEPEND="${CDEPEND}"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/sasl/md5global.h
)

PATCHES=(
	"${FILESDIR}/${PN}-2.1.27-avoid_pic_overwrite.patch"
	"${FILESDIR}/${PN}-2.1.27-autotools_fixes.patch"
	"${FILESDIR}/${PN}-2.1.27-as_needed.patch"
	"${FILESDIR}/${PN}-2.1.25-auxprop.patch"
	"${FILESDIR}/${PN}-2.1.27-gss_c_nt_hostbased_service.patch"
	"${FILESDIR}/${PN}-2.1.26-missing-size_t.patch"
	"${FILESDIR}/${PN}-2.1.27-doc_build_fix.patch"
	"${FILESDIR}/${PN}-2.1.27-memmem.patch"
	"${FILESDIR}/${PN}-2.1.27-slibtool.patch"
)

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	export NOCONFIGURE=yes
}

src_prepare() {
	default

	# reconfigure
	cp "${WORKDIR}"/autogen.sh ./
	rm configure aclocal.m4 config/ltmain.sh Makefile.in

	# Get rid of the -R switch (runpath_switch for Sun)
	# >=gcc-4.6 errors out with unknown option
	sed -i -e '/LIB_SQLITE.*-R/s/ -R[^"]*//' \
		configure.ac || die

	# Use plugindir for sasldir
	sed -i '/^sasldir =/s:=.*:= $(plugindir):' \
		"${S}"/plugins/Makefile.{am,in} || die "sed failed"

	# #486740 #468556
	sed -i -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:g' \
		-e 's:AC_CONFIG_MACRO_DIR:AC_CONFIG_MACRO_DIRS:g' \
		configure.ac || die

	eautoreconf

	export CC_FOR_BUILD="$(tc-getBUILD_CC)"
}

src_configure() {
	# Find Kerberos.
	krb5_prefix=`krb5-config --prefix`
	if test x$krb5_prefix = x${_prefix} ; then
		krb5_prefix=
	else
		CPPFLAGS="-I${krb5_prefix}/include $CPPFLAGS"; export CPPFLAGS
		LDFLAGS="-L${krb5_prefix}/${_lib} $LDFLAGS"; export LDFLAGS
	fi

	# Find OpenSSL.
	LIBS="-lcrypt"; export LIBS
	if pkg-config openssl ; then
		CPPFLAGS="`pkg-config --cflags-only-I openssl` $CPPFLAGS"; export CPPFLAGS
		LDFLAGS="`pkg-config --libs-only-L openssl` $LDFLAGS"; export LDFLAGS
	fi

	# Find the MySQL libraries used needed by the SQL auxprop plugin.
	INC_DIR="`mysql_config --include`"
	if test x"$INC_DIR" != "x-I${_includedir}"; then
		CPPFLAGS="$INC_DIR $CPPFLAGS"; export CPPFLAGS
	fi
	LIB_DIR="`mysql_config --libs | sed -e 's,-[^L][^ ]*,,g' -e 's,^ *,,' -e 's, *$,,' -e 's,  *, ,g'`"
	if test x"$LIB_DIR" != "x-L${_libdir}"; then
		LDFLAGS="$LIB_DIR $LDFLAGS"; export LDFLAGS
	fi

	# Find the PostgreSQL libraries used needed by the SQL auxprop plugin.
	INC_DIR="-I`pg_config --includedir`"
	if test x"$INC_DIR" != "x-I${_includedir}"; then
		CPPFLAGS="$INC_DIR $CPPFLAGS"; export CPPFLAGS
	fi

	# Patch config.sub to support ppc64p7 subarch (Fedora specific)
	# This is similar to what the config.sub from automake has
	for i in `find . -name config.sub`; do
	  perl -pi -e "s/ppc64-\*/ppc64-\* \| ppc64p7-\*/" $i
	done

	append-cflags -fPIC -pie -Wl,-z,relro -Wl,-z,now
	append-ldflags -pie -Wl,-z,now

	append-flags -fno-strict-aliasing

	if [[ ${CHOST} == *-solaris* ]] ; then
		# getpassphrase is defined in /usr/include/stdlib.h
		append-cppflags -DHAVE_GETPASSPHRASE
	else
		# this horrendously breaks things on Solaris
		append-cppflags -D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -DLDAP_DEPRECATED
		# replaces BSD_SOURCE (bug #579218)
		append-cppflags -D_DEFAULT_SOURCE
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	# Java support
	multilib_is_native_abi && use java && export JAVAC="${JAVAC} ${JAVACFLAGS}"

	local myeconfargs=(
		--enable-shared
		--with-rc4
		--enable-login
		--enable-ntlm
		--enable-auth-sasldb
		--disable-cmulocal
		--disable-krb4
		--disable-macos-framework
		--disable-otp
		--without-sqlite
		--without-pwcheck
		--with-saslauthd="${EPREFIX}"/run/saslauthd
		--with-configdir="${EPREFIX}"/etc/sasl2
		--with-plugindir="${EPREFIX}"/usr/$(get_libdir)/sasl2
		--with-dbpath="${EPREFIX}"/etc/sasl2/sasldb2
		--with-sphinx-build=no
		$(use_with ssl openssl)
		$(use_with pam)
		$(use_with openldap ldap)
		$(use_enable ldapdb)
		$(multilib_native_use_enable sample)
		$(use_enable kerberos gssapi)
		$(multilib_native_use_enable java)
		$(multilib_native_use_with mysql mysql "${EPREFIX}"/usr)
		$(multilib_native_use_with postgres pgsql "${EPREFIX}"/usr/$(get_libdir)/postgresql)
		$(use_with sqlite sqlite3 "${EPREFIX}"/usr/$(get_libdir))
		$(use_enable srp)
		$(use_enable static-libs static)

		# Add authdaemond support (bug #56523).
		$(usex authdaemond --with-authdaemond="${EPREFIX}"/var/lib/courier/authdaemon/socket '')

		# Fix for bug #59634.
		$(usex ssl '' --without-des)

		# Use /dev/urandom instead of /dev/random (bug #46038).
		$(usex urandom --with-devrandom=/dev/urandom '')
	)

	if use sqlite || { multilib_is_native_abi && { use mysql || use postgres; }; } ; then
		myeconfargs+=( --enable-sql )
	else
		myeconfargs+=( --disable-sql )
	fi

	# Default to GDBM if both 'gdbm' and 'berkdb' are present.
	if use gdbm ; then
		einfo "Building with GNU DB as database backend for your SASLdb"
		myeconfargs+=( --with-dblib=gdbm )
	elif use berkdb ; then
		einfo "Building with BerkeleyDB as database backend for your SASLdb"
		myeconfargs+=(
			--with-dblib=berkeley
			--with-bdb-incdir="$(db_includedir)"
		)
	else
		einfo "Building without SASLdb support"
		myeconfargs+=( --with-dblib=none )
	fi

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	emake sasldir="${EPREFIX}"/usr/$(get_libdir)/sasl2

	emake -C saslauthd testsaslauthd
	emake -C sample
	# Default location for java classes breaks OpenOffice (bug #60769).
	# Thanks to axxo@gentoo.org for the solution.
	if multilib_is_native_abi && use java ; then
		jar -cvf ${PN}.jar -C java $(find java -name "*.class")
	fi

	# Build a small program to list the available mechanisms, because I need it.
	pushd lib
	../libtool --mode=link gcc -o sasl2-shared-mechlist -I$S/include $CFLAGS "${WORKDIR}"/sasl-mechlist.c $LDFLAGS ./libsasl2.la
}

multilib_src_install() {
	emake install DESTDIR=${ED} sasldir="${EPREFIX}"/usr/$(get_libdir)/sasl2
	emake install DESTDIR=${ED} sasldir="${EPREFIX}"/usr/$(get_libdir)/sasl2 -C plugins

	# Provide an easy way to query the list of available mechanisms.
	dosbin lib/sasl2-shared-mechlist

	dodir /etc/sysconfig && insinto /etc/sysconfig/
	doins "${WORKDIR}"/saslauthd.sysconfig

	if multilib_is_native_abi; then
		if use sample ; then
			docinto sample
			dodoc "${S}"/sample/*.c
			exeinto /usr/share/doc/${P}/sample
			doexe sample/client sample/server
		fi

		# Default location for java classes breaks OpenOffice (bug #60769).
		if use java; then
			java-pkg_dojar ${PN}.jar
			java-pkg_regso "${ED}/usr/$(get_libdir)/libjavasasl$(get_libname)"
			# hackish, don't wanna dig through makefile
			rm -rf "${ED}/usr/$(get_libdir)/java" || die
			docinto "java"
			dodoc "${S}/java/README" "${FILESDIR}/java.README.gentoo" "${S}"/java/doc/*
			insinto "/usr/share/doc/${PF}/java/Test"
			doins "${S}"/java/Test/*.java
		fi

		dosbin saslauthd/testsaslauthd
	fi
}

multilib_src_install_all() {
	doman man/*

	keepdir /etc/sasl2

	# Reset docinto to default value (#674296)
	docinto
	dodoc AUTHORS ChangeLog doc/legacy/TODO
	newdoc pwcheck/README README.pwcheck

	newdoc docsrc/sasl/release-notes/$(ver_cut 1-2)/index.rst release-notes
	edos2unix "${ED}/usr/share/doc/${PF}/release-notes"

	docinto html
	dodoc doc/html/*.html

	if use pam; then
		newpamd "${FILESDIR}/saslauthd.pam-include" saslauthd
	fi

	newinitd "${FILESDIR}/pwcheck.rc6" pwcheck
	systemd_dounit "${FILESDIR}/pwcheck.service"

	newinitd "${FILESDIR}/saslauthd2.rc7" saslauthd
	newconfd "${FILESDIR}/saslauthd-${SASLAUTHD_CONF_VER}.conf" saslauthd
	systemd_dounit "${WORKDIR}"/saslauthd.service
	dotmpfiles "${FILESDIR}/${PN}.conf"

	# The get_modname bit is important: do not remove the .la files on
	# platforms where the lib isn't called .so for cyrus searches the .la to
	# figure out what the name is supposed to be instead
	if ! use static-libs && [[ $(get_modname) == .so ]] ; then
		find "${ED}" -name "*.la" -delete || die
	fi
}

pkg_postinst() {
	# Generate an empty sasldb2 with correct permissions.
	if ( use berkdb || use gdbm ) && [[ ! -f "${EROOT}/etc/sasl2/sasldb2" ]] ; then
		einfo "Generating an empty sasldb2 with correct permissions ..."
		echo "p" | "${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -p login \
			|| die "Failed to generate sasldb2"
		"${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -d login \
			|| die "Failed to delete temp user"
		chown root:mail "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chown ${EROOT}/etc/sasl2/sasldb2"
		chmod 0640 "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chmod ${EROOT}/etc/sasl2/sasldb2"
	fi

	if use authdaemond ; then
		elog "You need to add a user running a service using Courier's"
		elog "authdaemon to the 'mail' group. For example, do:"
		elog "	gpasswd -a postfix mail"
		elog "to add the 'postfix' user to the 'mail' group."
	fi

	elog "pwcheck and saslauthd home directories have moved to:"
	elog "  /run/saslauthd, using tmpfiles.d"
}
