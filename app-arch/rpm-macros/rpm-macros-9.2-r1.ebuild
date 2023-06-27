# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker rhel9

SRC_URI="${REPO_BIN}/r/redhat-release-${PV}-0.13.${DIST}.x86_64.rpm"
SRC_URI+=" ${REPO_BIN}/r/rootfiles-8.1-31.${DIST}.noarch.rpm"

REPO_BIN="${REPO_BIN/baseos/appstream}"

SRC_URI+=" ${REPO_BIN}/e/efi-srpm-macros-6-2.el9_0.noarch.rpm"

for macro in kernel-rpm-macros-185-12 perl-srpm-macros-1-41 redhat-rpm-config-199-1 \
	python-qt5-rpm-macros-5.15.6-1 python-rpm-macros-3.9-52 python-srpm-macros-3.9-52 python3-rpm-macros-3.9-52 \
	go-srpm-macros-3.2.0-1 qt5-rpm-macros-5.15.3-1 rust-srpm-macros-17-4 ;
do
SRC_URI+=" ${REPO_BIN}/${macro:0:1}/${macro}.${DIST}.noarch.rpm"
done

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""

RDEPEND="app-arch/rpm[lua,python]"
DEPEND="${RDEPEND}"
BDEPEND=""

src_install() {
	QLIST="enable"

	rhel_bin_install

	insinto /etc/rhsm/ca
	doins "${FILESDIR}/redhat-uep.pem"

	dodir /etc/pki/entitlement

	sed -i 's/_efi_vendor\ redhat/_efi_vendor\ gentoo/g' "${ED}"/${_rpmmacrodir}/macros.efi-srpm

	rm -rf "${ED}"/etc/{os-release,issue} "${ED}"/usr/lib/os-release
}
