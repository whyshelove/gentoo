# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Autogenerated by pycargoebuild 0.6.3

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..11} )

CRATES="
	adler-1.0.2
	aes-0.7.5
	aho-corasick-0.7.20
	anes-0.1.6
	anstream-0.2.6
	anstyle-0.3.5
	anstyle-parse-0.1.1
	anstyle-wincon-0.2.0
	assert_approx_eq-1.1.0
	atty-0.2.14
	autocfg-1.1.0
	base64-0.13.1
	base64-0.21.0
	base64ct-1.6.0
	bit-set-0.5.3
	bit-vec-0.6.3
	bitflags-1.3.2
	block-buffer-0.10.4
	bumpalo-3.12.0
	byteorder-1.4.3
	bytes-1.4.0
	bzip2-0.4.4
	bzip2-sys-0.1.11+1.0.8
	cached-path-0.6.1
	cast-0.3.0
	cc-1.0.79
	cfg-if-1.0.0
	ciborium-0.2.0
	ciborium-io-0.2.0
	ciborium-ll-0.2.0
	cipher-0.3.0
	clap-3.2.23
	clap-4.2.1
	clap_builder-4.2.1
	clap_derive-4.2.0
	clap_lex-0.2.4
	clap_lex-0.4.1
	concolor-override-1.0.0
	concolor-query-0.3.3
	console-0.15.5
	constant_time_eq-0.1.5
	core-foundation-0.9.3
	core-foundation-sys-0.8.4
	cpufeatures-0.2.6
	crc32fast-1.3.2
	criterion-0.4.0
	criterion-plot-0.5.0
	crossbeam-channel-0.5.8
	crossbeam-deque-0.8.3
	crossbeam-epoch-0.9.14
	crossbeam-utils-0.8.15
	crypto-common-0.1.6
	darling-0.14.4
	darling_core-0.14.4
	darling_macro-0.14.4
	derive_builder-0.12.0
	derive_builder_core-0.12.0
	derive_builder_macro-0.12.0
	digest-0.10.6
	dirs-4.0.0
	dirs-sys-0.3.7
	either-1.8.1
	encode_unicode-0.3.6
	encoding_rs-0.8.32
	env_logger-0.7.1
	errno-0.3.1
	errno-dragonfly-0.1.2
	esaxx-rs-0.1.8
	fancy-regex-0.10.0
	fastrand-1.9.0
	filetime-0.2.21
	flate2-1.0.25
	fnv-1.0.7
	foreign-types-0.3.2
	foreign-types-shared-0.1.1
	form_urlencoded-1.1.0
	fs2-0.4.3
	futures-channel-0.3.28
	futures-core-0.3.28
	futures-io-0.3.28
	futures-sink-0.3.28
	futures-task-0.3.28
	futures-util-0.3.28
	generic-array-0.14.7
	getrandom-0.2.9
	glob-0.3.1
	h2-0.3.16
	half-1.8.2
	hashbrown-0.12.3
	heck-0.4.1
	hermit-abi-0.1.19
	hermit-abi-0.2.6
	hermit-abi-0.3.1
	hmac-0.12.1
	http-0.2.9
	http-body-0.4.5
	httparse-1.8.0
	httpdate-1.0.2
	humantime-1.3.0
	hyper-0.14.25
	hyper-tls-0.5.0
	ident_case-1.0.1
	idna-0.3.0
	indexmap-1.9.3
	indicatif-0.15.0
	indicatif-0.16.2
	indoc-1.0.9
	instant-0.1.12
	io-lifetimes-1.0.10
	ipnet-2.7.2
	is-terminal-0.4.7
	itertools-0.10.5
	itertools-0.8.2
	itertools-0.9.0
	itoa-1.0.6
	jobserver-0.1.26
	js-sys-0.3.61
	lazy_static-1.4.0
	libc-0.2.141
	linux-raw-sys-0.3.1
	lock_api-0.4.9
	log-0.4.17
	macro_rules_attribute-0.1.3
	macro_rules_attribute-proc_macro-0.1.3
	matrixmultiply-0.2.4
	matrixmultiply-0.3.2
	memchr-2.5.0
	memoffset-0.8.0
	mime-0.3.17
	minimal-lexical-0.2.1
	miniz_oxide-0.6.2
	mio-0.8.6
	monostate-0.1.6
	monostate-impl-0.1.6
	native-tls-0.2.11
	ndarray-0.13.1
	ndarray-0.15.6
	nom-7.1.3
	num-complex-0.2.4
	num-complex-0.4.3
	num-integer-0.1.45
	num-traits-0.2.15
	num_cpus-1.15.0
	number_prefix-0.3.0
	number_prefix-0.4.0
	numpy-0.18.0
	once_cell-1.17.1
	onig-6.4.0
	onig_sys-69.8.1
	oorandom-11.1.3
	opaque-debug-0.3.0
	openssl-0.10.50
	openssl-macros-0.1.1
	openssl-probe-0.1.5
	openssl-sys-0.9.85
	os_str_bytes-6.5.0
	parking_lot-0.12.1
	parking_lot_core-0.9.7
	password-hash-0.4.2
	paste-1.0.12
	pbkdf2-0.11.0
	percent-encoding-2.2.0
	pin-project-lite-0.2.9
	pin-utils-0.1.0
	pkg-config-0.3.26
	plotters-0.3.4
	plotters-backend-0.3.4
	plotters-svg-0.3.3
	ppv-lite86-0.2.17
	proc-macro2-1.0.56
	pyo3-0.18.2
	pyo3-build-config-0.18.2
	pyo3-ffi-0.18.2
	pyo3-macros-0.18.2
	pyo3-macros-backend-0.18.2
	quick-error-1.2.3
	quote-1.0.26
	rand-0.8.5
	rand_chacha-0.3.1
	rand_core-0.6.4
	rawpointer-0.2.1
	rayon-1.7.0
	rayon-cond-0.1.0
	rayon-core-1.11.0
	redox_syscall-0.2.16
	redox_syscall-0.3.5
	redox_users-0.4.3
	regex-1.7.3
	regex-syntax-0.6.29
	reqwest-0.11.16
	rustc-hash-1.1.0
	rustix-0.37.11
	ryu-1.0.13
	same-file-1.0.6
	schannel-0.1.21
	scopeguard-1.1.0
	security-framework-2.8.2
	security-framework-sys-2.8.0
	serde-1.0.159
	serde_derive-1.0.159
	serde_json-1.0.95
	serde_urlencoded-0.7.1
	sha1-0.10.5
	sha2-0.10.6
	slab-0.4.8
	smallvec-1.10.0
	socket2-0.4.9
	spm_precompiled-0.1.4
	strsim-0.10.0
	subtle-2.4.1
	syn-1.0.109
	syn-2.0.13
	tar-0.4.38
	target-lexicon-0.12.6
	tempfile-3.5.0
	termcolor-1.2.0
	textwrap-0.16.0
	thiserror-1.0.40
	thiserror-impl-1.0.40
	time-0.3.20
	time-core-0.1.0
	tinytemplate-1.2.1
	tinyvec-1.6.0
	tinyvec_macros-0.1.1
	tokio-1.27.0
	tokio-native-tls-0.3.1
	tokio-util-0.7.7
	tower-service-0.3.2
	tracing-0.1.37
	tracing-core-0.1.30
	try-lock-0.2.4
	typenum-1.16.0
	unicode-bidi-0.3.13
	unicode-ident-1.0.8
	unicode-normalization-0.1.22
	unicode-normalization-alignments-0.1.12
	unicode-segmentation-1.10.1
	unicode-width-0.1.10
	unicode_categories-0.1.1
	unindent-0.1.11
	url-2.3.1
	utf8parse-0.2.1
	vcpkg-0.2.15
	version_check-0.9.4
	walkdir-2.3.3
	want-0.3.0
	wasi-0.11.0+wasi-snapshot-preview1
	wasm-bindgen-0.2.84
	wasm-bindgen-backend-0.2.84
	wasm-bindgen-futures-0.4.34
	wasm-bindgen-macro-0.2.84
	wasm-bindgen-macro-support-0.2.84
	wasm-bindgen-shared-0.2.84
	web-sys-0.3.61
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-util-0.1.5
	winapi-x86_64-pc-windows-gnu-0.4.0
	windows-sys-0.42.0
	windows-sys-0.45.0
	windows-sys-0.48.0
	windows-targets-0.42.2
	windows-targets-0.48.0
	windows_aarch64_gnullvm-0.42.2
	windows_aarch64_gnullvm-0.48.0
	windows_aarch64_msvc-0.42.2
	windows_aarch64_msvc-0.48.0
	windows_i686_gnu-0.42.2
	windows_i686_gnu-0.48.0
	windows_i686_msvc-0.42.2
	windows_i686_msvc-0.48.0
	windows_x86_64_gnu-0.42.2
	windows_x86_64_gnu-0.48.0
	windows_x86_64_gnullvm-0.42.2
	windows_x86_64_gnullvm-0.48.0
	windows_x86_64_msvc-0.42.2
	windows_x86_64_msvc-0.48.0
	winreg-0.10.1
	xattr-0.2.3
	zip-0.6.4
	zstd-0.11.2+zstd.1.5.2
	zstd-safe-5.0.2+zstd.1.5.2
	zstd-sys-2.0.8+zstd.1.5.5
"

inherit cargo distutils-r1

DESCRIPTION="Implementation of today's most used tokenizers"
HOMEPAGE="https://github.com/huggingface/tokenizers"
SRC_URI="
	https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz
	$(cargo_crate_uris)
"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD CC0-1.0 MIT
	Unicode-DFS-2016
"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

distutils_enable_tests pytest

src_unpack() {
	cargo_src_unpack
}

src_prepare() {
	default
	cd bindings/python
	distutils-r1_src_prepare
}

src_configure() {
	cd tokenizers
	cargo_src_configure
	cd ../bindings/python
	distutils-r1_src_configure
}

src_compile() {
	cd tokenizers
	cargo_src_compile
	cd ../bindings/python
	distutils-r1_src_compile
}

src_test() {
	cd tokenizers
	# Tests do not work
	#cargo_src_test
	cd ../bindings/python
	# Need dataset module
	#distutils-r1_src_test
}

src_install() {
	cd tokenizers
	cargo_src_install
	cd ../bindings/python
	distutils-r1_src_install
}
