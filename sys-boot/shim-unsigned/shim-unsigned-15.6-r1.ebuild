# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rhel8-p

DESCRIPTION="Initial UEFI bootloader that handles chaining to a trusted full bootloader
under secure boot environments. This package contains the version unsigned."
HOMEPAGE="https://github.com/rhboot/shim"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
IUSE="ia32"
REQUIRED_USE="ia32? ( ^^ ( amd64 x86 ) )"
RDEPEND="${DEPEND}"
DEPEND="sys-devel/gcc
	sys-devel/make
	dev-libs/elfutils
	dev-vcs/git
	dev-libs/openssl
	>=app-crypt/pesign-0.106
	app-text/dos2unix
	sys-apps/findutils
"

pkg_setup() {
	efidir=$(eval echo $(grep ^ID= /etc/os-release | sed -e 's/^ID=//'))
	shimrootdir=${_datadir}/shim/

	case ${ARCH} in
		amd64) efiarch=x64 ;;
		arm64) efiarch=aa64 ;;
		*)     die "unsupported architecture: ${ARCH}" ;;
	esac

	use ia32 && efialtarch=ia32

   	S1="${WORKDIR}/redhatsecurebootca5.cer"
  	S2="${WORKDIR}/dbx.esl"
}

src_configure() { 
	COMMITID=$(cat commit)
	MAKEFLAGS="TOPDIR=.. -f ../Makefile COMMITID=${COMMITID} "
	MAKEFLAGS+="EFIDIR=${efidir} "
	MAKEFLAGS+="ENABLE_SHIM_HASH=true "

	if [ -f "${S1}" ]; then
		MAKEFLAGS="$MAKEFLAGS VENDOR_CERT_FILE=${S1}"
	fi

	if [ -s "${S2}" ]; then
		MAKEFLAGS="$MAKEFLAGS VENDOR_DBX_FILE=${S2}"
	fi
}

src_compile() {
	unset ARCH

	cd build-${efiarch}
	emake ${MAKEFLAGS} all

	if use ia32 ; then
		cd ../build-${efialtarch}
		setarch linux32 -B make ${MAKEFLAGS} ARCH=${efialtarch} all
	fi
}

src_install() {
	MAKEFLAGS+="ENABLE_HTTPBOOT=true "

	cd build-${efiarch}
	make ${MAKEFLAGS} \
		DESTDIR="${ED}" \
		install-as-data install-debuginfo install-debugsource


	if use ia32 ; then
		cd ../build-${efialtarch}
		setarch linux32 make ${MAKEFLAGS} ARCH=${efialtarch} \
			DESTDIR="${ED}" \
			install-as-data install-debuginfo install-debugsource
	fi

	rm -rf "${ED}"/usr/{lib,src} || die
}
