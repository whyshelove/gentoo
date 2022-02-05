# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker rhel9

SRC_URI="${REPO_BIN}/centos-stream-release-${PVR/r}.${DIST}.noarch.rpm"
SRC_URI="${SRC_URI} ${REPO_BIN}/rootfiles-8.1-30.${DIST}.noarch.rpm"

REPO_BIN="${MIRROR_BIN}/${RELEASE}/AppStream/x86_64/os/Packages"

for macro in efi-srpm-macros-4-9 kernel-rpm-macros-185-7.el9 perl-srpm-macros-1-41 redhat-rpm-config-188-1 \
	python-qt5-rpm-macros-5.15.0-10 python-rpm-macros-3.9-43 python-srpm-macros-3.9-43 python3-rpm-macros-3.9-43 \
	go-srpm-macros-3.0.9-9 qt5-rpm-macros-5.15.2-9 rust-srpm-macros-17-4 ;
do
SRC_URI="${SRC_URI} ${REPO_BIN}/${macro}.${DIST}.noarch.rpm"
done

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE="+binary"

RDEPEND="app-arch/rpm[lua,python]"
DEPEND="${RDEPEND}"
BDEPEND=""

src_install() {
	rhel_bin_install
	rm -rf $D/etc/{os-release,issue}
	rm -rf $D/usr/lib/os-release
}
