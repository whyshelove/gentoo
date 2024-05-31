# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
#DSUFFIX="_$(ver_cut 5)"
suffix_ver=$(ver_cut 5)
[[ ${suffix_ver} ]] && DSUFFIX="_9.${suffix_ver}"

inherit autotools prefix multilib-minimal rhel8

DESCRIPTION="A Client that groks URLs"
HOMEPAGE="https://curl.haxx.se/"

LICENSE="curl"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="adns alt-svc brotli +ftp gnutls gopher hsts +http2 idn +imap ipv6 +kerberos ldap mbedtls metalink nss +openssl +pop3 +progress-meter rtmp samba +smtp ssh ssl sslv3 static-libs test telnet +tftp +threads winssl"
IUSE+=" curl_ssl_gnutls curl_ssl_mbedtls curl_ssl_nss +curl_ssl_openssl curl_ssl_winssl"
IUSE+=" elibc_Winnt"

# c-ares must be disabled for threads
# only one default ssl provider can be enabled
REQUIRED_USE="
	winssl? ( elibc_Winnt )
	threads? ( !adns )
	ssl? (
		^^ (
			curl_ssl_gnutls
			curl_ssl_mbedtls
			curl_ssl_nss
			curl_ssl_openssl
			curl_ssl_winssl
		)
	)"

# lead to lots of false negatives, bug #285669
RESTRICT="!test? ( test )"

RDEPEND="ldap? ( net-nds/openldap[${MULTILIB_USEDEP}] )
	brotli? ( app-arch/brotli:=[${MULTILIB_USEDEP}] )
	ssl? (
		gnutls? (
			net-libs/gnutls:0=[static-libs?,${MULTILIB_USEDEP}]
			dev-libs/nettle:0=[${MULTILIB_USEDEP}]
			app-misc/ca-certificates
		)
		mbedtls? (
			net-libs/mbedtls:0=[${MULTILIB_USEDEP}]
			app-misc/ca-certificates
		)
		openssl? (
			dev-libs/openssl:0=[sslv3(-)=,static-libs?,${MULTILIB_USEDEP}]
		)
		nss? (
			dev-libs/nss:0[${MULTILIB_USEDEP}]
			app-misc/ca-certificates
		)
	)
	http2? ( net-libs/nghttp2[${MULTILIB_USEDEP}] )
	idn? ( net-dns/libidn2:0=[static-libs?,${MULTILIB_USEDEP}] )
	adns? ( net-dns/c-ares:0[${MULTILIB_USEDEP}] )
	kerberos? ( >=virtual/krb5-0-r1[${MULTILIB_USEDEP}] )
	metalink? ( >=media-libs/libmetalink-0.1.1[${MULTILIB_USEDEP}] )
	rtmp? ( media-video/rtmpdump[${MULTILIB_USEDEP}] )
	ssh? ( net-libs/libssh2[${MULTILIB_USEDEP}] )
	sys-libs/zlib[${MULTILIB_USEDEP}]"

# Do we need to enforce the same ssl backend for curl and rtmpdump? Bug #423303
#	rtmp? (
#		media-video/rtmpdump
#		curl_ssl_gnutls? ( media-video/rtmpdump[gnutls] )
#		curl_ssl_openssl? ( media-video/rtmpdump[-gnutls,ssl] )
#	)

# ssl providers to be added:
# fbopenssl  $(use_with spnego)

DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig
	test? (
		sys-apps/diffutils
		dev-lang/perl
	)"

DOCS=( CHANGES README docs/{FEATURES.md,INTERNALS.md,FAQ,BUGS.md,CONTRIBUTE.md} )

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/curl/curlbuild.h
)

MULTILIB_CHOST_TOOLS=(
	/usr/bin/curl-config
)

PATCHES=(
	"${FILESDIR}"/${PN}-respect-cflags-3.patch
)

src_prepare() {
	default

	sed -i '/LD_LIBRARY_PATH=/d' configure.ac || die #382241
	sed -i '/CURL_MAC_CFLAGS/d' configure.ac || die #637252

	eprefixify curl-config.in
	eautoreconf
}

multilib_src_configure() {
	# avoid using rpath
	sed -e 's/^runpath_var=.*/runpath_var=/' \
    	    -e 's/^hardcode_libdir_flag_spec=".*"$/hardcode_libdir_flag_spec=""/' \
            -i build-{full,minimal}/libtool

	# We make use of the fact that later flags override earlier ones
	# So start with all ssl providers off until proven otherwise
	# TODO: in the future, we may want to add wolfssl (https://www.wolfssl.com/)
	local myconf=()

	myconf+=( --without-gnutls --without-mbedtls --without-nss --without-polarssl --without-ssl --without-winssl )
	myconf+=( --without-ca-fallback --with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt  )
	#myconf+=( --without-default-ssl-backend )
	if use ssl ; then
		if use gnutls || use curl_ssl_gnutls; then
			einfo "SSL provided by gnutls"
			myconf+=( --with-gnutls --with-nettle )
		fi
		if use mbedtls || use curl_ssl_mbedtls; then
			einfo "SSL provided by mbedtls"
			myconf+=( --with-mbedtls )
		fi
		if use nss || use curl_ssl_nss; then
			einfo "SSL provided by nss"
			myconf+=( --with-nss )
		fi
		if use openssl || use curl_ssl_openssl; then
			einfo "SSL provided by openssl"
			myconf+=( --with-ssl --with-ca-path="${EPREFIX}"/etc/ssl/certs )
		fi
		if use winssl || use curl_ssl_winssl; then
			einfo "SSL provided by Windows"
			myconf+=( --with-winssl )
		fi

		if use curl_ssl_gnutls; then
			einfo "Default SSL provided by gnutls"
			myconf+=( --with-default-ssl-backend=gnutls )
		elif use curl_ssl_mbedtls; then
			einfo "Default SSL provided by mbedtls"
			myconf+=( --with-default-ssl-backend=mbedtls )
		elif use curl_ssl_nss; then
			einfo "Default SSL provided by nss"
			myconf+=( --with-default-ssl-backend=nss )
		elif use curl_ssl_openssl; then
			einfo "Default SSL provided by openssl"
			myconf+=( --with-default-ssl-backend=openssl )
		elif use curl_ssl_winssl; then
			einfo "Default SSL provided by Windows"
			myconf+=( --with-default-ssl-backend=winssl )
		else
			eerror "We can't be here because of REQUIRED_USE."
		fi

	else
		einfo "SSL disabled"
	fi

	# These configuration options are organized alphabetically
	# within each category.  This should make it easier if we
	# ever decide to make any of them contingent on USE flags:
	# 1) protocols first.  To see them all do
	# 'grep SUPPORT_PROTOCOLS configure.ac'
	# 2) --enable/disable options second.
	# 'grep -- --enable configure | grep Check | awk '{ print $4 }' | sort
	# 3) --with/without options third.
	# grep -- --with configure | grep Check | awk '{ print $4 }' | sort

	myconf+=(
		--cache-file=../config.cache
		--enable-symbol-hiding
		$(use_enable alt-svc)
		--enable-crypto-auth
		--enable-dict
		--disable-ech
		--enable-file
		$(use_enable ftp)
		$(use_enable gopher)
		--enable-http
		$(use_enable imap)
		$(use_enable ldap)
		$(use_enable ldap ldaps)
		--disable-ntlm-wb
		$(use_enable pop3)
		--enable-rt
		--enable-rtsp
		$(use_enable samba smb)
		$(use_with ssh libssh2)
		$(use_enable smtp)
		$(use_enable telnet)
		$(use_enable tftp)
		--enable-tls-srp
		$(use_enable adns ares)
		--enable-cookies
		--enable-dateparse
		--enable-dnsshuffle
		--enable-doh
		--enable-hidden-symbols
		--enable-http-auth
		$(use_enable ipv6)
		--enable-largefile
		--enable-manual
		--enable-mime
		--enable-netrc
		--enable-proxy
		--disable-sspi
		$(use_enable static-libs static)
		$(use_enable threads threaded-resolver)
		$(use_enable threads pthreads)
		--disable-versioned-symbols
		--without-amissl
		--without-bearssl
		$(use_with brotli)
		--without-cyassl
		--without-darwinssl
		--without-fish-functions-dir
		$(use_with http2 nghttp2)
		--without-hyper
		$(use_with idn libidn2)
		$(use_with kerberos gssapi "${EPREFIX}"/usr)
		$(use_with metalink libmetalink)
		--without-libgsasl
		--without-libpsl
		$(use_with rtmp librtmp)
		--without-rustls
		--without-schannel
		--without-secure-transport
		--without-spnego
		--without-winidn
		--without-wolfssl
		--with-zlib
	)

	ECONF_SOURCE="${S}" \
	econf "${myconf[@]}"

	if ! multilib_is_native_abi; then
		# avoid building the client
		sed -i -e '/SUBDIRS/s:src::' Makefile || die
		sed -i -e '/SUBDIRS/s:scripts::' Makefile || die
	fi

	# Fix up the pkg-config file to be more robust.
	# https://github.com/curl/curl/issues/864
	local priv=() libs=()
	# We always enable zlib.
	libs+=( "-lz" )
	priv+=( "zlib" )
	if use http2; then
		libs+=( "-lnghttp2" )
		priv+=( "libnghttp2" )
	fi
	if use ssl && use curl_ssl_openssl; then
		libs+=( "-lssl" "-lcrypto" )
		priv+=( "openssl" )
	fi
	grep -q Requires.private libcurl.pc && die "need to update ebuild"
	libs=$(printf '|%s' "${libs[@]}")
	sed -i -r \
		-e "/^Libs.private/s:(${libs#|})( |$)::g" \
		libcurl.pc || die
	echo "Requires.private: ${priv[*]}" >> libcurl.pc
}

multilib_src_test() {
	multilib_is_native_abi && default_src_test
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete || die
	rm -rf "${ED}"/etc/ || die
}
