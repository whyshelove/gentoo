# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# ebuild generated by hackport 0.6.1

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Portable regex library for Perl 5 compatible regular expressions"
HOMEPAGE="https://github.com/Daniel-Diaz/pcre-light"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 ~arm64 ~ppc64 ~riscv ~x86"
#IUSE="use-pkg-config"
IUSE=""

RDEPEND=">=dev-lang/ghc-7.4.1:=
	dev-libs/libpcre
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8.0
	virtual/pkgconfig
	test? ( >=dev-haskell/hunit-1.2.5.2
		>=dev-haskell/mtl-2.1.3.2 )
"

src_configure() {
	haskell-cabal_src_configure \
		--flag=use-pkg-config \
		--flag=-old_base
}
