# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit distutils-r1 rhel9-a

DESCRIPTION="Easily displaying tabular data in a visually appealing ASCII table format"
HOMEPAGE="https://code.google.com/p/prettytable/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ppc64 sparc x86 ~amd64-linux ~x86-linux"
IUSE="test"
RESTRICT="!test? ( test )"

python_test() {
	"${PYTHON}" prettytable_test.py || die "tests failed under ${EPYTHON}"
}
