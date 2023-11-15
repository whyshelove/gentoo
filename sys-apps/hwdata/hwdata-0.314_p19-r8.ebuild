# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

prefix_ver=$(ver_cut 4)
[[ ${prefix_ver} ]] && DPREFIX="${prefix_ver}."

inherit rhel8

DESCRIPTION="Hardware identification and configuration data"
HOMEPAGE="https://github.com/vcrhonek/hwdata"

S="${WORKDIR}/${MY_P}-${MY_PR}.${prefix_ver}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"
RESTRICT="test"
