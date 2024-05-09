# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 cmake

DESCRIPTION="Berkeley IEEE Binary Floating-Point Library"
HOMEPAGE="https://github.com/SDL-Hercules-390/SoftFloat"
EGIT_REPO_URI="https://github.com/SDL-Hercules-390/SoftFloat"

LICENSE="BSD"
SLOT="0"
PATCHES=( "${FILESDIR}/cmakefix.patch" )
