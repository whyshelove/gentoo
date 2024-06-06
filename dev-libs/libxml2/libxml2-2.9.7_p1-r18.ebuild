# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,8,9} )
PYTHON_REQ_USE="xml"

suffix_ver=$(ver_cut 5)
[[ ${suffix_ver} ]] && DSUFFIX="_10.${suffix_ver}"

inherit autotools flag-o-matic prefix python-r1 multilib-minimal rhel8

DESCRIPTION="XML C parser and toolkit"
HOMEPAGE="http://www.xmlsoft.org/ https://gitlab.gnome.org/GNOME/libxml2"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

IUSE="debug examples icu ipv6 lzma +python readline static-libs test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-util/gtk-doc-am
	virtual/pkgconfig
"
RDEPEND="
	>=sys-libs/zlib-1.2.8-r1:=[${MULTILIB_USEDEP}]
	icu? ( >=dev-libs/icu-51.2-r1:=[${MULTILIB_USEDEP}] )
	lzma? ( >=app-arch/xz-utils-5.0.5-r1:=[${MULTILIB_USEDEP}] )
	python? ( ${PYTHON_DEPS} )
	readline? ( sys-libs/readline:= )
"
DEPEND="${RDEPEND}"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/xml2-config
)

src_prepare() {
	default

	DOCS=( AUTHORS ChangeLog NEWS README* TODO* )

	eprefixify catalog.c xmlcatalog.c runtest.c xmllint.c


	if [[ ${CHOST} == *-darwin* ]] ; then
		# Avoid final linking arguments for python modules
		sed -i -e '/PYTHON_LIBS/s/ldflags/libs/' configure.ac || die
		# gcc-apple doesn't grok -Wno-array-bounds
		sed -i -e 's/-Wno-array-bounds//' configure.ac || die
	fi

	# Please do not remove, as else we get references to PORTAGE_TMPDIR
	# in /usr/lib/python?.?/site-packages/libxml2mod.la among things.
	# We now need to run eautoreconf at the end to prevent maintainer mode.
	# elibtoolize
	# If we don't eautoreconf, we need this instead
	# epunt_cxx

	eautoreconf
}

multilib_src_configure() {
	# Filter seemingly problematic CFLAGS (#26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	# Notes:
	# 1) USE zlib support breaks gnome2
	#    (libgnomeprint for instance fails to compile with
	#    fresh install, and existing) - <azarah@gentoo.org> (22 Dec 2002).
	#
	# 2) The meaning of the 'debug' USE flag does not apply to the --with-debug
	#    switch (enabling the libxml2 debug module). See bug #100898.
	#
	# 3) --with-mem-debug causes unusual segmentation faults (bug #105120).

	libxml2_configure() {
		ECONF_SOURCE="${S}" econf \
			--with-html-subdir=${PF}/html \
			$(use_with debug run-debug) \
			$(use_with icu) \
			$(use_with lzma) \
			$(use_enable ipv6) \
			$(use_enable static-libs static) \
			$(multilib_native_use_with readline) \
			$(multilib_native_use_with readline history) \
			"$@"
	}

	libxml2_py_configure() {
		# Ensure python build dirs exist
		mkdir -p "${BUILD_DIR}" || die

		# Odd build system, also see bug #582130
		run_in_build_dir libxml2_configure \
			"--cache-file=../config.cache" \
			"--with-python=${EPYTHON}" \
			"--with-python-install-dir=$(python_get_sitedir)"
	}

	# Build python bindings separately
	libxml2_configure --without-python

	if multilib_is_native_abi && use python ; then
		python_foreach_impl libxml2_py_configure
	fi
}

libxml2_py_emake() {
	pushd "${BUILD_DIR}/python" > /dev/null || die

	emake "$@"

	popd > /dev/null || die
}

multilib_src_compile() {
	default

	if multilib_is_native_abi && use python ; then
		local native_builddir="${BUILD_DIR}"

		python_foreach_impl libxml2_py_emake \
				top_builddir="${native_builddir}" \
				all
	fi
}

multilib_src_test() {
	ln -s "${S}"/xmlconf || die

	emake check

	if multilib_is_native_abi && use python ; then
		python_foreach_impl libxml2_py_emake test
	fi
}

multilib_src_install() {
	emake \
		DESTDIR="${D}" \
		EXAMPLES_DIR="${EPREFIX}"/usr/share/doc/${PF}/examples \
		install

	if multilib_is_native_abi && use python ; then
		python_foreach_impl libxml2_py_emake \
			DESTDIR="${D}" \
			docsdir="${EPREFIX}"/usr/share/doc/${PF}/python \
			exampledir="${EPREFIX}"/usr/share/doc/${PF}/python/examples \
			install

		python_foreach_impl python_optimize
	fi
}

multilib_src_install_all() {
	rm -rf "${ED}"/usr/share/doc/${P}

	einstalldocs

	# multiarch crazyness on timestamp differences or Makefile/binaries for examples
	touch -m --reference=${ED}"/usr/include/libxml2/libxml/parser.h ${ED}"/usr/bin/xml2-config

	if ! use examples ; then
		rm -rf "${ED}"/usr/share/doc/${PF}/examples
		rm -rf "${ED}"/usr/share/doc/${PF}/python/examples
	fi

	find "${D}" -name '*.la' -delete || die
}

pkg_postinst() {
	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [[ -n "${ROOT}" ]]; then
		elog "Skipping XML catalog creation for stage building (bug #208887)."
	else
		# Need an XML catalog, so no-one writes to a non-existent one
		CATALOG="${EROOT}/etc/xml/catalog"

		# We don't want to clobber an existing catalog though,
		# only ensure that one is there
		# <obz@gentoo.org>
		if [[ ! -e "${CATALOG}" ]]; then
			[[ -d "${EROOT}/etc/xml" ]] || mkdir -p "${EROOT}/etc/xml"
			"${EPREFIX}"/usr/bin/xmlcatalog --create > "${CATALOG}"
			einfo "Created XML catalog in ${CATALOG}"
		fi
	fi
}
