# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DSUFFIX="_8"
inherit flag-o-matic toolchain-funcs systemd usr-ldscript rhel8

DESCRIPTION="xfs filesystem utilities"
HOMEPAGE="https://xfs.wiki.kernel.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="icu libedit nls readline static-libs"

RDEPEND=">=sys-apps/util-linux-2.17.2
	dev-libs/inih
	icu? ( dev-libs/icu:= )
	readline? ( sys-libs/readline:0= )
	!readline? ( libedit? ( dev-libs/libedit ) )
"
DEPEND="${RDEPEND}"
BDEPEND="
	nls? ( sys-devel/gettext )
"

PATCHES=(
	"${FILESDIR}"/${PN}-4.9.0-underlinking.patch
	"${FILESDIR}"/${PN}-4.15.0-sharedlibs.patch
	"${FILESDIR}"/${PN}-4.15.0-docdir.patch
)

src_prepare() {
	default

	# Fix doc dir
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		include/builddefs.in || die

	# Clear out -static from all flags since we want to link against dynamic xfs libs.
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		include/builddefs.in || die
	# Don't install compressed docs
	sed 's@\(CHANGES\)\.gz[[:space:]]@\1 @' -i doc/Makefile || die
	find -name Makefile -exec \
		sed -i -r -e '/^LLDFLAGS [+]?= -static(-libtool-libs)?$/d' {} +
}

src_configure() {
	# include/builddefs.in will add FCFLAGS to CFLAGS which will
	# unnecessarily clutter CFLAGS (and fortran isn't used)
	unset FCFLAGS

	export DEBUG=-DNDEBUG

	# Package is honoring CFLAGS; No need to use OPTIMIZER anymore.
	# However, we have to provide an empty value to avoid default
	# flags.
	export OPTIMIZER=" "

	unset PLATFORM # if set in user env, this breaks configure

	# Avoid automagic on libdevmapper, #709694
	export ac_cv_search_dm_task_create=no

	# Build fails with -O3 (bug #712698)
	replace-flags -O3 -O2

	local myconf=(
		--enable-scrub=no
		--enable-blkid
		--with-crond-dir="${EPREFIX}/etc/cron.d"
		--with-systemd-unit-dir="$(systemd_get_systemunitdir)"
		$(use_enable icu libicu)
		$(use_enable nls gettext)
		$(use_enable readline)
		$(usex readline --disable-editline $(use_enable libedit editline))
		$(use_enable static-libs static)
	)

	if is-flagq -flto ; then
		myconf+=( --enable-lto )
	else
		myconf+=( --disable-lto )
	fi

	econf "${myconf[@]}"

	MAKEOPTS+=" V=1"
}

src_install() {
	emake DIST_ROOT="${ED}" install
	# parallel install fails on this target for >=xfsprogs-3.2.0
	emake -j1 DIST_ROOT="${ED}" install-dev

	# handle is for xfsdump, the rest for xfsprogs
	gen_usr_ldscript -a handle xcmd xfs xlog frog
	# removing unnecessary .la files if not needed
	if ! use static-libs ; then
		find "${ED}" -name '*.la' -delete || die
	fi
}

