# Copyright 2004-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
# NEED_BOOTSTRAP is for developers to quickly generate a tarball
# for publishing to the tree.
NEED_BOOTSTRAP="no"
inherit python-any-r1 multilib rhel

DESCRIPTION="Extended crypt library for descrypt, md5crypt, bcrypt, and others"
HOMEPAGE="https://github.com/besser82/libxcrypt"
if [[ ${NEED_BOOTSTRAP} == "yes" ]] ; then
	SRC_URI+="https://github.com/besser82/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="LGPL-2.1+ public-domain BSD BSD-2"
SLOT="0/1"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="static-libs test"
RESTRICT="!test? ( test )"

DEPEND="sys-libs/glibc
	!sys-libs/musl
	"
RDEPEND="${DEPEND}"
BDEPEND="dev-lang/perl
	sys-apps/findutils
	test? ( $(python_gen_any_dep 'dev-python/passlib[${PYTHON_USEDEP}]') )"

python_check_deps() {
	has_version -b "dev-python/passlib[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	default

	# WARNING: Please read on bumping or applying patches!
	#
	# There are two circular dependencies to be aware of:
	# 1)
	# 	if we're bootstrapping configure and makefiles:
	# 		libxcrypt -> automake -> perl -> libxcrypt
	#
	#   mitigation:
	#		toolchain@ manually runs `make dist` after running autoconf + `./configure`
	#		and the ebuild uses that.
	#		(Don't include the pre-generated Perl artefacts.)
	#
	#	solution for future:
	#		Upstream are working on producing `make dist` tarballs.
	#		https://github.com/besser82/libxcrypt/issues/134#issuecomment-871833573
	#
	# 2)
	#	configure *unconditionally* needs Perl at build time to generate
	#	a list of enabled algorithms based on the set passed to `configure`:
	#		libxcrypt -> perl -> libxcrypt
	#
	#	mitigation:
	#		None at the moment.
	#
	#	solution for future:
	#		Not possible right now. Upstream intend on depending on Perl for further
	#		configuration options.
	#		https://github.com/besser82/libxcrypt/issues/134#issuecomment-871833573
	#
	# Therefore, on changes (inc. bumps):
	#	* You must check whether upstream have started providing tarballs with bootstrapped
	#	  auto{conf,make};
	#
	#	* diff the build system changes!
	#
}

src_configure() {
	local -a myconf=(
		--disable-werror
		--enable-shared
		--disable-failure-tokens
		--enable-hashes=all
		--libdir=/$(get_libdir)
		--with-pkgconfigdir=/usr/$(get_libdir)/pkgconfig
		$(use_enable static-libs static)
		--enable-obsolete-api=glibc
	)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	# Remove useless stuff from installation
	find "${D}" -name '*.la' -delete || die

	if use static-libs; then
		# .a files are installed to /$(get_libdir) by default
		# Move static libraries to /usr prefix or portage will abort
		shopt -s nullglob || die "failglob failed"
		static_libs=( "${ED}"/$(get_libdir)/*.a )

		if [[ -n ${static_libs[*]} ]]; then
			dodir "/usr/$(get_libdir)"
			mv "${static_libs[@]}" "${D}/usr/$(get_libdir)" || die "Moving static libs failed"
		fi
	fi
}
