# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DSUFFIX="_3.2"
inherit rhel8

DESCRIPTION="This package contains DBX updates for UEFI Secure Boot."
HOMEPAGE="https://github.com/vathpela/dbxtool"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"

DEPEND="sys-libs/efivar:=
	dev-libs/popt
	dev-vcs/git"
RDEPEND="${DEPEND}"
