# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DSUFFIX="_10"
inherit flag-o-matic multilib toolchain-funcs rhel8

MY_PV="${PV//.}"
MY_P="${PN}${MY_PV}"

DESCRIPTION="unzipper for pkzip-compressed files"
HOMEPAGE="https://infozip.sourceforge.net/UnZip.html"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="bzip2 natspec unicode"

DEPEND="bzip2? ( app-arch/bzip2 )
	natspec? ( dev-libs/libnatspec )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
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

	# Delete bundled code to make sure we don't use it.
	rm -r bzip2 || die
}

src_configure() {
	case ${CHOST} in
		i?86*-*linux*)       TARGET="linux_asm" ;;
		*linux*)             TARGET="generic_gcc" ;;
		i?86*-*bsd* | \
		i?86*-dragonfly*)    TARGET="freebsd" ;; # mislabelled bsd with x86 asm
		*bsd* | *dragonfly*) TARGET="bsd" ;;
		*-darwin*)           TARGET="macosx" ;;
		*-solaris*)          TARGET="generic" ;;
		*-cygwin*)           TARGET="generic" ;;
		*) die "Unknown target; please update the ebuild to handle ${CHOST}	" ;;
	esac

	[[ ${CHOST} == *linux* ]] && append-cppflags -DNO_LCHMOD
	use bzip2 && append-cppflags -DUSE_BZIP2
	use unicode && append-cppflags -DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DUSE_ICONV_MAPPING

	# bug #281473
	append-cppflags -DLARGE_FILE_SUPPORT

	CF_NOOPT="-I. -DUNIX $CFLAGS -DNOMEMCPY -DIZ_HAVE_UXUIDGID"
}

src_compile() {
	ASFLAGS="${ASFLAGS} $(get_abi_CFLAGS)" \
		emake -f unix/Makefile ${TARGET}  CF_NOOPT="${CF_NOOPT}" LFLAGS2="${LDFLAGS}"
}

src_install() {
	dobin unzip funzip unzipsfx unix/zipgrep
	dosym unzip /usr/bin/zipinfo
	doman man/*.1
	dodoc BUGS History* README ToDo WHERE
}
