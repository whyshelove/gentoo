# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker rhel9

SRC_URI="${REPO_BIN}/r/redhat-release-${PV}-1.9.${DIST}.x86_64.rpm"
SRC_URI+=" ${REPO_BIN}/r/rootfiles-8.1-31.${DIST}.noarch.rpm"

REPO_BIN="${REPO_BIN/baseos/appstream}"

SRC_URI+=" ${REPO_BIN}/e/efi-srpm-macros-6-2.el9_0.noarch.rpm"

for macro in kernel-rpm-macros-185-11 perl-srpm-macros-1-41 redhat-rpm-config-196-1 \
	python-qt5-rpm-macros-5.15.6-1 python-rpm-macros-3.9-52 python-srpm-macros-3.9-52 python3-rpm-macros-3.9-52 \
	go-srpm-macros-3.0.9-9 qt5-rpm-macros-5.15.3-1 rust-srpm-macros-17-4 ;
do
SRC_URI+=" ${REPO_BIN}/${macro:0:1}/${macro}.${DIST}.noarch.rpm"
done

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE="+binary"

RDEPEND="app-arch/rpm[lua,python]"
DEPEND="${RDEPEND}"
BDEPEND=""

src_install() {
	insinto /etc/rhsm/ca
	doins "${FILESDIR}/redhat-uep.pem"

	dodir /etc/pki/entitlement

	rhel_bin_install
	rm -rf $D/etc/{os-release,issue}
	rm -rf $D/usr/lib/os-release
}
