# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.8.4.0.9999
#hackport: flags: -buildtests

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Typeclasses and instances for converting between types"
HOMEPAGE="https://hackage.haskell.org/package/convertible"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"

RDEPEND="dev-haskell/old-time:=[profile?]
	>=dev-haskell/text-0.8:=[profile?]
	>=dev-lang/ghc-8.10.6:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-3.2.1.0
	test? ( >=dev-haskell/quickcheck-2.8 )
"

src_configure() {
	haskell-cabal_src_configure \
		--flag=-buildtests
}
