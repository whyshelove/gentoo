# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

suffix_ver=$(ver_cut 4)
[[ ${suffix_ver} ]] && DSUFFIX="_${suffix_ver}"

inherit flag-o-matic rhel8

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="https://www.gnu.org/software/gzip/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="+pic static"

PATCHES=(
	"${FILESDIR}/${PN}-1.3.8-install-symlinks.patch"
)

src_configure() {
	use static && append-flags -static

	# avoid text relocation in gzip
	use pic && export DEFS="NO_ASM"
	export CPPFLAGS="-DHAVE_LSTAT"

	econf --disable-gcc-warnings #663928

}

src_install() {
	default

	docinto txt
	dodoc algorithm.doc gzip.doc

	# keep most things in /usr, just the fun stuff in /
	dodir /bin
	mv "${ED}"/usr/bin/{gunzip,gzip,uncompress,zcat} "${ED}"/bin/ || die
	sed -e "s:${EPREFIX}/usr:${EPREFIX}:" -i "${ED}"/bin/gunzip || die
}
