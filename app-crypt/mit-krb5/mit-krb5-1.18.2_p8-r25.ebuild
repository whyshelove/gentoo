# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

suffix_ver=$(ver_cut 5)
[[ ${suffix_ver} ]] && DSUFFIX="_${suffix_ver}"

PYTHON_COMPAT=( python3_{6,8,9} )
inherit autotools flag-o-matic python-any-r1 systemd toolchain-funcs rhel8

#MY_P="${P/mit-}"
P_DIR=$(ver_cut 1-2)
DESCRIPTION="MIT Kerberos V"
HOMEPAGE="https://web.mit.edu/kerberos/www/"

LICENSE="openafs-krb5-a BSD MIT OPENLDAP BSD-2 HPND BSD-4 ISC RSA CC-BY-SA-3.0 || ( BSD-2 GPL-2+ )"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
IUSE="cpu_flags_x86_aes doc keyutils lmdb nls openldap +pkinit selinux threads test xinetd"

# Test suite requires network access
RESTRICT="test"

DEPEND="
	!!app-crypt/heimdal
	>=sys-libs/e2fsprogs-libs-1.42.9
	|| (
		>=dev-libs/libverto-0.2.5[libev]
		>=dev-libs/libverto-0.2.5[libevent]
		>=dev-libs/libverto-0.2.5[tevent]
	)
	keyutils? ( >=sys-apps/keyutils-1.5.8:= )
	lmdb? ( dev-db/lmdb )
	nls? ( sys-devel/gettext )
	openldap? ( >=net-nds/openldap-2.4.38-r1 )
	pkinit? (
		>=dev-libs/openssl-1.0.1h-r2:0=
	)
	xinetd? ( sys-apps/xinetd )
	"
BDEPEND="
	${PYTHON_DEPS}
	virtual/yacc
	cpu_flags_x86_aes? (
		amd64? ( dev-lang/yasm )
		x86? ( dev-lang/yasm )
	)
	doc? ( virtual/latex-base )
	test? (
		${PYTHON_DEPS}
		dev-lang/tcl:0
		dev-util/dejagnu
		dev-util/cmocka
	)"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-kerberos )"

#S=${WORKDIR}/${MY_P}/src

CHOST_TOOLS=(
	/usr/bin/krb5-config
)

PATCHES=(
	"${FILESDIR}/${PN}-1.12_warn_cflags.patch"
	"${FILESDIR}/${PN}-config_LDFLAGS-r1.patch"
	"${FILESDIR}/${PN}_dont_create_run.patch"
)

src_prepare() {
	default
	# Make sure we always use the system copies.
	rm -rf util/{et,ss,verto}
	sed -i 's:^[[:space:]]*util/verto$::' configure.ac || die

	eautoreconf

}

src_configure() {
	# Go ahead and supply tcl info, because configure doesn't know how to find it.
	source ${_libdir}/tclConfig.sh

	# Work out the CFLAGS and CPPFLAGS which we intend to use.
	INCLUDES=-I/usr/include/et
	CFLAGS="$CFLAGS $DEFINES $INCLUDES"
	CPPFLAGS="$DEFINES $INCLUDES"
	append-cflags -fPIC -fstack-protector-all

	# QA
	append-flags -fno-strict-aliasing 
	append-flags -fno-strict-overflow

	ECONF_SOURCE=${S} \
	econf \
		$(use_with openldap ldap) \
		$(use_enable nls) \
		$(use_enable threads thread-support) \
		$(use_with lmdb) \
		$(use_with keyutils) \
		SS_LIB="-lss" \
		--localstatedir=${_var}/kerberos \
		--without-krb5-config \
		--with-netlib=-lresolv \
		--with-tcl \
		--enable-dns-for-realm \
		--with-dirsrv-account-locking \
		--with-crypto-impl=openssl \
		--with-pkinit-crypto-impl=openssl \
		--with-tls-impl=openssl \
		--with-pam \
		--with-prng-alg=os \
		--with-system-verto \
		--without-hesiod \
		--enable-shared \
		--with-system-et \
		--with-system-ss \
		--disable-rpath \
		\
		AR="$(tc-getAR)"
}

src_compile() {
	emake -j1
}

src_test() {
	emake -j1 check
}

src_install() {
	emake \
		DESTDIR="${D}" \
		EXAMPLEDIR="${EPREFIX}/usr/share/doc/${PF}/examples" \
		install

	# default database dir
	keepdir /var/lib/krb5kdc

	cd ..
	dodoc README

	if use doc; then
		dodoc -r doc/html
		docinto pdf
		dodoc doc/pdf/*.pdf
	fi

	newinitd "${FILESDIR}"/mit-krb5kadmind.initd-r2 mit-krb5kadmind
	newinitd "${FILESDIR}"/mit-krb5kdc.initd-r2 mit-krb5kdc
	newinitd "${FILESDIR}"/mit-krb5kpropd.initd-r2 mit-krb5kpropd
	newconfd "${FILESDIR}"/mit-krb5kadmind.confd mit-krb5kadmind
	newconfd "${FILESDIR}"/mit-krb5kdc.confd mit-krb5kdc
	newconfd "${FILESDIR}"/mit-krb5kpropd.confd mit-krb5kpropd

	systemd_newunit "${FILESDIR}"/mit-krb5kadmind.service mit-krb5kadmind.service
	systemd_newunit "${FILESDIR}"/mit-krb5kdc.service mit-krb5kdc.service
	systemd_newunit "${FILESDIR}"/mit-krb5kpropd.service mit-krb5kpropd.service
	systemd_newunit "${FILESDIR}"/mit-krb5kpropd_at.service "mit-krb5kpropd@.service"
	systemd_newunit "${FILESDIR}"/mit-krb5kpropd.socket mit-krb5kpropd.socket

	insinto /etc
	newins "${ED}/usr/share/doc/${PF}/examples/krb5.conf" krb5.conf.example
	insinto /var/lib/krb5kdc
	newins "${ED}/usr/share/doc/${PF}/examples/kdc.conf" kdc.conf.example

	if use openldap ; then
		insinto /etc/openldap/schema
		doins "${S}/plugins/kdb/ldap/libkdb_ldap/kerberos.schema"
	fi

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}/kpropd.xinetd" kpropd
	fi
}
