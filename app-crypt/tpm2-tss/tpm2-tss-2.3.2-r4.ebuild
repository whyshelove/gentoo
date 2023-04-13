# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools linux-info tmpfiles udev rhel8

DESCRIPTION="TCG Trusted Platform Module 2.0 Software Stack"
HOMEPAGE="https://github.com/tpm2-software/tpm2-tss"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="doc gcrypt +openssl static-libs test"

RESTRICT="!test? ( test )"

REQUIRED_USE="^^ ( gcrypt openssl )"

RDEPEND="acct-group/tss
	acct-user/tss
	gcrypt? ( dev-libs/libgcrypt:0= )
	openssl? ( dev-libs/openssl:0= )"
DEPEND="${RDEPEND}
	test? ( dev-util/cmocka )"
BDEPEND="virtual/pkgconfig
	doc? ( app-doc/doxygen )"

pkg_setup() {
	local CONFIG_CHECK=" \
		~TCG_TPM
	"
	linux-info_pkg_setup
	kernel_is ge 4 12 0 || ewarn "At least kernel 4.12.0 is required"
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--localstatedir=/var \
		$(use_enable doc doxygen-doc) \
		$(use_enable static-libs static) \
		$(use_enable test unit) \
		--disable-tcti-mssim \
		--disable-defaultflags \
		--disable-weakcrypto \
		--with-crypto="$(usex gcrypt gcrypt ossl)" \
		--with-udevrulesdir="$(get_udevdir)/rules.d" \
		--with-udevrulesprefix=60-

	# This is to fix Rpath errors. Taken from https://fedoraproject.org/wiki/Packaging:Guidelines#Removing_Rpath
	sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
	sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
