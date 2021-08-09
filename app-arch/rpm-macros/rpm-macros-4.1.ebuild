# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils rpm

BaseOS="http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages"
AppStream="http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages"
SRC_URI="${SRC_URI} ${BaseOS}/rootfiles-8.1-22.el8.noarch.rpm"
SRC_URI="${SRC_URI} ${AppStream}/python36-rpm-macros-3.6.8-37.module_el8.5.0+771+e5d9a225.noarch.rpm"
SRC_URI="${SRC_URI} ${AppStream}/python38-rpm-macros-3.8.8-2.module_el8.5.0+765+e829a51d.noarch.rpm"
SRC_URI="${SRC_URI} ${AppStream}/python2-rpm-macros-3-38.module_el8.5.0+743+cd2f5d28.noarch.rpm"

for macro in efi-srpm-macros-3-3 perl-srpm-macros-1-25 redhat-rpm-config-125-1 \
	python-qt5-rpm-macros-5.15.0-2 python-rpm-macros-3-41 python-srpm-macros-3-41 python3-rpm-macros-3-41 \
	qt5-rpm-macros-5.12.5-3 qt5-srpm-macros-5.12.5-3 ;
do
SRC_URI="${SRC_URI} ${AppStream}/${macro}.el8.noarch.rpm"
done

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="app-arch/rpm[lua,python]"
DEPEND="${RDEPEND}"
BDEPEND=""

src_unpack() {
	unpack ${FILESDIR}/rpmrc.tar.xz
	rpm_unpack ${A} && mkdir $S
}

src_install() {
	rm -rf $D $S
	ln -s ${WORKDIR} ${PORTAGE_BUILDDIR}/image
	rm -rf $D/usr/lib/.build-id
}
