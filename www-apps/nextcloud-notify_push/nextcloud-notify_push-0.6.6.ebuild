# Copyright 2017-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

CRATES="
addr2line@0.21.0
adler@1.0.2
ahash@0.7.7
ahash@0.8.6
aho-corasick@1.0.5
allocator-api2@0.2.16
android-tzdata@0.1.1
android_system_properties@0.1.5
ansi_term@0.12.1
async-stream@0.3.5
async-stream-impl@0.3.5
async-trait@0.1.74
atoi@0.3.3
atoi@1.0.0
atty@0.2.14
autocfg@1.1.0
backtrace@0.3.69
backtrace-ext@0.2.1
base64@0.13.1
base64@0.21.5
base64ct@1.6.0
beef@0.5.2
bitflags@1.3.2
bitflags@2.4.1
block-buffer@0.10.4
bumpalo@3.13.0
byteorder@1.5.0
bytes@1.5.0
cc@1.0.83
cfg-if@1.0.0
chrono@0.4.26
clap@2.34.0
combine@4.6.6
const-oid@0.7.1
core-foundation@0.9.3
core-foundation-sys@0.8.4
cpufeatures@0.2.11
crc@3.0.1
crc-catalog@2.2.0
crc16@0.4.0
crc32fast@1.3.2
crossbeam-queue@0.3.8
crossbeam-utils@0.8.16
crypto-bigint@0.3.2
crypto-common@0.1.6
dashmap@5.5.3
data-encoding@2.4.0
der@0.5.1
derivative@2.2.0
digest@0.10.7
dirs@4.0.0
dirs-sys@0.3.7
dotenv@0.15.0
dotenvy@0.15.7
either@1.8.1
encoding_rs@0.8.33
errno@0.3.2
errno-dragonfly@0.1.2
event-listener@2.5.3
flate2@1.0.26
flexi_logger@0.27.2
flume@0.10.14
fnv@1.0.7
form_urlencoded@1.2.0
futures@0.3.29
futures-channel@0.3.29
futures-core@0.3.29
futures-executor@0.3.29
futures-intrusive@0.4.2
futures-io@0.3.29
futures-macro@0.3.29
futures-sink@0.3.29
futures-task@0.3.29
futures-util@0.3.29
generic-array@0.14.7
getrandom@0.2.10
gimli@0.28.0
glob@0.3.1
h2@0.3.21
hashbrown@0.12.3
hashbrown@0.14.1
hashlink@0.8.3
headers@0.3.9
headers-core@0.2.0
heck@0.3.3
heck@0.4.1
hermit-abi@0.1.19
hermit-abi@0.3.3
hex@0.4.3
hkdf@0.12.3
hmac@0.12.1
http@0.2.9
http-auth-basic@0.3.3
http-body@0.4.5
httparse@1.8.0
httpdate@1.0.3
hyper@0.14.27
hyper-rustls@0.24.1
iana-time-zone@0.1.57
iana-time-zone-haiku@0.1.2
idna@0.4.0
indexmap@1.9.3
instant@0.1.12
ipnet@2.8.0
is-terminal@0.4.9
is_ci@1.1.1
itertools@0.10.5
itoa@1.0.9
js-sys@0.3.64
lazy_static@1.4.0
libc@0.2.149
libm@0.2.7
libsqlite3-sys@0.24.2
linux-raw-sys@0.4.5
lock_api@0.4.10
log@0.4.20
logos@0.12.1
logos-derive@0.12.1
matchers@0.0.1
md-5@0.10.5
memchr@2.6.4
miette@5.10.0
miette-derive@5.10.0
mime@0.3.17
mime_guess@2.0.4
mini-redis@0.4.1
minimal-lexical@0.2.1
miniz_oxide@0.7.1
mio@0.8.9
multer@2.1.0
nextcloud-config-parser@0.8.0
nextcloud_appinfo@0.6.0
nom@7.1.3
nu-ansi-term@0.49.0
num-bigint@0.4.3
num-bigint-dig@0.8.2
num-integer@0.1.45
num-iter@0.1.43
num-traits@0.2.17
num_cpus@1.16.0
object@0.32.1
once_cell@1.18.0
owo-colors@3.5.0
parking_lot@0.11.2
parking_lot@0.12.1
parking_lot_core@0.8.6
parking_lot_core@0.9.8
parse-display@0.8.2
parse-display-derive@0.8.2
paste@1.0.12
pem-rfc7468@0.3.1
percent-encoding@2.3.0
peresil@0.3.0
php-literal-parser@0.5.1
pin-project@1.1.3
pin-project-internal@1.1.3
pin-project-lite@0.2.13
pin-utils@0.1.0
pkcs1@0.3.3
pkcs8@0.8.0
pkg-config@0.3.27
ppv-lite86@0.2.17
proc-macro-error@1.0.4
proc-macro-error-attr@1.0.4
proc-macro2@1.0.69
quick-error@1.2.3
quote@1.0.33
rand@0.8.5
rand_chacha@0.3.1
rand_core@0.6.4
redis@0.23.3
redox_syscall@0.2.16
redox_syscall@0.3.5
redox_users@0.4.3
regex@1.9.4
regex-automata@0.1.10
regex-automata@0.3.7
regex-syntax@0.6.29
regex-syntax@0.7.5
reqwest@0.11.22
rfc7239@0.1.0
ring@0.16.20
ring@0.17.3
rsa@0.6.1
rustc-demangle@0.1.23
rustix@0.38.7
rustls@0.20.8
rustls@0.21.8
rustls-pemfile@1.0.3
rustls-webpki@0.101.7
ryu@1.0.15
scoped-tls@1.0.1
scopeguard@1.2.0
sct@0.7.0
semver@0.10.0
semver-parser@0.7.0
serde@1.0.190
serde_derive@1.0.190
serde_json@1.0.108
serde_urlencoded@0.7.1
sha1@0.10.6
sha2@0.10.7
sharded-slab@0.1.4
signal-hook-registry@1.4.1
slab@0.4.9
smallvec@1.11.1
smawk@0.3.1
socket2@0.4.10
socket2@0.5.5
spin@0.5.2
spin@0.9.8
spki@0.5.4
sqlformat@0.2.1
sqlx@0.6.3
sqlx-core@0.6.3
sqlx-macros@0.6.3
sqlx-rt@0.6.3
stringprep@0.1.2
strsim@0.8.0
structmeta@0.2.0
structmeta-derive@0.2.0
structopt@0.3.26
structopt-derive@0.4.18
subtle@2.5.0
supports-color@2.0.0
supports-hyperlinks@2.1.0
supports-unicode@2.0.0
sxd-document@0.3.2
sxd-xpath@0.4.2
syn@1.0.109
syn@2.0.39
system-configuration@0.5.1
system-configuration-sys@0.5.0
terminal_size@0.1.17
textwrap@0.11.0
textwrap@0.15.2
thiserror@1.0.50
thiserror-impl@1.0.50
thread_local@1.1.7
tinyvec@1.6.0
tinyvec_macros@0.1.1
tokio@1.33.0
tokio-macros@2.1.0
tokio-rustls@0.23.4
tokio-rustls@0.24.1
tokio-stream@0.1.14
tokio-tungstenite@0.20.1
tokio-util@0.7.10
tower-service@0.3.2
tracing@0.1.40
tracing-attributes@0.1.27
tracing-core@0.1.32
tracing-futures@0.2.5
tracing-log@0.1.3
tracing-serde@0.1.3
tracing-subscriber@0.2.25
try-lock@0.2.4
tungstenite@0.20.1
typed-arena@1.7.0
typenum@1.17.0
uncased@0.9.9
unicase@2.7.0
unicode-bidi@0.3.13
unicode-ident@1.0.12
unicode-linebreak@0.1.4
unicode-normalization@0.1.22
unicode-segmentation@1.10.1
unicode-width@0.1.10
unicode_categories@0.1.1
untrusted@0.7.1
untrusted@0.9.0
ureq@2.8.0
url@2.4.1
utf-8@0.7.6
valuable@0.1.0
vcpkg@0.2.15
vec_map@0.8.2
version_check@0.9.4
want@0.3.1
warp@0.3.6
warp-real-ip@0.2.0
wasi@0.11.0+wasi-snapshot-preview1
wasm-bindgen@0.2.87
wasm-bindgen-backend@0.2.87
wasm-bindgen-futures@0.4.37
wasm-bindgen-macro@0.2.87
wasm-bindgen-macro-support@0.2.87
wasm-bindgen-shared@0.2.87
web-sys@0.3.64
webpki@0.22.4
webpki-roots@0.22.6
webpki-roots@0.24.0
webpki-roots@0.25.2
whoami@1.4.0
winapi@0.3.9
winapi-i686-pc-windows-gnu@0.4.0
winapi-x86_64-pc-windows-gnu@0.4.0
windows@0.48.0
windows-sys@0.48.0
windows-targets@0.48.5
windows_aarch64_gnullvm@0.48.5
windows_aarch64_msvc@0.48.5
windows_i686_gnu@0.48.5
windows_i686_msvc@0.48.5
windows_x86_64_gnu@0.48.5
windows_x86_64_gnullvm@0.48.5
windows_x86_64_msvc@0.48.5
winreg@0.50.0
xpath_reader@0.5.3
zerocopy@0.7.25
zerocopy-derive@0.7.25
zeroize@1.6.0
"

inherit cargo systemd

DESCRIPTION="Push daemon for Nextcloud clients"
HOMEPAGE="https://github.com/nextcloud/notify_push"
SRC_URI="https://github.com/nextcloud/notify_push/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}"
LICENSE="0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0 GPL-3 ISC MIT MPL-2.0 Unicode-DFS-2016 Unlicense ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="test"

RDEPEND="acct-group/nobody
	acct-user/nobody"

S="${WORKDIR}/notify_push-${PV}"

QA_FLAGS_IGNORED="usr/bin/${PN}"

src_install() {
	cargo_src_install
	einstalldocs

	# default name is too generic
	mv "${ED}/usr/bin/notify_push" "${ED}/usr/bin/${PN}" || die

	newconfd "${FILESDIR}/${PN}-r1.confd" "${PN}"
	newinitd "${FILESDIR}/${PN}-r1.init" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service-r1" "${PN}.service"
	systemd_install_serviced "${FILESDIR}/${PN}.service.conf" "${PN}"

	# restrict access because conf.d entry could contain
	# database credentials
	fperms 0640 "/etc/conf.d/${PN}"
}

pkg_postinst() {
	# According to PMS this can be a space-separated list of version
	# numbers, even though in practice it is typically just one.
	local oldver
	for oldver in ${REPLACING_VERSIONS}; do
		if ver_test "${oldver}" -lt "0.6.6"; then
			ewarn "You are upgrading from $oldver to ${PVR}"
			ewarn "The systemd unit file for nextcloud-notify_push no longer sources ${EPREFIX}/etc/conf.d/nextcloud-notify_push ."
			ewarn "Configuration is still done via ${EPREFIX}/etc/conf.d/nextcloud-notify_push for OpenRC systems"
			ewarn "while for systemd systems, a systemd drop-in file located at"
			ewarn "${EPREFIX}/etc/systemd/system/nextcloud-notify_push.d/00gentoo.conf"
			ewarn "is used for configuration."
			break
		fi
	done
}
