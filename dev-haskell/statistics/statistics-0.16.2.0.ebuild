# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.8.4.0.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="A library of statistical types, data, and functions"
HOMEPAGE="https://github.com/haskell/statistics"

LICENSE="BSD-2"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"

RESTRICT=test # likes to fail under a load

RDEPEND=">=dev-haskell/aeson-0.6.0.0:=[profile?]
	>=dev-haskell/async-2.2.2:=[profile?] <dev-haskell/async-2.3:=[profile?]
	>=dev-haskell/data-default-class-0.1.2:=[profile?]
	>=dev-haskell/dense-linear-algebra-0.1:=[profile?] <dev-haskell/dense-linear-algebra-0.2:=[profile?]
	>=dev-haskell/math-functions-0.3.4.1:=[profile?]
	>=dev-haskell/mwc-random-0.15.0.0:=[profile?]
	>=dev-haskell/parallel-3.2.2.0:=[profile?] <dev-haskell/parallel-3.3:=[profile?]
	>=dev-haskell/primitive-0.3:=[profile?]
	>=dev-haskell/random-1.2:=[profile?]
	>=dev-haskell/vector-0.10:=[profile?]
	>=dev-haskell/vector-algorithms-0.4:=[profile?]
	>=dev-haskell/vector-binary-instances-0.2.1:=[profile?]
	dev-haskell/vector-th-unbox:=[profile?]
	>=dev-lang/ghc-8.8.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-3.0.0.0
	test? ( dev-haskell/erf
		>=dev-haskell/ieee754-0.7.3
		>=dev-haskell/quickcheck-2.7.5
		dev-haskell/tasty
		dev-haskell/tasty-expected-failure
		dev-haskell/tasty-hunit
		dev-haskell/tasty-quickcheck )
"
