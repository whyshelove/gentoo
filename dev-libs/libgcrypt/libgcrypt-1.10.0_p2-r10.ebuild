# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

suffix_ver=$(ver_cut 5)
[[ ${suffix_ver} ]] && DSUFFIX="_${suffix_ver}"
inherit autotools flag-o-matic linux-info multilib-minimal toolchain-funcs rhel9

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="https://www.gnupg.org/"

LICENSE="LGPL-2.1 MIT"
SLOT="0/20" # subslot = soname major version
KEYWORDS="~alpha amd64 ~arm arm64 hppa ~ia64 ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+asm cpu_flags_arm_neon cpu_flags_arm_aes cpu_flags_arm_sha1 cpu_flags_arm_sha2 cpu_flags_ppc_altivec cpu_flags_ppc_vsx2 cpu_flags_ppc_vsx3 cpu_flags_x86_aes cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_padlock cpu_flags_x86_sha cpu_flags_x86_sse4_1 doc +getentropy static-libs"

# Build system only has --disable-arm-crypto-support right now
# If changing this, update src_configure logic too.
# ARM CPUs seem to, right now, support all-or-nothing for crypto extensions,
# but this looks like it might change in future. This is just a safety check
# in case people somehow do have a CPU which only supports some. They must
# for now disable them all if that's the case.
REQUIRED_USE="
	cpu_flags_arm_aes? ( cpu_flags_arm_sha1 cpu_flags_arm_sha2 )
	cpu_flags_arm_sha1? ( cpu_flags_arm_aes cpu_flags_arm_sha2 )
	cpu_flags_arm_sha2? ( cpu_flags_arm_aes cpu_flags_arm_sha1 )
	cpu_flags_ppc_vsx3? ( cpu_flags_ppc_altivec cpu_flags_ppc_vsx2 )
	cpu_flags_ppc_vsx2? ( cpu_flags_ppc_altivec )
"

RDEPEND=">=dev-libs/libgpg-error-1.25[${MULTILIB_USEDEP}]
	getentropy? (
		kernel_linux? (
			elibc_glibc? ( >=sys-libs/glibc-2.25 )
			elibc_musl? ( >=sys-libs/musl-1.1.20 )
		)
	)"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( virtual/texi2dvi )"

PATCHES=(
	"${FILESDIR}"/${PN}-multilib-syspath.patch
	"${FILESDIR}"/${PN}-powerpc-darwin.patch
	"${FILESDIR}"/${PN}-1.10.1-fix-no-asm-hppa.patch
	"${FILESDIR}"/${PN}-1.9.4-no-fgrep-libgcrypt-config.patch
	"${FILESDIR}"/${PN}-1.10.1-configure-clang16.patch
)

MULTILIB_CHOST_TOOLS=(
	/usr/bin/libgcrypt-config
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} == buildonly ]]; then
		return
	fi
	if use kernel_linux && use getentropy; then
		unset KV_FULL
		get_running_version
		if [[ -n ${KV_FULL} ]] && kernel_is -lt 3 17; then
			eerror "The getentropy function requires the getrandom syscall."
			eerror "This was introduced in Linux 3.17."
			eerror "Your system is currently running Linux ${KV_FULL}."
			eerror "Disable the 'getentropy' USE flag or upgrade your kernel."
			die "Kernel is too old for getentropy"
		fi
	fi
}

pkg_setup() {
	# should be all algorithms except SM3 and SM4
	export DIGESTS='crc gostr3411-94 md4 md5 rmd160 sha1 sha256 sha512 sha3 tiger whirlpool stribog blake2'
	export CIPHERS='arcfour blowfish cast5 des aes twofish serpent rfc2268 seed camellia idea salsa20 gost28147 chacha20'
}

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	append-cflags -flto=auto

	if [[ ${CHOST} == *86*-solaris* ]] ; then
		# ASM code uses GNU ELF syntax, divide in particular, we need to
		# allow this via ASFLAGS, since we don't have a flag-o-matic
		# function for that, we'll have to abuse cflags for this
		append-cflags -Wa,--divide
	fi

	if [[ ${CHOST} == powerpc* ]] ; then
		# ./configure does a lot of automagic, prevent that
		# generic ppc32+ppc64 altivec
		use cpu_flags_ppc_altivec || local -x gcry_cv_cc_ppc_altivec=no
		use cpu_flags_ppc_altivec || local -x gcry_cv_cc_ppc_altivec_cflags=no
		# power8 vector extension, aka arch 2.07 ISA, also checked below via ppc-crypto-support
		use cpu_flags_ppc_vsx2 || local -x gcry_cv_gcc_inline_asm_ppc_altivec=no
		# power9 vector extension, aka arch 3.00 ISA
		use cpu_flags_ppc_vsx3 || local -x gcry_cv_gcc_inline_asm_ppc_arch_3_00=no
	fi

	# Workaround for GCC < 11.3 bug
	# https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgcrypt.git;a=commitdiff;h=0b399721ce9709ae25f9d2050360c5ab2115ae29
	# https://dev.gnupg.org/T5581
	# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=102124
	if use arm64 && tc-is-gcc && (($(gcc-major-version) == 11)) && (($(gcc-minor-version) <= 2)) && (($(gcc-micro-version) == 0)) ; then
		append-flags -fno-tree-loop-vectorize
	fi

	# ideally we want !tc-ld-is-bfd for best future-proofing, but it needs
	# https://github.com/gentoo/gentoo/pull/28355
	# mold needs this too but right now tc-ld-is-mold is also not available
	if tc-ld-is-lld; then
		append-ldflags -Wl,--undefined-version
	fi

	local myeconfargs=(
		CC_FOR_BUILD="$(tc-getBUILD_CC)"

		--enable-noexecstack
		--enable-hmac-binary-check
		--disable-brainpool
		--enable-digests="$DIGESTS"
		--enable-ciphers="$CIPHERS"
		$(use_enable cpu_flags_arm_neon neon-support)
		# See REQUIRED_USE comment above
		$(use_enable cpu_flags_arm_aes arm-crypto-support)
		$(use_enable cpu_flags_ppc_vsx2 ppc-crypto-support)
		$(use_enable cpu_flags_x86_aes aesni-support)
		$(use_enable cpu_flags_x86_avx avx-support)
		$(use_enable cpu_flags_x86_avx2 avx2-support)
		$(use_enable cpu_flags_x86_padlock padlock-support)
		$(use_enable cpu_flags_x86_sha shaext-support)
		$(use_enable cpu_flags_x86_sse4_1 sse41-support)
		# required for sys-power/suspend[crypt], bug 751568
		$(use_enable static-libs static)

		# disabled due to various applications requiring privileges
		# after libgcrypt drops them (bug #468616)
		--without-capabilities

		# http://trac.videolan.org/vlc/ticket/620
		$([[ ${CHOST} == *86*-darwin* ]] && echo "--disable-asm")
		# causes bus-errors on sparc64-solaris
		$([[ ${CHOST} == sparcv9-*-solaris* ]] && echo "--disable-asm")

		$(use asm || echo "--disable-asm")

		GPG_ERROR_CONFIG="${ESYSROOT}/usr/bin/${CHOST}-gpg-error-config"
	)

	if use kernel_linux; then
		# --enable-random=getentropy requires getentropy/getrandom.
		# --enable-random=linux enables legacy code that tries getrandom
		# and falls back to reading /dev/random.
		myeconfargs+=( --enable-random=$(usex getentropy getentropy linux) )
	fi

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}" \
		$("${S}/configure" --help | grep -o -- '--without-.*-prefix')

	sed -i -e '/^sys_lib_dlsearch_path_spec/s,/lib /usr/lib,/usr/lib /lib64 /usr/lib64 /lib,g' libtool
}

multilib_src_compile() {
	default
	multilib_is_native_abi && use doc && VARTEXFONTS="${T}/fonts" emake -C doc gcrypt.pdf
}

multilib_src_install() {
	emake DESTDIR="${D}" install
	multilib_is_native_abi && use doc && dodoc doc/gcrypt.pdf
}

multilib_src_install_all() {
	default

	# Change /usr/lib64 back to /usr/lib.  This saves us from having to patch the
	# script to "know" that -L/usr/lib64 should be suppressed, and also removes
	# a file conflict between 32- and 64-bit versions of this package.
	# Also replace my_host with none.
	sed -i -e 's,^libdir="/usr/lib.*"$,libdir="/usr/lib",g' ${D}/usr/bin/libgcrypt-config
	sed -i -e 's,^my_host=".*"$,my_host="none",g' ${D}/usr/bin/libgcrypt-config

	find "${ED}" -type f -name '*.la' -delete || die
}
