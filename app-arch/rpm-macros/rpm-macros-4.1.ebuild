# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils rpm

BaseOS="https://odcs.stream.centos.org/production/latest-CentOS-Stream/compose/BaseOS/x86_64/os/Packages"
AppStream="https://odcs.stream.centos.org/production/latest-CentOS-Stream/compose/AppStream/x86_64/os/Packages/"
SRC_URI="${SRC_URI} ${BaseOS}/centos-stream-release-9.0-1.0.4.el9.noarch.rpm"
SRC_URI="${SRC_URI} ${BaseOS}/rootfiles-8.1-30.el9.noarch.rpm"

for macro in cmake-rpm-macros-3.20.2-6 efi-srpm-macros-4-7 perl-srpm-macros-1-40 redhat-rpm-config-187-1 \
	python-qt5-rpm-macros-5.15.0-9 python-rpm-macros-3.9-41 python-srpm-macros-3.9-41 python3-rpm-macros-3.9-41 \
	qt5-rpm-macros-5.15.2-8 qt5-srpm-macros-5.15.2-8 ;
do
SRC_URI="${SRC_URI} ${AppStream}/${macro}.el9.noarch.rpm"
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
	rm -rf $D/usr/lib/.build-id $D/etc/{os-release,issue}
}
