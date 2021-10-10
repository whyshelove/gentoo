# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs

DESCRIPTION="A window switcher, run dialog and dmenu replacement"
HOMEPAGE="https://github.com/davatorium/rofi"
SRC_URI="https://github.com/davatorium/rofi/releases/download/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+drun test +windowmode"
RESTRICT="!test? ( test )"

BDEPEND="virtual/pkgconfig"
RDEPEND="
	dev-libs/glib:2
	gnome-base/librsvg:2
	media-libs/freetype
	virtual/jpeg
	x11-libs/cairo[X,xcb(+)]
	x11-libs/libXft
	x11-libs/libXinerama
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/pango[X]
	x11-libs/startup-notification
	x11-libs/xcb-util
	x11-libs/xcb-util-wm
	x11-libs/xcb-util-xrm
"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto
	test? ( >=dev-libs/check-0.11 )
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	tc-export CC

	local myeconfargs=(
		$(use_enable drun)
		$(use_enable test check)
		$(use_enable windowmode)
	)
	econf "${myeconfargs[@]}"
}

pkg_postinst() {
	for v in ${REPLACING_VERSIONS}; do
		if ver_test "${v}" -lt 1.7.0; then
			elog "Rofi 1.7.0 removed the (deprecated) xresources based configuration setup."
			elog "If you are still using old configuration setup, please convert it to new format manually."
			elog "The new format configuration can be generated by 'rofi -dump-config > ~/.config/rofi/config.rasi'."
			elog "For more information, please see https://github.com/davatorium/rofi/releases/tag/1.7.0"
		fi
	done
}
