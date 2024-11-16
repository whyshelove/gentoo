# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker rhel9

SRC_URI="${REPO_BIN}/r/redhat-release-${PV}-0.6.${DIST}.x86_64.rpm"

SRC_URI+=" ${REPO_BIN}/r/rootfiles-8.1-31.${DIST}.noarch.rpm"

crypto_policies="crypto-policies-scripts-20240828-2.git626aa59.el9_5.noarch.rpm"
SRC_URI+=" ${REPO_BIN}/c/${crypto_policies}"
SRC_URI+=" ${REPO_BIN}/c/${crypto_policies/-scripts}"

REPO_BIN="${REPO_BIN/baseos/appstream}"

SRC_URI+=" ${REPO_BIN}/e/efi-srpm-macros-6-2.el9_0.noarch.rpm"

for macro in kernel-rpm-macros-185-12 perl-srpm-macros-1-41 redhat-rpm-config-208-1 \
	python-qt5-rpm-macros-5.15.6-1 python-rpm-macros-3.9-54 python-srpm-macros-3.9-54 python3-rpm-macros-3.9-54 \
	go-srpm-macros-3.6.0-3 qt5-rpm-macros-5.15.3-1 rust-srpm-macros-17-4 ;
do
SRC_URI+=" ${REPO_BIN}/${macro:0:1}/${macro}.${DIST}.noarch.rpm"
done

REPO_BIN="${REPO_BIN/appstream/codeready-builder}"
SRC_URI+=" ${REPO_BIN}/r/redhat-sb-certs-9.4-0.4.${DIST}.noarch.rpm"

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
	rhel_bin_install

	insinto /etc/rhsm/ca
	doins "${FILESDIR}/redhat-uep.pem"

	insinto ${_sysconfdir}/crypto-policies
	newins "${FILESDIR}"/default-config config

	insinto ${_sysconfdir}/sandbox.d
	newins "${FILESDIR}"/28-sandbox 28rhel

	dodir /etc/pki/entitlement

	sed -i 's/_efi_vendor\ redhat/_efi_vendor\ gentoo/g' "${ED}"/${_rpmmacrodir}/macros.efi-srpm

	rm -rf "${ED}"/etc/{os-release,issue} "${ED}"/usr/lib/os-release
}

pkg_postinst() {
	DIR="${EROOT}/${_sysconfdir}/crypto-policies/back-ends"

	if [ "`ls -A ${DIR}`" = "" ]; then
		ln -s ${EROOT}/usr/share/crypto-policies ${EROOT}${_sysconfdir}/crypto-policies/back-ends/.config
		update-crypto-policies --no-check
	fi
}
