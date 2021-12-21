# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit pam rhel9

if [[ ${PV} == *8888 ]]; then
	inherit autotools
else
	KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
fi

DESCRIPTION="Keyboard and console utilities"
HOMEPAGE="http://kbd-project.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="nls pam test"
#RESTRICT="!test? ( test )"
# Upstream has strange assumptions how to run tests (see bug #732868)
RESTRICT="test"

RDEPEND="
	app-arch/gzip
	pam? (
		!app-misc/vlock
		sys-libs/pam
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	test? ( dev-libs/check )
"

src_prepare() {
	default
	if [[ ${PV} == "9999" ]] || [[ $(ver_cut 3) -ge 90 ]] ; then
		eautoreconf
	fi
}

src_configure() {
	local myeconfargs=(
		# USE="test" installs .a files
		--disable-static
		$(use_enable nls)
		$(use_enable pam vlock)
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	docinto html
	dodoc docs/doc/*.html

	# ro_win.map.gz is useless
	rm -f ${D}${_exec_prefix}/lib/kbd/keymaps/i386/qwerty/ro_win.map.gz

	# Some microoptimization
	sed -i -e 's,\<kbd_mode\>,${_bindir}/kbd_mode,g;s,\<setfont\>,${_bindir}/setfont,g' \
		${D}${_bindir}/unicode_start

	# Install PAM configuration for vlock
	dodir ${_sysconfdir}/pam.d
	insinto ${_sysconfdir}/pam.d/
	newins ${WORKDIR}/vlock.pamd vlock

	# USE="test" installs .la files
	find "${ED}" -type f -name "*.la" -delete || die
}
