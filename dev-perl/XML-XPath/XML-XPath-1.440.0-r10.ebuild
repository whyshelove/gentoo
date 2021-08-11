# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DIST_AUTHOR=MANWAR
DIST_VERSION=1.44
DIST_EXAMPLES=("examples/*")
inherit perl-module rhel9-a

DESCRIPTION="A XPath Perl Module"

SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND=">=dev-perl/XML-Parser-2.230.0"
DEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		>=dev-perl/Path-Tiny-0.76.0
		virtual/perl-Test-Simple
	)
"
src_test() {
	perl_rm_files t/meta-json.t t/meta-yml.t
	perl-module_src_test
}
