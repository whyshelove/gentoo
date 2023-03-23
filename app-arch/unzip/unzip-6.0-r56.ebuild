# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic multilib toolchain-funcs rhel9

MY_PV="${PV//.}"
MY_PV="${MY_PV%_p*}"
MY_P="${PN}${MY_PV}"

DESCRIPTION="unzipper for pkzip-compressed files"
HOMEPAGE="https://infozip.sourceforge.net/UnZip.html"
SRC_URI+="
	mirror://debian/pool/main/u/${PN}/${PN}_${PV}-27.debian.tar.xz"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 natspec unicode"

DEPEND="bzip2? ( app-arch/bzip2 )
	natspec? ( dev-libs/libnatspec )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${WORKDIR}"/debian/patches
)

src_prepare() {
	# bug #275244
	use natspec && PATCHES+=( "${FILESDIR}"/${PN}-6.0-natspec.patch )

	rm "${WORKDIR}"/debian/patches/0{2,5,7,9}-*.patch || die
	rm "${WORKDIR}"/debian/patches/1{0,1,2,4,6,7,8,9}-*.patch || die
	rm "${WORKDIR}"/debian/patches/2{0,2,3,4,5,6,8}-*.patch || die
	default

	sed -i -r \
		-e '/^CFLAGS/d' \
		-e '/CFLAGS/s:-O[0-9]?:$(CFLAGS) $(CPPFLAGS):' \
		-e '/^STRIP/s:=.*:=true:' \
		-e "s:\<CC *= *\"?g?cc2?\"?\>:CC=\"$(tc-getCC)\":" \
		-e "s:\<LD *= *\"?(g?cc2?|ld)\"?\>:LD=\"$(tc-getCC)\":" \
		-e "s:\<AS *= *\"?(g?cc2?|as)\"?\>:AS=\"$(tc-getCC)\":" \
		-e 's:LF2 = -s:LF2 = :' \
		-e 's:LF = :LF = $(LDFLAGS) :' \
		-e 's:SL = :SL = $(LDFLAGS) :' \
		-e 's:FL = :FL = $(LDFLAGS) :' \
		-e "/^#L_BZ2/s:^$(use bzip2 && echo .)::" \
		-e 's:$(AS) :$(AS) $(ASFLAGS) :g' \
		unix/Makefile \
		|| die "sed unix/Makefile failed"

	# Use the C implementation of CRC instead of assembly (only on i386, other architectures use C by default)
	sed -i -e 's:-DASM_CRC::g' unix/configure || die "sed unix/configure failed"
	sed -i -e 's:CRC32OA="crc_gcc.o":CRC32OA="":g' unix/configure || die "sed unix/configure failed"

	# Delete bundled code to make sure we don't use it.
	rm -r bzip2 || die
}

src_configure() {
	case ${CHOST} in
		i?86*-*linux*)       TARGET="linux_asm" ;;
		*linux*)             TARGET="linux_noasm" ;;
		i?86*-*bsd* | \
		i?86*-dragonfly*)    TARGET="freebsd" ;; # mislabelled bsd with x86 asm
		*bsd* | *dragonfly*) TARGET="bsd" ;;
		*-darwin*)           TARGET="macosx" ;;
		*-solaris*)          TARGET="generic" ;;
		*-cygwin*)           TARGET="generic" ;;
		*) die "Unknown target; please update the ebuild to handle ${CHOST}	" ;;
	esac

	# Needed for Clang 16
	append-flags -std=gnu89

	[[ ${CHOST} == *linux* ]] && append-cppflags -DNO_LCHMOD
	use bzip2 && append-cppflags -DUSE_BZIP2
	use unicode && append-cppflags -DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DUSE_ICONV_MAPPING

	# bug #281473
	append-cppflags -DLARGE_FILE_SUPPORT
}

src_compile() {
	CF_NOOPT="-I. -DUNIX $CFLAGS -DNOMEMCPY -DIZ_HAVE_UXUIDGID -DNO_LCHMOD"

	ASFLAGS="${ASFLAGS} $(get_abi_CFLAGS)" emake -f unix/Makefile ${TARGET} CF_NOOPT="${CF_NOOPT}" LFLAGS2="${LDFLAGS}" generic_gcc

}

src_install() {
	dobin unzip funzip unzipsfx unix/zipgrep
	dosym unzip /usr/bin/zipinfo
	doman man/*.1
	dodoc BUGS History* README ToDo WHERE
}
