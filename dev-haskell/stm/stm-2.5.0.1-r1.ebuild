# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.8.0.0.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Software Transactional Memory"
HOMEPAGE="https://wiki.haskell.org/Software_transactional_memory"

LICENSE="BSD"
SLOT="0/${PV}"
# Keep in sync with relevant ghc versions (CABAL_CORE_LIB_GHC_PV)
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86 ~amd64-linux ~x86-linux"

CABAL_CHDEPS=(
	'base  >= 4.3 && < 4.15' 'base >= 4.3'
)

RDEPEND="
	>=dev-lang/ghc-8.10.6:= <dev-lang/ghc-9.1
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.2.0.1
"

# ghc-9.0.1 and ghc-9.0.2 actually bundles stm-2.5.0.0, but downgrades can be messy.
# Mark as bundled as a workaround.
CABAL_CORE_LIB_GHC_PV="8.10.6 9.0.2"
