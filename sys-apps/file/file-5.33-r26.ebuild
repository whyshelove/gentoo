# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{6,8,9} )
DISTUTILS_OPTIONAL=1

inherit distutils-r1 libtool toolchain-funcs multilib-minimal autotools rhel8

KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DESCRIPTION="identify a file's format by scanning binary data for patterns"
HOMEPAGE="https://www.darwinsys.com/file/"

LICENSE="BSD-2"
SLOT="0"
IUSE="python static-libs zlib"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	python? (
		${PYTHON_DEPS}
		dev-python/setuptools[${PYTHON_USEDEP}]
	)
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )"
RDEPEND="${DEPEND}
	python? ( !dev-python/python-magic )"

src_prepare() {
	default

	eautoreconf
	sed 's@README.md@README.python.md@' -i python/setup.py || die #662090
}

multilib_src_configure() {
	local myeconfargs=(
		--disable-libseccomp
		--enable-fsect-man5
		$(use_enable static-libs static)
		$(use_enable zlib)
	)
	econf "${myeconfargs[@]}"
}

build_src_configure() {
	local myeconfargs=(
		--disable-shared
		--disable-libseccomp
		--disable-zlib
	)
	tc-env_build econf "${myeconfargs[@]}"
}

need_build_file() {
	# when cross-compiling, we need to build up our own file
	# because people often don't keep matching host/target
	# file versions #362941
	tc-is-cross-compiler && ! has_version -b "~${CATEGORY}/${P}"
}

src_configure() {
	local ECONF_SOURCE=${S}
	append-cflags -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE
	if need_build_file; then
		mkdir -p "${WORKDIR}"/build || die
		cd "${WORKDIR}"/build || die
		build_src_configure
	fi

	multilib-minimal_src_configure
	# remove hardcoded library paths from local libtool
	sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
	sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
	export LD_LIBRARY_PATH=${ED}/src/.libs
}

multilib_src_compile() {
	if multilib_is_native_abi ; then
		emake
	else
		cd src || die
		emake magic.h #586444
		emake libmagic.la
	fi
}

src_compile() {
	if need_build_file; then
		emake -C "${WORKDIR}"/build/src magic.h #586444
		emake -C "${WORKDIR}"/build/src file
		local -x PATH="${WORKDIR}/build/src:${PATH}"
	fi
	multilib-minimal_src_compile

	if use python ; then
		cd python || die
		distutils-r1_src_compile
	fi
}

multilib_src_install() {
	if multilib_is_native_abi ; then
		default
	else
		emake -C src install-{nodist_includeHEADERS,libLTLIBRARIES} DESTDIR="${D}"
	fi
}

multilib_src_install_all() {
	dodoc ChangeLog MAINT README

	# local magic in /etc/magic
	mkdir -p ${D}/etc
	cp -a ./magic/magic.local ${D}/etc/magic

	dodir /usr/share/file
	ln -s ../magic ${D}/usr/share/file/magic

	# Required for `file -C`
	dodir /usr/share/misc/magic
	insinto /usr/share/misc/magic
	doins -r magic/Magdir/*


	if use python ; then
		cd python || die
		distutils-r1_src_install
	fi
	find "${ED}" -type f -name "*.la" -delete || die
}
