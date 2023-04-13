# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic rhel8-p

MY_P=${P/opensp/OpenSP}
DESCRIPTION="A free, object-oriented toolkit for SGML parsing and entity management"
HOMEPAGE="https://openjade.sourceforge.net/"

S=${WORKDIR}/${MY_P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="doc nls static-libs test"
RESTRICT="!test? ( test )"

RDEPEND="elibc_glibc? ( net-libs/libnsl:0= )"
DEPEND="${RDEPEND}"
BDEPEND="nls? ( sys-devel/gettext )
	doc? (
		app-text/xmlto
		app-text/docbook-xml-dtd:4.1.2
	)
	test? (
		app-text/docbook-xml-dtd:4.5
		app-text/openjade
		app-text/sgml-common
	)"

PATCHES=(
	"${FILESDIR}"/${P}-c11-using.patch
)

src_prepare() {
	default
	use prefix && eautoreconf
}

src_configure() {
	export CONFIG_SHELL=${BASH}  # configure needs bash

	# The following filters are taken from openjade's ebuild. See bug #100828.
	# Please note!  Opts are disabled.  If you know what you're doing
	# feel free to remove this line.  It may cause problems with
	# docbook-sgml-utils among other things.
	#ALLOWED_FLAGS="-O -O1 -O2 -pipe -g -march"
	strip-flags

	append-cxxflags -std=gnu++11

	econf \
		--enable-http \
		--enable-default-catalog="${EPREFIX}"/etc/sgml/catalog \
		--enable-default-search-path="${EPREFIX}"/usr/share/sgml:"${EPREFIX}"/usr/share/xml \
		--datadir="${EPREFIX}"/usr/share/sgml/${P} \
		$(use_enable nls) \
		$(use_enable doc doc-build) \
		$(use_enable static-libs static)
}

src_compile() {
	emake pkgdocdir="${EPREFIX}"/usr/share/doc/${PF}
}

src_test() {
	# Skipping tests known not to work
	emake SHOWSTOPPERS= check
	SANDBOX_PREDICT="${SANDBOX_PREDICT%:/}"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		pkgdocdir="${EPREFIX}"/usr/share/doc/${PF} \
		install

	find "${ED}" -name '*.la' -delete || die

	dodoc AUTHORS BUGS ChangeLog NEWS README

	# oMy, othis ois osilly.
	for file in nsgmls sgmlnorm spam spent sx ; do
	   ln -s o$file ${ED}${_bindir}/$file
	done

	# Rename sx to sgml2xml.
	mv ${ED}${_bindir}/sx ${ED}${_bindir}/sgml2xml

	# Clean out (installed) redundant copies of the docs and DTDs.
	rm -rf ${ED}${_docdir}/OpenSP
	rm -rf ${ED}${_datadir}/OpenSP
}
