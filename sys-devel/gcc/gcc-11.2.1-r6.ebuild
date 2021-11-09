# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PATCH_GCC_VER="11.2.0"
PATCH_VER="1"

#MY_PR=${PVR##*r}
#MY_PF=${P}-${MY_PR}
DATE=20211019
inherit toolchain-rhel

KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"

RDEPEND=""
BDEPEND="${CATEGORY}/binutils"
