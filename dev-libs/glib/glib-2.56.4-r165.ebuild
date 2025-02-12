# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{6..9} )
GNOME2_EAUTORECONF=yes
DSUFFIX="_10"
inherit autotools flag-o-matic gnome2 gnome.org gnome2-utils linux-info \
	multilib-minimal pax-utils python-any-r1 toolchain-funcs virtualx xdg rhel8

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2.1+"
SLOT="2"
IUSE="dbus debug +elf elibc_glibc fam gtk-doc kernel_linux +mime selinux static-libs systemtap test utils xattr"
RESTRICT="!test? ( test )"
REQUIRED_USE="gtk-doc? ( test )" # Bug #777636

KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"

# * elfutils (via libelf) does not build on Windows. gresources are not embedded
# within ELF binaries on that platform anyway and inspecting ELF binaries from
# other platforms is not that useful so exclude the dependency in this case.
# * Technically static-libs is needed on zlib, util-linux and perhaps more, but
# these are used by GIO, which glib[static-libs] consumers don't really seem
# to need at all, thus not imposing the deps for now and once some consumers
# are actually found to static link libgio-2.0.a, we can revisit and either add
# them or just put the (build) deps in that rare consumer instead of recursive
# RDEPEND here (due to lack of recursive DEPEND).
RDEPEND="
	!<dev-util/gdbus-codegen-${PV}
	>=virtual/libiconv-0-r1[${MULTILIB_USEDEP}]
	>=dev-libs/libpcre-8.13:3[${MULTILIB_USEDEP},static-libs?]
	>=dev-libs/libffi-3.0.13-r1:=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	>=virtual/libintl-0-r2[${MULTILIB_USEDEP}]
	kernel_linux? ( >=sys-apps/util-linux-2.23[${MULTILIB_USEDEP}] )
	selinux? ( >=sys-libs/libselinux-2.2.2-r5[${MULTILIB_USEDEP}] )
	xattr? ( !elibc_glibc? ( >=sys-apps/attr-2.4.47-r1[${MULTILIB_USEDEP}] ) )
	elf? ( virtual/libelf:0= )
	fam? ( >=virtual/fam-0-r1[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"
# libxml2 used for optional tests that get automatically skipped
BDEPEND="
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	>=sys-devel/gettext-0.19.8
	gtk-doc? ( !<dev-util/gtk-doc-1.15-r2
		app-text/docbook-xml-dtd:4.2
		app-text/docbook-xml-dtd:4.5 )
	systemtap? ( >=dev-util/systemtap-1.3 )
	${PYTHON_DEPS}
	test? ( >=sys-apps/dbus-1.2.14 )
	virtual/pkgconfig
"
# TODO: >=dev-util/gdbus-codegen-${PV} test dep once we modify gio/tests/meson.build to use external gdbus-codegen

PDEPEND="
	dbus? ( gnome-base/dconf )
	mime? ( x11-misc/shared-mime-info )
"
# shared-mime-info needed for gio/xdgmime, bug #409481
# dconf is needed to be able to save settings, bug #498436

MULTILIB_CHOST_TOOLS=(
	/usr/bin/gio-querymodules$(get_exeext)
)

pkg_setup() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INOTIFY_USER"
		if use test ; then
			CONFIG_CHECK="~IPV6"
			WARNING_IPV6="Your kernel needs IPV6 support for running some tests, skipping them."
		fi
		linux-info_pkg_setup
	fi
	python-any-r1_pkg_setup
}

src_prepare() {
	if use test; then
		# Disable tests requiring dev-util/desktop-file-utils when not installed, bug #286629, upstream bug #629163
		if ! has_version dev-util/desktop-file-utils ; then
			ewarn "Some tests will be skipped due dev-util/desktop-file-utils not being present on your system,"
			ewarn "think on installing it to get these tests run."
			sed -i -e "/appinfo\/associations/d" gio/tests/appinfo.c || die
			sed -i -e "/g_test_add_func/d" gio/tests/desktop-app-info.c || die
		fi

		# gdesktopappinfo requires existing terminal (gnome-terminal or any
		# other), falling back to xterm if one doesn't exist
		if ! has_version x11-terms/xterm && ! has_version x11-terms/gnome-terminal ; then
			ewarn "Some tests will be skipped due to missing terminal program"
			sed -i -e "/appinfo\/launch/d" gio/tests/appinfo.c || die
		fi

		# https://bugzilla.gnome.org/show_bug.cgi?id=722604
		sed -i -e "/timer\/stop/d" glib/tests/timer.c || die
		sed -i -e "/timer\/basic/d" glib/tests/timer.c || die

		ewarn "Tests for search-utils have been skipped"
		sed -i -e "/search-utils/d" glib/tests/Makefile.am || die
	else
		# Don't build tests, also prevents extra deps, bug #512022
		sed -i -e 's/ tests//' {.,gio,glib}/Makefile.am || die
	fi


	gnome2_src_prepare
	gnome2_environment_reset
}

multilib_src_configure() {
	if use debug; then
		append-cflags -DG_ENABLE_DEBUG
	else
		append-cflags -DG_DISABLE_CAST_CHECKS # https://gitlab.gnome.org/GNOME/glib/issues/1833
	fi

	# Avoid circular depend with dev-util/pkgconfig and
	# native builds (cross-compiles won't need pkg-config
	# in the target ROOT to work here)
	if ! tc-is-cross-compiler && ! $(tc-getPKG_CONFIG) --version >& /dev/null; then
		if has_version sys-apps/dbus; then
			export DBUS1_CFLAGS="-I/usr/include/dbus-1.0 -I/usr/$(get_libdir)/dbus-1.0/include"
			export DBUS1_LIBS="-ldbus-1"
		fi
		export LIBFFI_CFLAGS="-I$(echo /usr/$(get_libdir)/libffi-*/include)"
		export LIBFFI_LIBS="-lffi"
		export PCRE_CFLAGS=" " # test -n "$PCRE_CFLAGS" needs to pass
		export PCRE_LIBS="-lpcre"
	fi

	# These configure tests don't work when cross-compiling.
	if tc-is-cross-compiler ; then
		# https://bugzilla.gnome.org/show_bug.cgi?id=756473
		case ${CHOST} in
		hppa*|metag*) export glib_cv_stack_grows=yes ;;
		*)            export glib_cv_stack_grows=no ;;
		esac
		# https://bugzilla.gnome.org/show_bug.cgi?id=756474
		export glib_cv_uscore=no
		# https://bugzilla.gnome.org/show_bug.cgi?id=756475
		export ac_cv_func_posix_get{pwuid,grgid}_r=yes
	fi

	local myconf

	case "${CHOST}" in
		*-mingw*) myconf="${myconf} --with-threads=win32" ;;
		*)        myconf="${myconf} --with-threads=posix" ;;
	esac

	# libelf used only by the gresource bin
	ECONF_SOURCE="${S}" gnome2_src_configure ${myconf} \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable xattr) \
		$(use_enable fam) \
		$(use_enable kernel_linux libmount) \
		$(use_enable selinux) \
		$(use_enable static-libs static) \
		$(use_enable systemtap dtrace) \
		$(use_enable systemtap systemtap) \
		$(multilib_native_use_enable utils libelf) \
		--with-python=${EPYTHON} \
		--disable-compile-warnings \
		--enable-man \
		--with-pcre=system \
		--with-xml-catalog="${EPREFIX}/etc/xml/catalog"

	if multilib_is_native_abi; then
		local d
		for d in glib gio gobject; do
			ln -s "${S}"/docs/reference/${d}/html docs/reference/${d}/html || die
		done
	fi
}

multilib_src_test() {
	export XDG_CONFIG_DIRS=/etc/xdg
	export XDG_DATA_DIRS=/usr/local/share:/usr/share
	export G_DBUS_COOKIE_SHA1_KEYRING_DIR="${T}/temp"
	export LC_TIME=C # bug #411967
	unset GSETTINGS_BACKEND # bug #596380
	python_setup

	# Related test is a bit nitpicking
	mkdir "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"
	chmod 0700 "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"

	# Hardened: gdb needs this, bug #338891
	if host-is-pax ; then
		pax-mark -mr "${BUILD_DIR}"/tests/.libs/assert-msg-test \
			|| die "Hardened adjustment failed"
	fi

	# Need X for dbus-launch session X11 initialization
	virtx emake check
}

multilib_src_install() {
	default
	keepdir /usr/$(get_libdir)/gio/modules
}

multilib_src_install_all() {
	einstalldocs

	# These are installed by dev-util/glib-utils
	# TODO: With patching we might be able to get rid of the python-any deps and removals, and test depend on glib-utils instead; revisit with meson
	rm "${ED}usr/bin/glib-genmarshal" || die
	rm "${ED}usr/share/man/man1/glib-genmarshal.1" || die
	rm "${ED}usr/bin/glib-mkenums" || die
	rm "${ED}usr/share/man/man1/glib-mkenums.1" || die
	rm "${ED}usr/bin/gtester-report" || die
	rm "${ED}usr/share/man/man1/gtester-report.1" || die
	rm "${ED}usr/bin/gdbus-codegen" || die
 	rm "${ED}usr/share/man/man1/gdbus-codegen.1" || die

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${ED}/usr/$(get_libdir)/charset.alias"

	# Don't install gdb python macros, bug 291328
	rm -rf "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"

	# Completely useless with or without USE static-libs, people need to use pkg-config
	find "${ED}" -name '*.la' -delete || die
}

pkg_preinst() {
	xdg_pkg_preinst

	# Make gschemas.compiled belong to glib alone
	local cache="usr/share/glib-2.0/schemas/gschemas.compiled"

	if [[ -e ${EROOT}${cache} ]]; then
		cp "${EROOT}"${cache} "${ED}"/${cache} || die
	else
		touch "${ED}"/${cache} || die
	fi

	multilib_pkg_preinst() {
		# Make giomodule.cache belong to glib alone
		local cache="usr/$(get_libdir)/gio/modules/giomodule.cache"

		if [[ -e ${EROOT}${cache} ]]; then
			cp "${EROOT}"${cache} "${ED}"/${cache} || die
		else
			touch "${ED}"/${cache} || die
		fi
	}

	# Don't run the cache ownership when cross-compiling, as it would end up with an empty cache
	# file due to inability to create it and GIO might not look at any of the modules there
	if ! tc-is-cross-compiler ; then
		multilib_foreach_abi multilib_pkg_preinst
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	# glib installs no schemas itself, but we force update for fresh install in case
	# something has dropped in a schemas file without direct glib dep; and for upgrades
	# in case the compiled schema format could have changed
	gnome2_schemas_update

	multilib_pkg_postinst() {
		gnome2_giomodule_cache_update \
			|| die "Update GIO modules cache failed (for ${ABI})"
	}
	if ! tc-is-cross-compiler ; then
		multilib_foreach_abi multilib_pkg_postinst
	else
		ewarn "Updating of GIO modules cache skipped due to cross-compilation."
		ewarn "You might want to run gio-querymodules manually on the target for"
		ewarn "your final image for performance reasons and re-run it when packages"
		ewarn "installing GIO modules get upgraded or added to the image."
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update

	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		multilib_pkg_postrm() {
			rm -f "${EROOT}"usr/$(get_libdir)/gio/modules/giomodule.cache
		}
		multilib_foreach_abi multilib_pkg_postrm
		rm -f "${EROOT}"usr/share/glib-2.0/schemas/gschemas.compiled
	fi
}

