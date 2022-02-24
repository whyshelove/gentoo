# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DIST=12.el8
inherit rhel8
S="${WORKDIR}/${P}-${PR/r}.12"
DESCRIPTION="Hardware identification and configuration data"
HOMEPAGE="https://github.com/vcrhonek/hwdata"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"
RESTRICT="test"
