# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool multilib-minimal usr-ldscript rhel8

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="https://www.pcre.org/"

if [[ ${PV} != *8888 ]]; then
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 jit libedit +pcre16 +pcre32 readline recursion-limit static-libs unicode zlib"
REQUIRED_USE="?? ( libedit readline )"

BDEPEND="
	virtual/pkgconfig
	userland_GNU? ( >=sys-apps/findutils-4.4.0 )
"
RDEPEND="
	bzip2? ( app-arch/bzip2 )
	libedit? ( dev-libs/libedit )
	readline? ( sys-libs/readline:0= )
	zlib? ( sys-libs/zlib )
"
DEPEND="${RDEPEND}"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/pcre2-config
)

src_prepare() {
	[[ -d "${WORKDIR}/patches" ]] && eapply "${WORKDIR}"/patches

	default

	[[ ${PV} == *8888 ]] && elibtoolize --copy --force && autoreconf -vif
}

multilib_src_configure() {
	local myeconfargs=(
		--enable-pcre2-8
		--enable-shared
		--enable-newline-is-lf
		--enable-pcre2grep-callout
		--disable-bsr-anycrlf
		--disable-coverage
		--disable-ebcdic
		--disable-fuzz-support
		--disable-never-backslash-C
		--disable-rebuild-chartables
		--disable-silent-rules
		--disable-valgrind
		--disable-jit-sealloc
		--with-match-limit-depth=$(usex recursion-limit 8192 MATCH_LIMIT)
		$(multilib_native_use_enable bzip2 pcre2grep-libbz2)
		$(multilib_native_use_enable libedit pcre2test-libedit)
		$(multilib_native_use_enable readline pcre2test-libreadline)
		$(multilib_native_use_enable zlib pcre2grep-libz)
		$(use_enable jit)
		$(use_enable jit pcre2grep-jit)
		$(use_enable pcre16 pcre2-16)
		$(use_enable pcre32 pcre2-32)
		$(use_enable static-libs static)
		$(use_enable unicode)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	emake V=1 $(multilib_is_native_abi || echo "bin_PROGRAMS=")
}

multilib_src_install() {
	emake \
		DESTDIR="${D}" \
		$(multilib_is_native_abi || echo "bin_PROGRAMS= dist_html_DATA=") \
		install
	multilib_is_native_abi && gen_usr_ldscript -a pcre2-posix
}

multilib_src_install_all() {
	find "${ED}" -type f -name "*.la" -delete || die
}
