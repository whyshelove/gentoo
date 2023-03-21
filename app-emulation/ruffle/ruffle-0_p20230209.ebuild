# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	Inflector-0.11.4
	addr2line-0.19.0
	adler-1.0.2
	adler32-1.2.0
	ahash-0.7.6
	aho-corasick-0.7.20
	aliasable-0.1.3
	alsa-0.7.0
	alsa-sys-0.3.1
	android_system_properties-0.1.5
	anyhow-1.0.68
	approx-0.5.1
	arboard-3.2.0
	arrayref-0.3.6
	arrayvec-0.5.2
	arrayvec-0.7.2
	ash-0.37.2+1.3.238
	async-channel-1.8.0
	atk-sys-0.16.0
	atty-0.2.14
	autocfg-1.1.0
	backtrace-0.3.67
	base64-0.13.1
	base64-0.21.0
	bindgen-0.61.0
	bit-set-0.5.3
	bit-vec-0.6.3
	bit_field-0.10.1
	bitflags-1.3.2
	bitstream-io-1.6.0
	block-0.1.6
	block-buffer-0.10.3
	bstr-0.2.17
	bumpalo-3.12.0
	bytemuck-1.13.0
	bytemuck_derive-1.4.0
	byteorder-1.4.3
	bytes-1.3.0
	cairo-sys-rs-0.16.3
	calloop-0.10.5
	castaway-0.1.2
	cc-1.0.78
	cesu8-1.1.0
	cexpr-0.6.0
	cfg-expr-0.11.0
	cfg-if-0.1.10
	cfg-if-1.0.0
	chrono-0.4.23
	clang-sys-1.4.0
	clap-4.1.4
	clap_derive-4.1.0
	clap_lex-0.3.1
	clipboard-win-4.5.0
	cmake-0.1.49
	cocoa-0.24.1
	cocoa-foundation-0.1.0
	codespan-reporting-0.11.1
	color_quant-1.1.0
	colored-2.0.0
	com-rs-0.2.1
	combine-4.6.6
	concurrent-queue-2.1.0
	console-0.15.5
	console_error_panic_hook-0.1.7
	convert_case-0.6.0
	cookie-factory-0.3.2
	core-foundation-0.9.3
	core-foundation-sys-0.6.2
	core-foundation-sys-0.8.3
	core-graphics-0.22.3
	core-graphics-types-0.1.1
	core-text-19.2.0
	coreaudio-rs-0.11.2
	coreaudio-sys-0.2.11
	cpal-0.15.0
	cpufeatures-0.2.5
	crc-3.0.0
	crc-catalog-2.2.0
	crc32fast-1.3.2
	crossbeam-channel-0.5.6
	crossbeam-deque-0.8.2
	crossbeam-epoch-0.9.13
	crossbeam-utils-0.8.14
	crossfont-0.5.1
	crunchy-0.2.2
	crypto-common-0.1.6
	csv-1.1.6
	csv-core-0.1.10
	ctor-0.1.26
	cty-0.2.2
	curl-0.4.44
	curl-sys-0.4.59+curl-7.86.0
	cxx-1.0.87
	cxx-build-1.0.87
	cxxbridge-flags-1.0.87
	cxxbridge-macro-1.0.87
	darling-0.13.4
	darling-0.14.2
	darling_core-0.13.4
	darling_core-0.14.2
	darling_macro-0.13.4
	darling_macro-0.14.2
	dasp_sample-0.11.0
	data-encoding-2.3.3
	derive-try-from-primitive-1.0.0
	diff-0.1.13
	digest-0.10.6
	dirs-4.0.0
	dirs-sys-0.3.7
	dispatch-0.2.0
	dlib-0.5.0
	downcast-rs-1.2.0
	dwrote-0.11.0
	either-1.8.0
	embed-resource-1.8.0
	encode_unicode-0.3.6
	encoding_rs-0.8.31
	enum-map-2.4.2
	enum-map-derive-0.11.0
	enumset-1.0.12
	enumset_derive-0.6.1
	env_logger-0.10.0
	errno-0.2.8
	errno-dragonfly-0.1.2
	error-code-2.3.1
	euclid-0.22.7
	event-listener-2.5.3
	expat-sys-2.1.6
	exr-1.5.2
	fastrand-1.8.0
	flate2-1.0.25
	float_next_after-0.1.5
	flume-0.10.14
	fnv-1.0.7
	foreign-types-0.3.2
	foreign-types-0.5.0
	foreign-types-macros-0.2.2
	foreign-types-shared-0.1.1
	foreign-types-shared-0.3.1
	form_urlencoded-1.1.0
	freetype-rs-0.26.0
	freetype-sys-0.13.1
	futures-0.3.26
	futures-channel-0.3.26
	futures-core-0.3.26
	futures-executor-0.3.26
	futures-io-0.3.26
	futures-lite-1.12.0
	futures-macro-0.3.26
	futures-sink-0.3.26
	futures-task-0.3.26
	futures-util-0.3.26
	fxhash-0.2.1
	gdk-pixbuf-sys-0.16.3
	gdk-sys-0.16.0
	generational-arena-0.2.8
	generator-0.7.2
	generic-array-0.14.6
	gethostname-0.2.3
	getrandom-0.2.8
	gif-0.11.4
	gif-0.12.0
	gimli-0.27.1
	gio-sys-0.16.3
	glib-sys-0.16.3
	glob-0.3.1
	gobject-sys-0.16.3
	gpu-alloc-0.5.3
	gpu-alloc-types-0.2.0
	gpu-allocator-0.21.0
	gpu-descriptor-0.2.3
	gpu-descriptor-types-0.1.1
	gtk-sys-0.16.0
	half-2.2.1
	hashbrown-0.12.3
	hassle-rs-0.9.0
	heck-0.4.0
	hermit-abi-0.1.19
	hermit-abi-0.2.6
	hexf-parse-0.2.1
	http-0.2.8
	humantime-2.1.0
	iana-time-zone-0.1.53
	iana-time-zone-haiku-0.1.1
	ident_case-1.0.1
	idna-0.3.0
	image-0.24.5
	indexmap-1.9.2
	indicatif-0.17.3
	insta-1.26.0
	instant-0.1.12
	io-lifetimes-1.0.4
	is-terminal-0.4.2
	isahc-1.7.2
	itoa-0.4.8
	itoa-1.0.5
	jni-0.19.0
	jni-0.20.0
	jni-sys-0.3.0
	jobserver-0.1.25
	jpeg-decoder-0.3.0
	js-sys-0.3.60
	khronos-egl-4.1.0
	lazy_static-1.4.0
	lazycell-1.3.0
	lebe-0.5.2
	libc-0.2.139
	libflate-1.2.0
	libflate_lz77-1.1.0
	libloading-0.7.4
	libm-0.2.6
	libnghttp2-sys-0.1.7+1.45.0
	libtest-mimic-0.6.0
	libz-sys-1.1.8
	link-cplusplus-1.0.8
	linked-hash-map-0.5.6
	linkme-0.3.7
	linkme-impl-0.3.7
	linux-raw-sys-0.1.4
	lock_api-0.4.9
	log-0.4.17
	loom-0.5.6
	lyon-1.0.1
	lyon_algorithms-1.0.2
	lyon_geom-1.0.4
	lyon_path-1.0.3
	lyon_tessellation-1.0.8
	lzma-rs-0.3.0
	mach-0.3.2
	malloc_buf-0.0.6
	matchers-0.1.0
	memchr-2.5.0
	memmap2-0.5.8
	memoffset-0.6.5
	memoffset-0.7.1
	metal-0.24.0
	mime-0.3.16
	minimal-lexical-0.2.1
	miniz_oxide-0.6.2
	mio-0.8.5
	nanorand-0.7.0
	ndk-0.7.0
	ndk-context-0.1.1
	ndk-glue-0.7.0
	ndk-macro-0.3.0
	ndk-sys-0.4.1+23.1.7779620
	nix-0.24.3
	nix-0.25.1
	nom-7.1.3
	nom8-0.2.0
	nu-ansi-term-0.46.0
	num-bigint-0.4.3
	num-complex-0.4.3
	num-derive-0.3.3
	num-integer-0.1.45
	num-rational-0.4.1
	num-traits-0.2.15
	num_cpus-1.15.0
	num_enum-0.5.9
	num_enum_derive-0.5.9
	number_prefix-0.4.0
	objc-0.2.7
	objc-foundation-0.1.1
	objc_exception-0.1.2
	objc_id-0.1.1
	object-0.30.3
	oboe-0.5.0
	oboe-sys-0.5.0
	once_cell-1.17.0
	openssl-probe-0.1.5
	openssl-sys-0.9.80
	os_info-3.5.1
	os_str_bytes-6.4.1
	ouroboros-0.15.5
	ouroboros_macro-0.15.5
	output_vt100-0.1.3
	overload-0.1.1
	pango-sys-0.16.3
	parking-2.0.0
	parking_lot-0.12.1
	parking_lot_core-0.9.6
	path-slash-0.2.1
	peeking_take_while-0.1.2
	percent-encoding-2.2.0
	pin-project-1.0.12
	pin-project-internal-1.0.12
	pin-project-lite-0.2.9
	pin-utils-0.1.0
	pkg-config-0.3.26
	png-0.17.7
	polling-2.5.2
	portable-atomic-0.3.19
	pp-rs-0.2.1
	ppv-lite86-0.2.17
	pretty_assertions-1.3.0
	primal-check-0.3.3
	proc-macro-crate-1.3.0
	proc-macro-error-1.0.4
	proc-macro-error-attr-1.0.4
	proc-macro2-1.0.50
	profiling-1.0.7
	profiling-procmacros-1.0.7
	quote-1.0.23
	rand-0.8.5
	rand_chacha-0.3.1
	rand_core-0.6.4
	range-alloc-0.1.2
	raw-window-handle-0.4.3
	raw-window-handle-0.5.0
	rayon-1.6.1
	rayon-core-1.10.2
	redox_syscall-0.2.16
	redox_users-0.4.3
	regex-1.7.1
	regex-automata-0.1.10
	regex-syntax-0.6.28
	regress-0.4.1
	renderdoc-sys-0.7.1
	rfd-0.11.0
	rle-decode-fast-1.0.3
	ron-0.8.0
	rustc-demangle-0.1.21
	rustc-hash-1.1.0
	rustc_version-0.4.0
	rustdct-0.7.1
	rustfft-6.1.0
	rustix-0.36.7
	rustversion-1.0.11
	ryu-1.0.12
	safe_arch-0.5.2
	safe_arch-0.6.0
	same-file-1.0.6
	schannel-0.1.21
	scoped-tls-1.0.1
	scoped_threadpool-0.1.9
	scopeguard-1.1.0
	scratch-1.0.3
	sctk-adwaita-0.4.3
	semver-1.0.16
	serde-1.0.152
	serde-wasm-bindgen-0.4.5
	serde-xml-rs-0.6.0
	serde_derive-1.0.152
	serde_json-1.0.91
	servo-fontconfig-0.5.1
	servo-fontconfig-sys-5.1.0
	sha2-0.10.6
	sharded-slab-0.1.4
	shlex-1.1.0
	similar-2.2.1
	simple_asn1-0.6.2
	slab-0.4.7
	slotmap-1.0.6
	sluice-0.5.5
	smallvec-1.10.0
	smithay-client-toolkit-0.16.0
	socket2-0.4.7
	spin-0.9.4
	spirv-0.2.0+1.5.4
	static_assertions-1.1.0
	str-buf-1.0.6
	strength_reduce-0.2.4
	strsim-0.10.0
	symphonia-0.5.2
	symphonia-bundle-mp3-0.5.2
	symphonia-core-0.5.2
	symphonia-metadata-0.5.2
	syn-1.0.107
	synstructure-0.12.6
	system-deps-6.0.3
	termcolor-1.2.0
	thiserror-1.0.38
	thiserror-impl-1.0.38
	thread_local-1.1.4
	threadpool-1.8.1
	tiff-0.8.1
	time-0.3.17
	time-core-0.1.0
	time-macros-0.2.6
	tiny-skia-0.7.0
	tiny-skia-path-0.7.0
	tinyvec-1.6.0
	tinyvec_macros-0.1.0
	toml-0.5.11
	toml_datetime-0.5.1
	toml_edit-0.18.0
	tracing-0.1.37
	tracing-attributes-0.1.23
	tracing-core-0.1.30
	tracing-futures-0.2.5
	tracing-log-0.1.3
	tracing-subscriber-0.3.16
	tracing-tracy-0.10.0
	tracing-wasm-0.2.1
	tracy-client-0.14.2
	tracy-client-sys-0.19.0
	transpose-0.2.2
	typed-arena-2.0.2
	typenum-1.16.0
	unicode-bidi-0.3.10
	unicode-ident-1.0.6
	unicode-normalization-0.1.22
	unicode-segmentation-1.10.0
	unicode-width-0.1.10
	unicode-xid-0.2.4
	url-2.3.1
	valuable-0.1.0
	vcpkg-0.2.15
	vec_map-0.8.2
	version-compare-0.1.1
	version_check-0.9.4
	vswhom-0.1.0
	vswhom-sys-0.1.2
	waker-fn-1.1.0
	walkdir-2.3.2
	wasi-0.11.0+wasi-snapshot-preview1
	wasm-bindgen-0.2.83
	wasm-bindgen-backend-0.2.83
	wasm-bindgen-futures-0.4.33
	wasm-bindgen-macro-0.2.83
	wasm-bindgen-macro-support-0.2.83
	wasm-bindgen-shared-0.2.83
	wayland-client-0.29.5
	wayland-commons-0.29.5
	wayland-cursor-0.29.5
	wayland-protocols-0.29.5
	wayland-scanner-0.29.5
	wayland-sys-0.29.5
	weak-table-0.3.2
	web-sys-0.3.60
	webbrowser-0.8.7
	weezl-0.1.7
	wepoll-ffi-0.1.2
	wide-0.7.5
	widestring-0.5.1
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-util-0.1.5
	winapi-wsapoll-0.1.1
	winapi-x86_64-pc-windows-gnu-0.4.0
	windows-0.39.0
	windows-0.43.0
	windows-0.44.0
	windows-sys-0.36.1
	windows-sys-0.42.0
	windows-targets-0.42.1
	windows_aarch64_gnullvm-0.42.1
	windows_aarch64_msvc-0.36.1
	windows_aarch64_msvc-0.39.0
	windows_aarch64_msvc-0.42.1
	windows_i686_gnu-0.36.1
	windows_i686_gnu-0.39.0
	windows_i686_gnu-0.42.1
	windows_i686_msvc-0.36.1
	windows_i686_msvc-0.39.0
	windows_i686_msvc-0.42.1
	windows_x86_64_gnu-0.36.1
	windows_x86_64_gnu-0.39.0
	windows_x86_64_gnu-0.42.1
	windows_x86_64_gnullvm-0.42.1
	windows_x86_64_msvc-0.36.1
	windows_x86_64_msvc-0.39.0
	windows_x86_64_msvc-0.42.1
	winit-0.27.5
	winreg-0.10.1
	wio-0.2.2
	x11-dl-2.21.0
	x11rb-0.10.1
	x11rb-protocol-0.10.0
	xcursor-0.3.4
	xml-rs-0.8.4
	yaml-rust-0.4.5
	yansi-0.5.1"
declare -A GIT_CRATES=(
	[d3d12]="https://github.com/gfx-rs/d3d12-rs;a990c93ec64eeab78f2292763d0715da9dba1d59;d3d12-rs-%commit%"
	[dasp]="https://github.com/RustAudio/dasp;f05a703d247bb504d7e812b51e95f3765d9c5e94;dasp-%commit%/dasp"
	[flash-lso]="https://github.com/ruffle-rs/rust-flash-lso;8376453eddddbe701031a091c0eed94068fa5649;rust-flash-lso-%commit%/flash-lso"
	[gc-arena]="https://github.com/kyren/gc-arena;318b2ea594dcdadd01f7789025e3b3940be96b2c;gc-arena-%commit%/src/gc-arena"
	[glow]="https://github.com/grovesNL/glow;c8a011fcd57a5c68cc917ed394baa484bdefc909"
	[h263-rs-yuv]="https://github.com/ruffle-rs/h263-rs;f0083f5933f173798dd308d1678f06d181a99975;h263-rs-%commit%/yuv"
	[h263-rs]="https://github.com/ruffle-rs/h263-rs;f0083f5933f173798dd308d1678f06d181a99975;h263-rs-%commit%/h263"
	[naga]="https://github.com/gfx-rs/naga;1be8024bda3594987b417bead5024b98be9ab521"
	[naga_oil]="https://github.com/Aaron1011/naga_oil;f4474b53285a85fe67cc35372c9d7ff4517cb556"
	[nellymoser-rs]="https://github.com/ruffle-rs/nellymoser;4a33521c29a918950df8ae9fe07e527ac65553f5;nellymoser-%commit%"
	[nihav_codec_support]="https://github.com/ruffle-rs/nihav-vp6;9416fcc9fc8aab8f4681aa9093b42922214abbd3;nihav-vp6-%commit%/nihav-codec-support"
	[nihav_core]="https://github.com/ruffle-rs/nihav-vp6;9416fcc9fc8aab8f4681aa9093b42922214abbd3;nihav-vp6-%commit%/nihav-core"
	[nihav_duck]="https://github.com/ruffle-rs/nihav-vp6;9416fcc9fc8aab8f4681aa9093b42922214abbd3;nihav-vp6-%commit%/nihav-duck"
	[quick-xml]="https://github.com/ruffle-rs/quick-xml;8496365ec1412eb5ba5de350937b6bce352fa0ba"
	[wgpu]="https://github.com/gfx-rs/wgpu;c5851275c59b1d5d949b142d6aa973d0bb638181;wgpu-%commit%/wgpu"
)
inherit cargo desktop flag-o-matic virtualx xdg

MY_PV="nightly-${PV:3:4}-${PV:7:2}-${PV:9:2}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Flash Player emulator written in Rust"
HOMEPAGE="https://ruffle.rs/"
SRC_URI="
	https://github.com/ruffle-rs/ruffle/archive/refs/tags/${MY_PV}.tar.gz -> ${MY_P}.tar.gz
	$(cargo_crate_uris)"
S="${WORKDIR}/${MY_P}"

LICENSE="Apache-2.0 BSD BSD-2 Boost-1.0 CC0-1.0 ISC MIT MPL-2.0 Unicode-DFS-2016 ZLIB curl"
SLOT="0"
KEYWORDS="~amd64"

# dlopen: libX* (see winit+x11-dl crates)
RDEPEND="
	dev-libs/glib:2
	dev-libs/openssl:=
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	sys-libs/zlib:=
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXrender"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto"
BDEPEND="
	virtual/jre:*
	virtual/pkgconfig
	>=virtual/rust-1.64
	test? (
		media-libs/mesa[llvm]
		x11-base/xorg-server[-minimal]
	)"

QA_FLAGS_IGNORED="usr/bin/${PN}.*"

PATCHES=(
	"${FILESDIR}"/${PN}-0_p20230125-no-patch-naga.patch
)

src_compile() {
	filter-lto # does not play well with C code in crates

	cargo_src_compile --bins # note: configure --bins would skip tests
}

src_test() {
	virtx cargo_src_test
}

src_install() {
	dodoc README.md

	newicon web/packages/extension/assets/images/icon180.png ${PN}.png
	make_desktop_entry ${PN} ${PN^} ${PN} "AudioVideo;Player;Emulator;" \
		"MimeType=application/x-shockwave-flash;application/vnd.adobe.flash.movie;"

	cd target/$(usex debug{,} release) || die

	newbin ${PN}_desktop ${PN}
	newbin exporter ${PN}_exporter
	dobin ${PN}_scanner
}

pkg_postinst() {
	xdg_pkg_postinst

	if [[ ! ${REPLACING_VERSIONS} ]]; then
		elog "${PN} is experimental software that is still under heavy development"
		elog "and only receiving nightly releases. Plans in Gentoo is to update"
		elog "roughly every months if no known major regressions (feel free to"
		elog "report if you feel a newer nightly is needed ahead of time)."
		elog
		elog "There is currently no plans to support wasm builds / browser"
		elog "extensions, this provides the desktop viewer and other tools."
	fi
}
