# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{6,8,9} )

DPREFIX="module+"
VER_COMMIT=16781+9f4724c2
DSUFFIX=".8.0+${VER_COMMIT}"
WhatArch=noarch

inherit toolchain-funcs python-any-r1 rhel8-a

# SeaBIOS maintainers sometimes don't release stable tarballs or stable
# binaries to generate the stable tarball the following is necessary:
# git clone git://git.seabios.org/seabios.git && cd seabios
# git archive --output seabios-${PV}.tar.gz --prefix seabios-${PV}/ rel-${PV}

if [[ ${PV} == *9999* || -n "${EGIT_COMMIT}" ]] ; then
	EGIT_REPO_URI="git://git.seabios.org/seabios.git"
	inherit git-r3
else
	KEYWORDS="~alpha amd64 arm64 ~loong ~m68k ~mips ~ppc ppc64 x86"
	SRC_URI="
		!binary? ( ${SRC_URI} )
		binary? ( ${BIN_URI/-/-bin-}
			${BIN_URI/bios/vgabios-bin} )"
fi

DESCRIPTION="Open Source implementation of a 16-bit x86 BIOS"
HOMEPAGE="https://www.seabios.org/"

LICENSE="LGPL-3 GPL-3"
SLOT="0"
IUSE="binary debug +seavgabios"

BDEPEND="
	>=sys-power/iasl-20060912
	${PYTHON_DEPS}"
RDEPEND="!sys-firmware/seabios-bin"

choose_target_chost() {
	if [[ -n "${CC}" ]]; then
		${CC} -dumpmachine
		return
	fi

	if use amd64 || use x86; then
		# Use the native compiler
		echo "${CHOST}"
		return
	fi

	local i
	for i in x86_64 i686 i586 i486 i386 ; do
		i=${i}-pc-linux-gnu
		type -P ${i}-gcc > /dev/null && echo ${i} && return
	done
}

pkg_pretend() {
	ewarn "You have decided to compile your own SeaBIOS. This is not"
	ewarn "supported by upstream unless you use their recommended"
	ewarn "toolchain (which you are not)."
	elog
	ewarn "If you are intending to use this build with QEMU, realize"
	ewarn "you will not receive any support if you have compiled your"
	ewarn "own SeaBIOS. Virtual machines subtly fail based on changes"
	ewarn "in SeaBIOS."
	if [[ -z "$(choose_target_chost)" ]]; then
		elog
		eerror "Before you can compile ${PN}, you need to install a x86 cross-compiler"
		eerror "Run the following commands:"
		eerror "  emerge crossdev"
		eerror "  crossdev --stable -t x86_64-pc-linux-gnu"
		die "cross-compiler is needed"
	fi
}


src_unpack() {
	rhel_src_unpack ${A}

	# This simplifies the logic between binary & source builds.
	mkdir -p "${S}"
}

src_configure() {
	use binary && return

	tc-ld-disable-gold #438058
	[[ $(tc-arch) == "amd64" ]] && export CFLAGS
	if use debug ; then
		echo "CONFIG_DEBUG_LEVEL=1" >.config
	fi
	_emake config
}

_emake() {
	LANG=C \
	emake -j1 V=1 \
		CPP="$(tc-getPROG CPP cpp)" \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		AR="$(tc-getAR)" \
		AS="$(tc-getAS)" \
		OBJCOPY="$(tc-getOBJCOPY)" \
		RANLIB="$(tc-getRANLIB)" \
		OBJDUMP="$(tc-getOBJDUMP)" \
		STRIP="$(tc-getSTRIP)" \
		HOST_CC="$(tc-getBUILD_CC)" \
		VERSION="Gentoo/${EGIT_COMMIT:-${PVR}}" \
		"$@"
}

build_bios() {
    _emake PYTHON=${PYTHON} clean distclean
    cp $1 .config || die
    _emake PYTHON=${PYTHON} oldnoconfig

    CHOST="${TARGET_CHOST}" _emake PYTHON=${PYTHON} $4

    mv out/$2 ../$3 || die
}

src_compile() {
	local TARGET_CHOST=$(choose_target_chost)

	build_bios ${WORKDIR}/config.seabios-128k bios.bin bios.bin
	build_bios ${WORKDIR}/config.seabios-256k bios.bin bios-256k.bin

	if use seavgabios ; then
		local config vgaconfigs=(
			cirrus
			qxl
			stdvga
			virtio
			ramfb
			bochs-display
		)
		for config in "${vgaconfigs[@]}" ; do
		    build_bios ${WORKDIR}/config.vga.${config} \
			       vgabios.bin vgabios-${config}.bin out/vgabios.bin
		done
	fi
}

src_install() {
	use binary && rhel_bin_install && return

	insinto /usr/share/seabios
	doins ../bios.bin
	doins ../bios-256k.bin

	if use seavgabios ; then
		insinto /usr/share/seavgabios
		doins ../vgabios*.bin
	fi
}
