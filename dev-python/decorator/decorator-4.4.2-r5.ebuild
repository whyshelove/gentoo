# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( pypy3 python3_{7,8,9} )

inherit distutils-r1 rhel9

DESCRIPTION="Simplifies the usage of decorators for the average programmer"
HOMEPAGE="https://github.com/micheles/decorator https://pypi.org/project/decorator/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~x64-macos"

DOCS=( CHANGES.md )

distutils_enable_tests setup.py
