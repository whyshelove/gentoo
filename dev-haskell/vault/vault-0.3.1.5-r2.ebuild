# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.7.1.1.9999
#hackport: flags: +useghc

CABAL_FEATURES="lib profile haddock hoogle hscolour"
CABAL_HACKAGE_REVISION=3
inherit haskell-cabal

DESCRIPTION="a persistent store for values of arbitrary types"
HOMEPAGE="https://github.com/HeinrichApfelmus/vault"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 ~arm64 ~ppc64 ~riscv ~x86"

RDEPEND="
	>=dev-haskell/hashable-1.1.2.5:=[profile?] <dev-haskell/hashable-1.5:=[profile?]
	>=dev-haskell/unordered-containers-0.2.3.0:=[profile?] <dev-haskell/unordered-containers-0.3:=[profile?]
	>=dev-lang/ghc-8.4.3:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.2.0.1
"

src_configure() {
	haskell-cabal_src_configure \
		--flag=useghc
}
