# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit rhel8-a

DESCRIPTION="Overwrite files with iterative patterns."
HOMEPAGE="https://github.com/chaos/scrub"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~sparc x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	default
	./autogen.sh
}
