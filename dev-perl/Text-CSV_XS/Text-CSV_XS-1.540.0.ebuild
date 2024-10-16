# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=HMBRAND
DIST_A_EXT=tgz
DIST_VERSION=1.54
DIST_EXAMPLES=("examples/*")
inherit perl-module

DESCRIPTION="Comma-separated values manipulation routines"

SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 hppa ~loong ~mips ppc ppc64 ~riscv ~s390 ~sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"

RDEPEND="
	>=virtual/perl-Encode-3.210.0
	virtual/perl-IO
	virtual/perl-XSLoader
"
BDEPEND="
	${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		virtual/perl-Test-Simple
	)
"

PERL_RM_FILES=( "t/00_pod.t" "t/01_pod.t" )
