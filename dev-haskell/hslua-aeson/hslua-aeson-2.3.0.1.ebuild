# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.8.2.0.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Allow aeson data types to be used with Lua"
HOMEPAGE="https://hslua.org/"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"

RDEPEND=">=dev-haskell/aeson-1.5:=[profile?] <dev-haskell/aeson-2.2:=[profile?]
	>=dev-haskell/hashable-1.2:=[profile?] <dev-haskell/hashable-1.5:=[profile?]
	>=dev-haskell/hslua-core-2.0:=[profile?] <dev-haskell/hslua-core-2.4:=[profile?]
	>=dev-haskell/hslua-marshalling-2.1:=[profile?] <dev-haskell/hslua-marshalling-2.4:=[profile?]
	>=dev-haskell/scientific-0.3:=[profile?] <dev-haskell/scientific-0.4:=[profile?]
	>=dev-haskell/text-1.2:=[profile?] <dev-haskell/text-2.1:=[profile?]
	>=dev-haskell/unordered-containers-0.2:=[profile?] <dev-haskell/unordered-containers-0.3:=[profile?]
	>=dev-haskell/vector-0.7:=[profile?]
	>=dev-lang/ghc-8.8.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-3.0.0.0
	test? ( dev-haskell/quickcheck
		dev-haskell/quickcheck-instances
		>=dev-haskell/tasty-0.11
		>=dev-haskell/tasty-hunit-0.10
		>=dev-haskell/tasty-quickcheck-0.8 )
"
