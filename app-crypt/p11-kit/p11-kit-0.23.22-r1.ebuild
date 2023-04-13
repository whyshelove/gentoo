# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal systemd rhel8

DESCRIPTION="Provides a standard configuration setup for installing PKCS#11"
HOMEPAGE="https://p11-glue.github.io/p11-glue/p11-kit.html"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="+asn1 debug +libffi systemd +trust"
REQUIRED_USE="trust? ( asn1 )"

RDEPEND="asn1? ( >=dev-libs/libtasn1-3.4:=[${MULTILIB_USEDEP}] )
	libffi? ( dev-libs/libffi:=[${MULTILIB_USEDEP}] )
	systemd? ( sys-apps/systemd:= )
	trust? ( app-misc/ca-certificates )"
DEPEND="${RDEPEND}
		dev-python/six"
BDEPEND="virtual/pkgconfig"

pkg_setup() {
	# disable unsafe tests, bug#502088
	export FAKED_MODE=1
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		$(use_enable trust trust-module) \
		$(use_with trust trust-paths "${EPREFIX}"/etc/ssl/certs/ca-certificates.crt) \
		$(use_enable debug) \
		$(use_with libffi) \
		$(use_with asn1 libtasn1) \
		$(multilib_native_use_with systemd)

	if multilib_is_native_abi; then
		# re-use provided documentation
		ln -s "${S}"/doc/manual/html doc/manual/html || die
	fi
}

multilib_src_install_all() {
	dodir /etc/pkcs11/modules ${_userunitdir}
	
	insinto ${_libexecdir}/p11-kit/
	insopts -m0755
	doins "${WORKDIR}"/trust-extract-compat

	systemd_douserunit "${WORKDIR}"/p11-kit-client.service

	einstalldocs
	find "${D}" -name '*.la' -delete || die
}
