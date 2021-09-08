# Copyright 2003-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic multilib-minimal rhel8

DESCRIPTION="Libraries/utilities to handle ELF objects (drop in replacement for libelf)"
HOMEPAGE="http://elfutils.org/"

LICENSE="|| ( GPL-2+ LGPL-3+ ) utils? ( GPL-3+ )"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="bzip2 lzma nls static-libs test +threads +utils valgrind zstd debuginfod libdebuginfod"

RDEPEND=">=sys-libs/zlib-1.2.8-r1[static-libs?,${MULTILIB_USEDEP}]
	bzip2? ( >=app-arch/bzip2-1.0.6-r4[static-libs?,${MULTILIB_USEDEP}] )
	lzma? ( >=app-arch/xz-utils-5.0.5-r1[static-libs?,${MULTILIB_USEDEP}] )
	zstd? ( app-arch/zstd:=[static-libs?,${MULTILIB_USEDEP}] )
	!dev-libs/libelf
"
DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )
	debuginfod? ( >=net-libs/libmicrohttpd-0.9.55 )
"
BDEPEND="nls? ( sys-devel/gettext )
	>=sys-devel/flex-2.5.4a
	sys-devel/m4
"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}"/${PN}-0.175-disable-biarch-test-PR24158.patch
	"${FILESDIR}"/${PN}-0.177-disable-large.patch
	"${FILESDIR}"/${PN}-0.180-PaX-support.patch
	"${FILESDIR}"/${PN}-0.185-static-inline.patch
)

src_prepare() {
	default

	if ! use static-libs; then
		sed -i -e '/^lib_LIBRARIES/s:=.*:=:' -e '/^%.os/s:%.o$::' lib{asm,dw,elf}/Makefile.in || die
	fi
	# https://sourceware.org/PR23914
	sed -i 's:-Werror::' */Makefile.in || die
}

src_configure() {
	use test && append-flags -g #407135
	# Remove -Wall from default flags.  The makefiles enable enough warnings
	# themselves, and they use -Werror.  Appending -Wall defeats the cases where
	# the makefiles disable some specific warnings for specific code.
	# But add -Wformat explicitly for use with -Werror=format-security which
	# doesn't work without -Wformat (enabled by -Wall).
	filter-flags -Wall
	append-flags -Wformat
	append-cflags -fexceptions

	# Symbol aliases are implemented as asm statements.
	# Will require porting: https://gcc.gnu.org/PR48200
	filter-flags '-flto*'

	multilib-minimal_src_configure
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		$(use_enable nls) \
		$(use_enable threads thread-safety) \
		$(use_enable valgrind) \
		$(use_enable debuginfod) \
		$(use_enable libdebuginfod) \
		--program-prefix="eu-" \
		--with-zlib \
		$(use_with bzip2 bzlib) \
		$(use_with lzma) \
		$(use_with zstd)
}

multilib_src_test() {
	# Record some build root versions in build.log
	uname -r; rpm -q binutils gcc glibc || true

	env	LD_LIBRARY_PATH="${BUILD_DIR}/libelf:${BUILD_DIR}/libebl:${BUILD_DIR}/libdw:${BUILD_DIR}/libasm" \
		LC_ALL="C" \
		emake -s check VERBOSE=1 || (cat tests/test-suite.log; true)
}

multilib_src_install_all() {
	einstalldocs
	dodoc NOTES
	# These build quick, and are needed for most tests, so don't
	# disable their building when the USE flag is disabled.
	if ! use utils; then
		rm -rf "${ED}"/usr/bin || die
	fi
	chmod +x "${ED}"/usr/lib64/lib*.so*

	install -Dm0644 config/debuginfod.service "${ED}"/usr/lib/systemd/system/debuginfod.service
	install -Dm0644 config/debuginfod.sysconfig "${ED}"/etc/sysconfig/debuginfod
	mkdir -p "${ED}"/var/cache/debuginfod
	touch "${ED}"/var/cache/debuginfod/debuginfod.sqlite
}
