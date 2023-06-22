# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit pam toolchain-funcs rhel8

DESCRIPTION="passwd - An utility for setting or changing passwords using PAM"
HOMEPAGE="https://pagure.io/passwd"

LICENSE="BSD or GPL+"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="+audit +selinux"
RDEPEND="${DEPEND}"
DEPEND="dev-libs/glib
	dev-libs/popt
	sys-devel/gettext
	>=sys-libs/pam-1.0.90
	audit? ( >=sys-process/audit-1.0.14 )
	selinux? ( >=sys-libs/libselinux-2.1.6 )
"

src_configure() {
	econf 	$(use_with selinux) \
		$(use_with audit) 
}

src_install() {
	default

	insopts -m0755
	insinto ${_sysconfdir}/pam.d
	newins passwd.pamd passwd

	fowners root:root ${_bindir}/passwd
	fperms 4755 ${_bindir}/passwd 

	dodoc AUTHORS ChangeLog NEWS
}
