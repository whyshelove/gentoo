# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.7.1.1.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Common lower-level functions needed by various streaming data libraries"
HOMEPAGE="https://github.com/fpco/streaming-commons"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"

RESTRICT=test # requires network

RDEPEND="dev-haskell/async:=[profile?]
	>=dev-haskell/network-2.4.0.0:=[profile?]
	dev-haskell/random:=[profile?]
	dev-haskell/stm:=[profile?]
	dev-haskell/zlib:=[profile?]
	>=dev-lang/ghc-8.6.3:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.4.0.1
	test? ( >=dev-haskell/hspec-1.8
		dev-haskell/quickcheck )
"
