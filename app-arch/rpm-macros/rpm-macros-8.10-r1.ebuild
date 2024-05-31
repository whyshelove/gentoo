# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker rhel8

SRC_URI="${REPO_BIN}/r/redhat-release-${PV}-0.2.${DIST}.x86_64.rpm"
SRC_URI+=" ${REPO_BIN}/r/rootfiles-8.1-22.${DIST}.noarch.rpm"

crypto_policies="crypto-policies-scripts-20230731-1.git3177e06.${DIST}.noarch.rpm"
SRC_URI+=" ${REPO_BIN}/c/${crypto_policies}"
SRC_URI+=" ${REPO_BIN}/c/${crypto_policies/-scripts}"

REPO_BIN="${REPO_BIN/baseos/appstream}"

SRC_URI+=" ${REPO_BIN}/p/python2-rpm-macros-3-38.module+el8.1.0+3111+de3f2d8e.noarch.rpm"
SRC_URI+=" ${REPO_BIN}/p/python36-rpm-macros-3.6.8-38.module+el8.5.0+12207+5c5719bc.noarch.rpm"

for macro in efi-srpm-macros-3-3 perl-srpm-macros-1-25 kernel-rpm-macros-130-1 redhat-rpm-config-131-1 \
	python-qt5-rpm-macros-5.15.0-3 python-rpm-macros-3-45 python-srpm-macros-3-45 python3-rpm-macros-3-45 \
	go-srpm-macros-2-17 qt5-rpm-macros-5.15.3-1 rust-srpm-macros-5-2 ;
do
SRC_URI+=" ${REPO_BIN}/${macro:0:1}/${macro}.${DIST}.noarch.rpm"
done

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""

RDEPEND="app-arch/rpm[lua,python]
	dev-vcs/git
	sys-libs/libselinux"
DEPEND="${RDEPEND}"
BDEPEND=""

src_install() {
	QLIST="enable"

	rhel_bin_install

	insinto /etc/rhsm/ca
	doins "${FILESDIR}/redhat-uep.pem"

	insinto ${_sysconfdir}/sandbox.d
	newins "${FILESDIR}"/28-sandbox 28rhel

	dodir /etc/pki/entitlement

	sed -i 's/_efi_vendor\ redhat/_efi_vendor\ gentoo/g' "${ED}"/${_rpmmacrodir}/macros.efi-srpm

	sed -i 's/usr\///g' "${ED}"/${_rpmconfigdir}/redhat/gpgverify

	rm -rf "${ED}"/etc/{os-release,issue} "${ED}"/usr/lib/os-release
}

pkg_postinst() {
	DIR="${EROOT}/${_sysconfdir}/crypto-policies/back-ends"

	if [ "`ls -A ${DIR}`" = "" ]; then
		update-crypto-policies --no-check
	fi
}
