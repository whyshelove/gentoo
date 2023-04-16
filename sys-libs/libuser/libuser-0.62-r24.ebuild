# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,8,9} )

inherit pam autotools python-r1 multilib multilib-minimal linux-info toolchain-funcs rhel8

DESCRIPTION="libuser - A user and group account administration library"
HOMEPAGE="https://pagure.io/libuser"

LICENSE="BSD or GPL+"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="+ldap +audit test"
RESTRICT="test"
RDEPEND="${DEPEND}
	virtual/libcrypt"
DEPEND="dev-libs/glib
	dev-libs/popt
	sys-devel/gettext
	dev-libs/cyrus-sasl
	>=sys-libs/pam-1.0.90
	>=sys-libs/libselinux-2.1.6
	audit? ( >=sys-process/audit-1.0.14 )
	ldap? ( net-nds/openldap )
	test? ( dev-libs/openssl )
"
src_prepare() {
	default
	eautoreconf -if
}

multilib_src_configure() {
	local -a myeconfargs=(
		$(use_enable ldap)
		$(use_enable audit)
		--with-selinux
		PYTHON=${EPYTHON}
	)

	ECONF_SOURCE=${S} econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	dodoc AUTHORS NEWS README TODO docs/*.txt

	# remove la files
	find "${ED}" -name '*.la' -delete || die
}
