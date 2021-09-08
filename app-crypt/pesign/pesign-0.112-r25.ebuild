# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs rhel8-a

SRC_URI="!binary? ( ${REPO_URI}/${MY_PF}.${DIST}.src.rpm )
        binary? ( ${REPO_BIN}/${MY_PF}.${DIST}.x86_64.rpm )"
DESCRIPTION="Tools for manipulating signed PE-COFF binaries"
HOMEPAGE="https://github.com/rhboot/pesign"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="+binary"

RDEPEND="dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0=
	dev-libs/popt
	sys-apps/util-linux
	sys-libs/efivar
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-apps/help2man
	sys-boot/gnu-efi
	virtual/pkgconfig
"

pkg_setup() {
	export conf="PREFIX=${EPREFIX}/usr LIBDIR=${EPREFIX}/usr/$(get_libdir)"
}

src_unpack() {
	rhel_unpack 
	rpmbuild -bb $WORKDIR/*.spec --nodeps
}

src_prepare() {
	if use binary; then
		eapply_user
	else
        default
    fi
}

src_compile() {
	append-cflags -O1 #721934
	use binary && return
	emake AR="$(tc-getAR)" \
		ARFLAGS="-cvqs" \
		AS="$(tc-getAS)" \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		OBJCOPY="$(tc-getOBJCOPY)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		RANLIB="$(tc-getRANLIB)" \
		$conf
}

src_install() {
	rhel_bin_install && return

	dodir ${_libdir}
	emake $conf INSTALLROOT=${D} \
		install
	emake $conf INSTALLROOT=${D} \
		install_systemd
	# there's some stuff that's not really meant to be shipped yet
	rm -rf ${D}/boot ${D}/usr/include
	rm -rf ${D}${_libdir}/libdpe*

	insinto /etc/pki/pesign && doins -r etc/pki/pesign/*
	insinto /etc/pki/pesign-rh-test && doins -r etc/pki/pesign-rh-test/*

	# remove some files that don't make sense for Gentoo installs
	rm -rf "${ED}/var" "${ED}/usr/share/doc/${PF}/COPYING" || die
	insopts -m0755 && insinto /usr/lib/python3.6/site-packages/mockbuild/plugins/
	doins $WORKDIR/pesign.py
}

pkg_preinst() {
	getent group pesign >/dev/null || groupadd -r pesign
	getent passwd pesign >/dev/null || \
		useradd -r -g pesign -d /run/pesign -s /sbin/nologin \
			-c "Group for the pesign signing daemon" pesign
}
pkg_postinst() {
	systemd_post pesign.service
}

pkg_prerm() {
	systemd_preun pesign.service
}
