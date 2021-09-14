# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6..9} )

inherit autotools python-r1 rhel8

DESCRIPTION="A command-line tool and library to read and convert trace files"
HOMEPAGE="https://babeltrace.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv x86"
IUSE="test +python"
RESTRICT="!test? ( test )"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="dev-libs/glib:2
	dev-libs/popt
	dev-libs/elfutils
	sys-apps/util-linux
	${PYTHON_DEPS}
	"

DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
	"

pkg_setup() {
	python_setup
	export PYTHON_CONFIG=${PYTHON}-config
}

src_prepare() {
	default
	eautoreconf -vif
}

src_configure() {
	econf $(use_enable test glibtest) \
		$(use_enable python python-bindings) \
		--enable-debug-info
}

src_install() {
	default
	python_foreach_impl python_optimize

	find "${D}" -name '*.la' -delete || die
}
