# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.7.3.0
#hackport: flags: -llvm

CABAL_HACKAGE_REVISION=1

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Efficient algorithms for vector arrays"
HOMEPAGE="https://github.com/erikd/vector-algorithms/"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"
IUSE="+bench +boundschecks internalchecks +properties unsafechecks"

RDEPEND=">=dev-haskell/bitvec-1.0:=[profile?] <dev-haskell/bitvec-1.2:=[profile?]
	>=dev-haskell/primitive-0.6.2.0:=[profile?] <dev-haskell/primitive-0.8:=[profile?]
	>=dev-haskell/vector-0.6:=[profile?] <dev-haskell/vector-0.14:=[profile?]
	>=dev-lang/ghc-8.4.3:=
"

# bug 916191
RDEPEND+="
	|| (
		dev-haskell/bitvec[gmp]
		dev-lang/ghc[gmp]
	)
"

DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.2.0.1
	test? ( properties? ( >dev-haskell/quickcheck-2.9 <dev-haskell/quickcheck-2.15 ) )
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag bench bench) \
		$(cabal_flag boundschecks boundschecks) \
		$(cabal_flag internalchecks internalchecks) \
		--flag=-llvm \
		$(cabal_flag properties properties) \
		$(cabal_flag unsafechecks unsafechecks)
}
