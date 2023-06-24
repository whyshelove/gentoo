# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit mount-boot rhel8

DESCRIPTION="Initial UEFI bootloader that handles chaining to a trusted full bootloader
under secure boot environments. This package contains the version signed by
the UEFI signing service."
HOMEPAGE="https://github.com/rhboot/shim/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
RDEPEND="${DEPEND}"
DEPEND="sys-boot/mokutil
	sys-boot/dbxtool
	sys-boot/shim-unsigned
	>=app-crypt/pesign-0.112
"
pkg_setup() {
	ewarn "\033[33mYour separate efi partition must be mounted at /boot/efi.\033[0m"
	QLIST="enable"

	efi_arch=$(get_efi_arch)
	efi_vendor=$(eval echo $(grep ^ID= /etc/os-release | sed -e 's/^ID=//'))
	efi_esp_efi="/boot/efi/EFI"
	efi_esp_dir="${efi_esp_efi}/${efi_vendor}"

	bootcsv="${FILESDIR}/BOOT${efi_arch^^}.CSV"
	shimefi="${WORKDIR}/shim${efi_arch}.efi"
	shimdir="${_datadir}/shim/${PV}/${efi_arch}"
}

_hash() {
	pesign -i ${shimefi} -h -P > shim.hash
	read file0 hash0 < shim.hash
	read file1 hash1 < ${shimdir}/shim${efi_arch}.hash
	if ! [ "$hash0" = "$hash1" ]; then
		echo $hash0 vs $hash1
		die "Invalid signature!"
	fi
}	

distrosign() {
	cp -av ${shimdir}/${1}${efi_arch}.efi ${1}${efi_arch}-unsigned.efi
	_pesign ${1}${efi_arch}-unsigned.efi ${1}${efi_arch}-signed.efi

	if [[ ${1} == shim ]]; then
		mv ${1}${efi_arch}-signed.efi ${1}${efi_arch}-${efi_vendor}.efi

		if use arm64; then
			cp ${1}${efi_arch}-${efi_vendor}.efi ${1}${efi_arch}.efi	
		fi
	else
		mv ${1}${efi_arch}-signed.efi ${1}${efi_arch}.efi
	fi
}

src_compile() {
	#_hash
	cp ${shimefi} shim${efi_arch}.efi

	distrosign shim
	distrosign mm
	distrosign fb
}

src_install() {
	insopts -m0700
	insinto ${efi_esp_efi}/BOOT

	newins shim${efi_arch}.efi BOOT${efi_arch^^}.EFI
	doins fb${efi_arch}.efi

	rm -rf fb${efi_arch}.efi *-unsigned.efi

	insopts -m0700
	insinto ${efi_esp_dir}
	doins *.efi  ${bootcsv}
}
