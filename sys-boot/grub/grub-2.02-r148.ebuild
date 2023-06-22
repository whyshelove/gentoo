# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} == 9999  ]]; then
	GRUB_AUTORECONF=1
	GRUB_BOOTSTRAP=1
fi

if [[ -n ${GRUB_AUTOGEN} || -n ${GRUB_BOOTSTRAP} ]]; then
	PYTHON_COMPAT=( python{2_7,3_{6,8,9}} )
	inherit python-any-r1
fi

if [[ -n ${GRUB_AUTORECONF} ]]; then
	WANT_LIBTOOL=none
	inherit autotools
fi

#DSUFFIX="_$(ver_cut 4).$(ver_cut 6)"
_hardened_build="undefine"
_annotated_build="undefine"

inherit bash-completion-r1 flag-o-matic multibuild optfeature pax-utils toolchain-funcs mount-boot rhel8

if [[ ${PV} != 9999 ]]; then
	S=${WORKDIR}/${P/_p*}
	KEYWORDS="amd64 ~arm arm64 ~ia64 ppc ppc64 sparc x86"
else
	EGIT_REPO_URI+="https://git.savannah.gnu.org/git/grub.git"
fi

PATCHES=(
	"${FILESDIR}"/gfxpayload.patch
	"${FILESDIR}"/2.02-freetype-capitalise-variables.patch
	"${FILESDIR}"/2.02-freetype-pkg-config.patch
)

DEJAVU=dejavu-sans-ttf-2.37
UNIFONT=unifont-12.1.02
SRC_URI+=" fonts? ( mirror://gnu/unifont/${UNIFONT}/${UNIFONT}.pcf.gz )
	themes? ( mirror://sourceforge/dejavu/${DEJAVU}.zip )"

DESCRIPTION="GNU GRUB boot loader"
HOMEPAGE="https://www.gnu.org/software/grub/"

# Includes licenses for dejavu and unifont
LICENSE="GPL-3+ BSD MIT fonts? ( GPL-2-with-font-exception ) themes? ( CC-BY-SA-3.0 BitstreamVera )"
SLOT="2/${PVR}"
IUSE="device-mapper doc +efiemu +fonts mount nls static sdl test +themes truetype libzfs +sign"

GRUB_ALL_PLATFORMS=( coreboot efi-32 efi-64 emu ieee1275 loongson multiboot qemu qemu-mips pc uboot xen xen-32 )
IUSE+=" ${GRUB_ALL_PLATFORMS[@]/#/grub_platforms_}"

REQUIRED_USE="
	grub_platforms_coreboot? ( fonts )
	grub_platforms_qemu? ( fonts )
	grub_platforms_ieee1275? ( fonts )
	grub_platforms_loongson? ( fonts )
    sign? ( ^^ ( amd64 arm64 ) )
"

BDEPEND="
	${PYTHON_DEPS}
	app-misc/pax-utils
	sys-devel/flex
	sys-devel/bison
	sys-apps/help2man
	sys-apps/texinfo
	sign? ( app-crypt/pesign )
	fonts? (
		media-libs/freetype:2
		virtual/pkgconfig
	)
	test? (
		app-admin/genromfs
		app-arch/cpio
		app-arch/lzop
		app-emulation/qemu
		dev-libs/libisoburn
		sys-apps/miscfiles
		sys-block/parted
		sys-fs/squashfs-tools
	)
	themes? (
		app-arch/unzip
		media-libs/freetype:2
		virtual/pkgconfig
	)
	truetype? ( virtual/pkgconfig )
	sys-boot/shim
"
DEPEND="
	app-arch/xz-utils
	>=sys-libs/ncurses-5.2-r5:0=
	grub_platforms_emu? (
		sdl? ( media-libs/libsdl )
	)
	device-mapper? ( >=sys-fs/lvm2-2.02.45 )
	libzfs? ( sys-fs/zfs:= )
	mount? ( sys-fs/fuse:0 )
	truetype? ( media-libs/freetype:2= )
	ppc? ( >=sys-apps/ibm-powerpc-utils-1.3.5 )
	ppc64? ( >=sys-apps/ibm-powerpc-utils-1.3.5 )
"
RDEPEND="${DEPEND}
	kernel_linux? (
		grub_platforms_efi-32? ( sys-boot/efibootmgr )
		grub_platforms_efi-64? ( sys-boot/efibootmgr )
	)
	!sys-boot/grub:0
	nls? ( sys-devel/gettext )
"

RESTRICT="!test? ( test )"

QA_EXECSTACK="usr/bin/grub-emu* usr/lib/grub/*"
QA_PRESTRIPPED="usr/lib/grub/.*"
QA_MULTILIB_PATHS="usr/lib/grub/.*"
QA_WX_LOAD="usr/lib/grub/*"

pkg_setup() {
    if use amd64; then
        efiarch=x64
        grub_target_name=x86_64-efi
        package_arch=efi-x64
    fi

    if use arm64; then
        efiarch=aa64
        grub_target_name=arm64-efi
        package_arch=efi-aa64
    fi

    S13="${WORKDIR}/redhatsecurebootca3.cer"
    S14="${WORKDIR}/redhatsecureboot301.cer"
    S15="${WORKDIR}/redhatsecurebootca5.cer"
    S16="${WORKDIR}/redhatsecureboot502.cer"

    GRUB_EFI64_S="${WORKDIR}/${P/_p*}-${package_arch/x}"
    efi_vendor=$(eval echo $(grep ^ID= /etc/os-release | sed -e 's/^ID=//'))
    efi_esp_dir="/boot/efi/EFI/${efi_vendor}"
    grubefiname="grub${efiarch}.efi"
    grubeficdname="gcd${efiarch}.efi"

grub_modules="all_video boot blscfg \
		cat configfile cryptodisk echo ext2 \
		fat font gcry_rijndael gcry_rsa gcry_serpent \
		gcry_sha256 gcry_twofish gcry_whirlpool \
		gfxmenu gfxterm gzio halt http \
		increment iso9660 jpeg loadenv loopback linux \
		lvm luks mdraid09 mdraid1x minicmd net \
		normal part_apple part_msdos part_gpt \
		password_pbkdf2 png reboot regexp search \
		search_fs_uuid search_fs_file search_label \
		serial sleep syslinuxcfg test tftp video xfs"

efi_modules=" efi_netfs efifwsetup efinet lsefi lsefimmap connectefi"

platform_modules=" backtrace chain usb usbserial_common usbserial_pl2303 usbserial_ftdi usbserial_usbdebug keylayouts at_keyboard"
}

#src_unpack() {
#	rhel_src_unpack ${A}
#	sed -i "/Patch0319/d" ${WORKDIR}/grub.patches
#	rpmbuild -bp $WORKDIR/*.spec --nodeps
#}

src_prepare() {
	default
	sed -i -e /autoreconf/d autogen.sh || die

	# Nothing in Gentoo packages 'american-english' in the exact path
	# wanted for the test, but all that is needed is a compressible text
	# file, and we do have 'words' from miscfiles in the same path.
	sed -i \
		-e '/CFILESSRC.*=/s,american-english,words,' \
		tests/util/grub-fs-tester.in \
		|| die

	if [[ -n ${GRUB_AUTOGEN} || -n ${GRUB_BOOTSTRAP} ]]; then
		python_setup
	else
		export PYTHON=true
	fi

	if [[ -n ${GRUB_BOOTSTRAP} ]]; then
		eautopoint --force
		AUTOPOINT=: AUTORECONF=: ./bootstrap || die
	elif [[ -n ${GRUB_AUTOGEN} ]]; then
		./autogen.sh || die
	fi

	if [[ -n ${GRUB_AUTORECONF} ]]; then
		autopoint() { :; }
		eautoreconf
	fi
}

grub_do() {
	multibuild_foreach_variant run_in_build_dir "$@"
}

grub_do_once() {
	multibuild_for_best_variant run_in_build_dir "$@"
}

grub_configure() {
	local platform

	case ${MULTIBUILD_VARIANT} in
		efi*) platform=efi ;;
		xen*) platform=xen ;;
		guessed) ;;
		*) platform=${MULTIBUILD_VARIANT} ;;
	esac

	case ${MULTIBUILD_VARIANT} in
		*-32)
			if [[ ${CTARGET:-${CHOST}} == x86_64* ]]; then
				local CTARGET=i386
			fi ;;
		*-64)
			if [[ ${CTARGET:-${CHOST}} == i?86* ]]; then
				local CTARGET=x86_64
				local -x TARGET_CFLAGS="-Os -march=x86-64 ${TARGET_CFLAGS}"
				local -x TARGET_CPPFLAGS="-march=x86-64 ${TARGET_CPPFLAGS}"
			fi ;;
	esac

	local myeconfargs=(
		TARGET_CFLAGS="$CFLAGS -I$(pwd)"
		TARGET_CPPFLAGS="${CPPFLAGS} -I$(pwd)"
		TARGET_LDFLAGS="-static"
		--disable-werror
		--program-prefix=
		--libdir="${EPREFIX}"/usr/lib
		--with-utils=host
		--target=${CHOST}
		--with-grubdir=${PN}
		--program-transform-name=s,${PN},${PN}2,
        	--with-debug-timestamps
        	--enable-boot-time
		$(use_enable device-mapper)
		$(use_enable mount grub-mount)
		$(use_enable themes grub-themes)
		$(use_enable truetype grub-mkfont)
		$(use_enable libzfs)
		$(use_enable sdl grub-emu-sdl)
		${platform:+--with-platform=}${platform}

		# Let configure detect this where supported
		$(usex efiemu '' '--disable-efiemu')
	)

	# Set up font symlinks
	ln -s "${WORKDIR}/${UNIFONT}.pcf" unifont.pcf || die
	if use themes; then
		ln -s "${WORKDIR}/${DEJAVU}/ttf/DejaVuSans.ttf" DejaVuSans.ttf || die
	fi

	local ECONF_SOURCE="${S}"
	econf "${myeconfargs[@]}"
}

src_configure() {
	# Bug 508758.
	replace-flags -O3 -O2
    	replace-flags -mregparm=3 -mregparm=4
	filter-flags '-O. ' '-fplugin=annobin' '-fstack-protector*' '-Wp,-D_FORTIFY_SOURCE=*' '--param=ssp-buffer-size=4' -fexceptions -fasynchronous-unwind-tables
	append-cflags -fno-strict-aliasing

	# We don't want to leak flags onto boot code.
	export HOST_CCASFLAGS=${CCASFLAGS}
	export HOST_CFLAGS=${CFLAGS}
	export HOST_CPPFLAGS="${CPPFLAGS} -I$(pwd)"
	export HOST_LDFLAGS=${LDFLAGS}
	unset CCASFLAGS CFLAGS CPPFLAGS LDFLAGS

	use static && HOST_LDFLAGS+=" -static"

	tc-ld-disable-gold #439082 #466536 #526348
	export TARGET_LDFLAGS="${TARGET_LDFLAGS} ${LDFLAGS}"
	unset LDFLAGS

	tc-export CC NM OBJCOPY RANLIB STRIP
	tc-export BUILD_CC # Bug 485592

	MULTIBUILD_VARIANTS=()
	local p
	for p in "${GRUB_ALL_PLATFORMS[@]}"; do
		use "grub_platforms_${p}" && MULTIBUILD_VARIANTS+=( "${p}" )
	done
	[[ ${#MULTIBUILD_VARIANTS[@]} -eq 0 ]] && MULTIBUILD_VARIANTS=( guessed )
	grub_do grub_configure
}

src_compile() {
	# Sandbox bug 404013.
	use libzfs && addpredict /etc/dfs:/dev/zfs

	grub_do emake
	use doc && grub_do_once emake -C docs html

    if use sign ; then
	GRUB_MODULES+=${grub_modules}
	GRUB_MODULES+=${efi_modules}
	GRUB_MODULES+=${platform_modules}

        cd ${GRUB_EFI64_S}
	cp $S/grub-${grub_target_name}-${PV/_p*}/sbat.csv .

        ./grub-mkimage -O ${grub_target_name} -o ${grubefiname}.orig -p /EFI/${efi_vendor} -d grub-core --sbat ./sbat.csv ${GRUB_MODULES} || die
        ./grub-mkimage -O ${grub_target_name} -o ${grubeficdname}.orig -p /EFI/BOOT -d grub-core --sbat ./sbat.csv ${GRUB_MODULES} || die

        _pesign ${grubefiname}.orig ${grubefiname}.one "${S13}" "${S14}" redhatsecureboot301 || die
        _pesign ${grubeficdname}.orig ${grubeficdname}.one "${S13}" "${S14}" redhatsecureboot301 || die
        _pesign ${grubefiname}.one ${grubefiname} "${S15}" "${S16}" redhatsecureboot502 || die
        _pesign ${grubeficdname}.one ${grubeficdname} "${S15}" "${S16}" redhatsecureboot502 || die
    fi
}

src_test() {
	# The qemu dependency is a bit complex.
	# You will need to adjust QEMU_SOFTMMU_TARGETS to match the cpu/platform.
	grub_do emake check
}

do_common_install()
{
	diropts -m0700
	dodir /${efi_esp_dir} /boot/grub /boot/loader/entries boot/$PN/themes/system ${_sysconfdir}/{default,sysconfig}

	touch ${ED}${_sysconfdir}/default/grub
	dosym ../default/grub ${_sysconfdir}/sysconfig/grub

	exeopts -m0700
	exeinto /${efi_esp_dir}
	doexe ${grubefiname} ${grubeficdname}

	${ED}/${_bindir}/grub2-editenv ${ED}/${efi_esp_dir}/grubenv create
	dosym ../efi/EFI/${efi_vendor}/grubenv /boot/grub/grubenv

	dosym ./grub2-mkconfig /usr/sbin/grub-mkconfig
}

src_install() {
	grub_do emake install DESTDIR="${D}" bashcompletiondir="$(get_bashcompdir)"
	use doc && grub_do_once emake -C docs install-html DESTDIR="${D}"

	einstalldocs

	insinto /etc/default
	newins "${FILESDIR}"/grub.default-3 grub

	diropts -m0700
	dodir /boot/loader/entries 

	exeinto ${_prefix}/lib/kernel/install.d
	doexe "${WORKDIR}"/{20-grub,99-grub-mkconfig}.install

	exeinto /etc/kernel/install.d
	newexe /dev/null 20-grubby.install
	newexe /dev/null 90-loaderentry.install

	if use sign ; then
		cd ${GRUB_EFI64_S}
		do_common_install
	fi
}

pkg_postinst() {
	elog "For information on how to configure GRUB2 please refer to the guide:"
	elog "    https://wiki.gentoo.org/wiki/GRUB2_Quick_Start"

	if has_version 'sys-boot/grub:0'; then
		elog "A migration guide for GRUB Legacy users is available:"
		elog "    https://wiki.gentoo.org/wiki/GRUB2_Migration"
	fi

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog
		elog "You may consider installing the following optional packages:"
		optfeature "Detect other operating systems (grub-mkconfig)" sys-boot/os-prober
		optfeature "Create rescue media (grub-mkrescue)" dev-libs/libisoburn
		optfeature "Enable RAID device detection" sys-fs/mdadm
	fi

	ewarn "\033[33mYour separate efi partition must be mounted at /boot/efi.\033[0m"
	ewarn "\033[33mIf use enable sign, Kernel must use sign kernel and modules.\033[0m"
}
