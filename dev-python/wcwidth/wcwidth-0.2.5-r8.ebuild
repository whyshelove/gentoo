# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,8,9} pypy3 )

inherit distutils-r1 rhel9-a

DESCRIPTION="Measures number of Terminal column cells of wide-character codes"
HOMEPAGE="https://pypi.org/project/wcwidth/ https://github.com/jquast/wcwidth"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/backports-functools-lru-cache[${PYTHON_USEDEP}]
	' -2)"

distutils_enable_tests pytest

src_prepare() {
	sed -i -e 's:test_package_version:_&:' tests/test_core.py || die

	distutils-r1_src_prepare
}

python_install_all() {
	docinto docs
	distutils-r1_python_install_all
}
