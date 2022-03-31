# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PATCH_VER="4"
PATCH_GCC_VER="11.3.0"
MUSL_VER="1"
MUSL_GCC_VER="11.3.0"

DIST=7.el9
DATE=20211203
inherit toolchain-rhel

KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ~ppc64 ~riscv ~s390 sparc x86"

RDEPEND=""
BDEPEND="${CATEGORY}/binutils"
