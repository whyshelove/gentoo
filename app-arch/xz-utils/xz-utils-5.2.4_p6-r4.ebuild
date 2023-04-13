# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

EAPI=7

suffix_ver=$(ver_cut 5)
[[ ${suffix_ver} ]] && DSUFFIX="_${suffix_ver}"

inherit libtool multilib multilib-minimal preserve-libs usr-ldscript rhel8

if [[ ${PV} == "8888" ]] ; then
	EGIT_REPO_URI="$EGIT_REPO_URIhttps://git.tukaani.org/xz.git"
	inherit autotools
	SRC_URI=""
	BDEPEND="sys-devel/gettext dev-vcs/cvs >=sys-devel/libtool-2" #272880 286068
else
	KEYWORDS="amd64 arm64 ~ppc64 ~s390"
fi

DESCRIPTION="utils for managing LZMA compressed files"
HOMEPAGE="https://tukaani.org/xz/"

# See top-level COPYING file as it outlines the various pieces and their licenses.
LICENSE="public-domain LGPL-2.1+ GPL-2+"
SLOT="0"
IUSE="elibc_FreeBSD +extra-filters nls static-libs"

RDEPEND="!<app-arch/lzma-4.63
	!<app-arch/p7zip-4.57
	!<app-i18n/man-pages-de-2.16"
DEPEND="${RDEPEND}"

# Tests currently do not account for smaller feature set
RESTRICT="!extra-filters? ( test )"

src_prepare() {
	default
	if [[ ${PV} == "8888" ]] ; then
		eautopoint
		eautoreconf
	else
		elibtoolize  # to allow building shared libs on Solaris/x64
	fi
}

multilib_src_configure() {
	local myconf=(
		--enable-threads
		$(use_enable nls)
		$(use_enable static-libs static)
	)
	multilib_is_native_abi ||
		myconf+=( --disable-{xz,xzdec,lzmadec,lzmainfo,lzma-links,scripts} )
	if ! use extra-filters; then
		myconf+=(
			# LZMA1 + LZMA2 for standard .lzma & .xz files
			--enable-encoders=lzma1,lzma2
			--enable-decoders=lzma1,lzma2
			# those are used by default, depending on preset
			--enable-match-finders=hc3,hc4,bt4
			# CRC64 is used by default, though some (old?) files use CRC32
			--enable-checks=crc32,crc64
		)
	fi

	if [[ ${CHOST} == *-solaris* ]] ; then
		# undo Solaris-based defaults pointing to /usr/xpg5/bin
		myconf+=( --disable-path-for-script )
		export gl_cv_posix_shell=${EPREFIX}/bin/sh
	fi

	use elibc_FreeBSD && export ac_cv_header_sha256_h=no #545714
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install() {
	default

	gen_usr_ldscript -a lzma

	insinto ${_sysconfdir}/profile.d
	doins "${WORKDIR}"/colorxzgrep.{sh,csh}
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete || die
	rm "${ED}"/usr/share/doc/${PF}/COPYING* || die
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/liblzma$(get_libname 0)
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/liblzma$(get_libname 0)
}
