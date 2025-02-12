# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_REQ_USE="sqlite"
PYTHON_COMPAT=( python3_{6,8,9} )

GIT_COMMIT=bb1bba3d77
WhatArch=noarch

DSUFFIX="_10.4"

suffix_ver=$(ver_cut 3)
[[ ${suffix_ver} ]] && DSUFFIX="_10.${suffix_ver}"

inherit python-any-r1 readme.gentoo-r1 rhel8-a

DESCRIPTION="UEFI firmware for 64-bit x86 virtual machines"
HOMEPAGE="https://github.com/tianocore/edk2"

BUNDLED_OPENSSL_SUBMODULE_SHA="e2e09d9fba1187f8d6aafaa34d4172f56f1ffb72"
BUNDLED_BROTLI_SUBMODULE_SHA="666c3280cc11dc433c303d79a83d4ffbdd12cc8d"

# TODO: talk with tamiko about unbundling (mva)

# TODO: the binary 202105 package currently lacks the preseeded
#       OVMF_VARS.secboot.fd file (that we typically get from fedora)

SRC_URI="
	!binary? (
		${SRC_URI/-ovmf}
		https://github.com/openssl/openssl/archive/${BUNDLED_OPENSSL_SUBMODULE_SHA}.tar.gz -> openssl-${BUNDLED_OPENSSL_SUBMODULE_SHA}.tar.gz
		https://github.com/google/brotli/archive/${BUNDLED_BROTLI_SUBMODULE_SHA}.tar.gz -> brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}.tar.gz
	)
	binary? ( ${BIN_URI} )
"

LICENSE="BSD-2 MIT"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"

IUSE="+binary"
REQUIRED_USE+="
	!amd64? ( binary )
"

NON_BINARY_DEPEND="
	app-emulation/qemu
	>=dev-lang/nasm-2.0.7
	>=sys-power/iasl-20160729
	${PYTHON_DEPS}
"

DEPEND+="
	!binary? (
		amd64? (
			${NON_BINARY_DEPEND}
		)
	)"
RDEPEND=""

PATCHES=(
)

S="${WORKDIR}/edk2-${GITCOMMIT}"

DISABLE_AUTOFORMATTING=true
DOC_CONTENTS="This package contains the tianocore edk2 UEFI firmware for 64-bit x86
virtual machines. The firmware is located under
	/usr/share/edk2-ovmf/OVMF_CODE.fd
	/usr/share/edk2-ovmf/OVMF_VARS.fd
	/usr/share/edk2-ovmf/OVMF_CODE.secboot.fd

If USE=binary is enabled, we also install an OVMF variables file (coming from
fedora) that contains secureboot default keys

	/usr/share/edk2-ovmf/OVMF_VARS.secboot.fd

If you have compiled this package by hand, you need to either populate all
necessary EFI variables by hand by booting
	/usr/share/edk2-ovmf/UefiShell.(iso|img)
or creating OVMF_VARS.secboot.fd by hand:
	https://github.com/puiterwijk/qemu-ovmf-secureboot

The firmware does not support csm (due to no free csm implementation
available). If you need a firmware with csm support you have to download
one for yourself. Firmware blobs are commonly labeled
	OVMF{,_CODE,_VARS}-with-csm.fd

In order to use the firmware you can run qemu the following way

	$ qemu-system-x86_64 \
		-drive file=/usr/share/edk2-ovmf/OVMF.fd,if=pflash,format=raw,unit=0,readonly=on \
		..."

pkg_setup() {
	[[ ${PV} != "999999" ]] && use binary || python-any-r1_pkg_setup
}

src_prepare() {
	if use binary; then
		eapply_user
	else
		# Bundled submodules
		cp -rl "${WORKDIR}/openssl-${BUNDLED_OPENSSL_SUBMODULE_SHA}"/* "CryptoPkg/Library/OpensslLib/openssl/"
		cp -rl "${WORKDIR}/brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}"/* "BaseTools/Source/C/BrotliCompress/brotli/"
		cp -rl "${WORKDIR}/brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}"/* "MdeModulePkg/Library/BrotliCustomDecompressLib/brotli/"

		sed -i -r \
			-e "/function SetupPython3/,/\}/{s,\\\$\(whereis python3\),${EPYTHON},g}" \
			"${S}"/edksetup.sh || die "Fixing for correct Python3 support failed"

		default
	fi
}

src_compile() {
	use binary && return
	export PYTHON_COMMAND=${EPYTHON}

	TARGET_ARCH=X64
	TARGET_NAME=RELEASE
	TARGET_TOOLS=GCC5

	# Build with neither SB nor SMM; include UEFI shell.

	CC_FLAGS="--cmd-len=65536 -t ${TARGET_TOOLS} -b DEBUG --hash \
		-D NETWORK_IP6_ENABLE \
		-D NETWORK_HTTP_BOOT_ENABLE \
		-D NETWORK_TLS_ENABLE"

	BUILD_FLAGS="-D TLS_ENABLE \
		-D HTTP_BOOT_ENABLE \
		${CC_FLAGS} \
		-D TPM_ENABLE \
		-D FD_SIZE_4MB -a X64 \
		-D PVSCSI_ENABLE=FALSE -D MPT_SCSI_ENABLE=FALSE \
		-p OvmfPkg/OvmfPkgX64.dsc \
		-D TPM2_ENABLE -D TPM2_CONFIG_ENABLE"

	SECUREBOOT_BUILD_FLAGS="${CC_FLAGS} \
		-D SECURE_BOOT_ENABLE -D EXCLUDE_SHELL_FROM_FD \
		-a IA32 -a X64 -p OvmfPkg/OvmfPkgIa32X64.dsc -D SMM_REQUIRE \
		-D PVSCSI_ENABLE=FALSE -D MPT_SCSI_ENABLE=FALSE \
		-D TPM_ENABLE -D FD_SIZE_4MB"

	[[ ${PV} != "999999" ]] && use binary && return

	emake ARCH=${TARGET_ARCH} -C BaseTools

	. ./edksetup.sh

	# Build all EFI firmware blobs:

	mkdir -p ovmf

	./OvmfPkg/build.sh \
		-a "${TARGET_ARCH}" -b "${TARGET_NAME}" -t "${TARGET_TOOLS}" \
		${BUILD_FLAGS} || die "OvmfPkg/build.sh failed"

	cp Build/OvmfX64/*/FV/OVMF_*.fd ovmf/
	rm -rf Build/OvmfX64

	./OvmfPkg/build.sh \
		-a "${TARGET_ARCH}" -b "${TARGET_NAME}" -t "${TARGET_TOOLS}" \
		${SECUREBOOT_BUILD_FLAGS} || die "OvmfPkg/build.sh failed"

	cp Build/OvmfX64/*/FV/OVMF_CODE.fd ovmf/OVMF_CODE.secboot.fd || die "cp failed"
	cp Build/OvmfX64/*/X64/Shell.efi ovmf/ || die "cp failed"
	cp Build/OvmfX64/*/X64/EnrollDefaultKeys.efi ovmf || die "cp failed"

	# Build a convenience UefiShell.img:

	mkdir -p iso_image/efi/boot || die "mkdir failed"
	cp ovmf/Shell.efi iso_image/efi/boot/bootx64.efi || die "cp failed"
	cp ovmf/EnrollDefaultKeys.efi iso_image || die "cp failed"
	qemu-img convert --image-opts \
		driver=vvfat,floppy=on,fat-type=12,label=UEFI_SHELL,dir=iso_image \
		ovmf/UefiShell.img || die "qemu-img failed"
}

src_install() {
	if use binary; then
		mv "${WORKDIR}"/* "${ED}"/
		mv "${ED}"/edk2-${GITCOMMIT} "${WORKDIR}"/

		return
	fi

	insinto /usr/share/${PN}
	doins ovmf/*

	insinto /usr/share/qemu/firmware
	doins qemu/*
	rm "${ED}"/usr/share/qemu/firmware/40-edk2-ovmf-x64-sb-enrolled.json || die "rm failed"

	readme.gentoo_create_doc
}

pkg_postinst() {
	use binary && return
	readme.gentoo_print_elog
}
