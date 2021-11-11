# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils libtool toolchain-funcs multilib-minimal rhel8

MY_PN="binutils"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Core binutils libraries (libbfd, libopcodes, libiberty) for external packages"
HOMEPAGE="https://sourceware.org/binutils/"

LICENSE="|| ( GPL-3 LGPL-3 )"
# The shared lib SONAMEs use the ${PV} in them.
# -r1 is a one-off subslot bump where SONAME changed for bug #666100
SLOT="0/${PV}"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="64-bit-bfd multitarget nls static-libs"

COMMON_DEPEND="sys-libs/zlib[${MULTILIB_USEDEP}]"
DEPEND="${COMMON_DEPEND}
	>=sys-apps/texinfo-4.7
	nls? ( sys-devel/gettext )"
# Need a newer binutils-config that'll reset include/lib symlinks for us.
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/binutils-config-5
	nls? ( !<sys-devel/gdb-7.10-r1[nls] )"

S="${WORKDIR}/${MY_P}"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/bfd.h
)

src_prepare() {
	# Fix cross-compile relinking issue, bug #626402
	elibtoolize

	default
}

pkgversion() {
	printf "Gentoo ${PVR}"
	[[ -n ${PATCHVER} ]] && printf " p${PATCHVER}"
}

multilib_src_configure() {
	local myconf=(
		--enable-obsolete
		--enable-shared
		--enable-threads
		# Newer versions (>=2.24) make this an explicit option. #497268
		--enable-install-libiberty
		--disable-werror
		--with-bugurl="https://bugs.gentoo.org/"
		--with-pkgversion="$(pkgversion)"
		$(use_enable static-libs static)
		# The binutils eclass enables this flag for all bi-arch builds,
		# but other tools often don't care about that support.  Put it
		# beyond a flag if people really want it, but otherwise leave
		# it disabled as it can slow things down on 32bit arches. #438522
		$(use_enable 64-bit-bfd)
		# This only disables building in the zlib subdir.
		# For binutils itself, it'll use the system version. #591516
		--without-zlib
		--with-system-zlib
		# We only care about the libs, so disable programs. #528088
		--disable-{binutils,etc,ld,gas,gold,gprof}
		# Disable modules that are in a combined binutils/gdb tree. #490566
		--disable-{gdb,libdecnumber,readline,sim}
		# Strip out broken static link flags.
		# https://gcc.gnu.org/PR56750
		--without-stage1-ldflags
		# We pull in all USE-flags that change ABI in an incompatible
		# way. #666100
		# USE=multitarget change size of global arrays
		# USE=64-bit-bfd changes data structures of exported API
		--with-extra-soversion-suffix=gentoo-${CATEGORY}-${PN}-$(usex multitarget mt st)-$(usex 64-bit-bfd 64 def)
	)

	# mips can't do hash-style=gnu ...
	if [[ $(tc-arch) != mips ]] ; then
		myconf+=( --enable-default-hash-style=gnu )
	fi

	case $(tc-arch) in
		ppc*|sparc|x86|s390|sh|arm*) myconf+=( --enable-64-bit-bfd ) ;;
		ppc*) myconf+=( --enable-targets=spu ) ;;
		ppc64) myconf+=( --enable-targets=powerpc64le-linux ) ;;
	esac

	( [[ $(tc-arch) == s390 ]] && CARGS=all ) || CARGS=x86_64-pep

	use multitarget && myconf+=( --enable-targets=$CARGS --enable-64-bit-bfd )

	use nls \
		&& myconf+=( --without-included-gettext ) \
		|| myconf+=( --disable-nls )

	ECONF_SOURCE=${S} \
	econf "${myconf[@]}"

	# Prevent makeinfo from running as we don't build docs here.
	# bug #622652
	sed -i \
		-e '/^MAKEINFO/s:=.*:= true:' \
		Makefile || die
}

multilib_src_install() {
	default
	# Provide libiberty.h directly.
	dosym libiberty/libiberty.h /usr/include/libiberty.h
}

multilib_src_install_all() {
	use static-libs || find "${ED}"/usr -name '*.la' -delete
}
