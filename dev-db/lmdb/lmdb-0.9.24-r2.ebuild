# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic multilib-minimal toolchain-funcs rhel8

MY_P="${PN^^}_${PV}"

DESCRIPTION="An ultra-fast, ultra-compact key-value embedded data store"
HOMEPAGE="https://symas.com/lmdb/technical/"

LICENSE="OPENLDAP"
SLOT="0/${PV}"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="static-libs"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}-${MY_P}/libraries/liblmdb"

src_prepare() {
	default
	multilib_copy_sources
}

multilib_src_configure() {
	local soname="-Wl,-soname,liblmdb$(get_libname 0)"

	sed -i -e "s!^CC.*!CC = $(tc-getCC)!" \
		-e "s!^CFLAGS.*!CFLAGS = ${CFLAGS}!" \
		-e "s!^AR.*!AR = $(tc-getAR)!" \
		-e "s!^SOEXT.*!SOEXT = $(get_libname)!" \
		-e "/^prefix/s!/usr/local!${EPREFIX}/usr!" \
		-e "/^libdir/s!lib\$!$(get_libdir)!" \
		-e "s!shared!shared ${soname}!" \
		"Makefile" || die
}

multilib_src_compile() {
	emake LDLIBS+=" -pthread" XCFLAGS="${optflags}"
}

multilib_src_install() {
	emake DESTDIR="${D}" install

	mv "${ED}"/usr/$(get_libdir)/liblmdb$(get_libname) \
		"${ED}"/usr/$(get_libdir)/liblmdb$(get_libname 0) || die
	dosym liblmdb$(get_libname 0) /usr/$(get_libdir)/liblmdb$(get_libname)

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${FILESDIR}/lmdb.pc"
	sed -i -e "s!@PACKAGE_VERSION@!${PV}!" \
		-e "s!@prefix@!${EPREFIX}/usr!g" \
		-e "s!@libdir@!$(get_libdir)!" \
		"${ED}"/usr/$(get_libdir)/pkgconfig/lmdb.pc || die
}
