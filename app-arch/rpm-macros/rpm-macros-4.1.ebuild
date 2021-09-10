# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker rhel8

SRC_URI=""

for macro in centos-stream-release-8.5-2 rootfiles-8.1-22 ;
do
SRC_URI="${SRC_URI} ${REPO_BIN}/${macro}.${DIST}.noarch.rpm"
done

inherit rhel8-a

SRC_URI="${SRC_URI} ${REPO_BIN}/python2-rpm-macros-3-38.module_el8.5.0+743+cd2f5d28.noarch.rpm"
SRC_URI="${SRC_URI} ${REPO_BIN}/python36-rpm-macros-3.6.8-37.module_el8.5.0+771+e5d9a225.noarch.rpm"

for macro in efi-srpm-macros-3-3 perl-srpm-macros-1-25 kernel-rpm-macros-125-1 redhat-rpm-config-125-1 \
	python-qt5-rpm-macros-5.15.0-2 python-rpm-macros-3-41 python-srpm-macros-3-41 python3-rpm-macros-3-41 \
	go-srpm-macros-2-17 qt5-rpm-macros-5.12.5-3 rust-srpm-macros-5-2 ;
do
SRC_URI="${SRC_URI} ${REPO_BIN}/${macro}.${DIST}.noarch.rpm"
done

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="+binary"

RDEPEND="app-arch/rpm[lua,python]"
DEPEND="${RDEPEND}"
BDEPEND=""

src_install() {
	rhel_bin_install
	rm -rf $D/etc/{os-release,issue}
}
