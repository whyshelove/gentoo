# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=KWMAK
DIST_SECTION=PBS/Client
DIST_VERSION=0.11
inherit perl-module

DESCRIPTION="Perl interface to submit jobs to PBS (Portable Batch System)"

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=virtual/perl-Data-Dumper-2.121.0
	>=virtual/perl-File-Temp-0.140.0
"
BDEPEND="
	${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"
