# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal rhel9-a

DESCRIPTION="Library for handling paper characteristics"
HOMEPAGE="https://packages.debian.org/unstable/source/libpaper"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DOCS=( README ChangeLog debian/changelog )

src_prepare() {
	sed -e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" -i configure.ac || die
	eautoreconf
	default
}

multilib_src_configure() {
	ECONF_SOURCE="${S}"	econf \
		--disable-static
}

multilib_src_install_all() {
	find "${ED}" -name '*.la' -exec rm -f {} +

	einstalldocs

	dodir ${_sysconfdir}/libpaper.d
	echo '# Simply write the paper name. See papersize(5) for possible values' > ${ED}${_sysconfdir}/papersize \
	|| die "papersize config failed"

	for i in cs da de es fr gl hu it ja nl pt_BR sv tr uk vi; do
		dodir ${_datadir}/locale/$i/LC_MESSAGES/;
		msgfmt debian/po/$i.po -o ${ED}${_datadir}/locale/$i/LC_MESSAGES/${PN}.mo;
	done
		
	if ! has_version app-text/libpaper ; then
		echo
		elog "run e.g. \"paperconfig -p letter\" as root to use letter-pagesizes"
		echo
	fi
}
