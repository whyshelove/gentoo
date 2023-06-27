# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

suffix_ver=$(ver_cut 4)
[[ ${suffix_ver} ]] && DSUFFIX="_${suffix_ver}"
DSUFFIX="_1"
_build_flags="undefine"

inherit toolchain-funcs tmpfiles rhel9-a

DESCRIPTION="This package contains the pesign utility for signing UEFI binaries as
well as other associated tools."
HOMEPAGE="https://github.com/rhboot/pesign"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE=""

RDEPEND="dev-libs/nspr
	dev-libs/nss[utils]
	dev-libs/openssl:0=
	dev-libs/popt
	sys-apps/util-linux
	>=sys-libs/efivar-38
"
DEPEND="${RDEPEND}
	sys-boot/gnu-efi
"
BDEPEND="
	sys-apps/help2man
	virtual/pkgconfig
"

pkg_setup() {
	export conf="PREFIX=${EPREFIX}/usr LIBDIR=${EPREFIX}/usr/$(get_libdir)"
	export MAKEOPTS="-j1"
}

src_compile() {
	filter-flags -O*

	#append-ldflags -Wl,-fuse-ld=bfd or tc-ld-disable-gold
	tc-ld-disable-gold

	sed -e 's/nss-util\ //g' \
	    -e '/^CFLAGS/s/?=/+=/g' -i Make.defaults

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
	emake $conf INSTALLROOT="${ED}" \
		install
	emake $conf INSTALLROOT="${ED}" \
		install_systemd
	# there's some stuff that's not really meant to be shipped yet
	rm -rf "${ED}"/boot "${ED}"/usr/include
	rm -rf "${ED}"${_libdir}/libdpe*

	diropts -m755
	dodir /etc/pki/pesign{,-rh-test}

	insinto /etc/pki/pesign
	doins  etc/pki/pesign/*

	insinto /etc/pki/pesign-rh-test
	doins etc/pki/pesign-rh-test/*

	insinto ${_rpmmacrodir}
	doins "${ED}"${_sysconfdir}/rpm/macros.pesign

	# remove some files that don't make sense for Gentoo installs
	rm -rf "${ED}/usr/share/doc/${PF}/COPYING" "${ED}${_sysconfdir}/rpm" || die

	#insinto /usr/lib/python3.6/site-packages/mockbuild/plugins
	#doins $WORKDIR/pesign.py
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
