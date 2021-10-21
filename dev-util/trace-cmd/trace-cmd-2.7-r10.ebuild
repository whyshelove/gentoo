# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6,8,9} )
DISTUTILS_OPTIONAL=1

inherit linux-info bash-completion-r1 python-r1 toolchain-funcs systemd flag-o-matic rhel8

DESCRIPTION="User-space front-end for Ftrace"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/rostedt/trace-cmd.git"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://git.kernel.org/pub/scm/linux/kernel/git/rostedt/${PN}.git"
	inherit git-r3
else
	KEYWORDS="amd64 ~arm64 ~x86"
	S="${WORKDIR}/${PN}-v${PV}"
fi

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0/${PV}"
IUSE="+audit doc test udis86"
RESTRICT="!test? ( test )"

RDEPEND="
	audit? ( sys-process/audit )
	udis86? ( dev-libs/udis86 )
"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	test? ( dev-util/cunit )
"
BDEPEND="
	doc? ( app-text/asciidoc )
"

# having trouble getting tests to compile
RESTRICT+=" test"

pkg_setup() {
	local CONFIG_CHECK="
		~TRACING
		~FTRACE
		~BLK_DEV_IO_TRACE"

	linux-info_pkg_setup
}

PATCHES=(
	"${FILESDIR}"/trace-cmd-2.7-makefile.patch
	"${FILESDIR}"/trace-cmd-2.7-soname.patch
)

src_prepare() {
	default
	sed -r -e 's:([[:space:]]+)install_bash_completion($|[[:space:]]+):\1:' \
		-i Makefile || die "sed failed"
}

src_configure() {
	append-cflags -D_GNU_SOURCE -g -Wall -fPIE -fstack-protector-strong --param=ssp-buffer-size=4 -fstack-clash-protection -fexceptions
	append-ldflags -pie -Wl,-z,now

	EMAKE_FLAGS=(
		"prefix=${EPREFIX}/usr"
		"libdir=${EPREFIX}/usr/$(get_libdir)"
		"CC=$(tc-getCC)"
		"AR=$(tc-getAR)"
		"BASH_COMPLETE_DIR=$(get_bashcompdir)"
		"etcdir=/etc"
		$(usex audit '' 'NO_AUDIT=' '' '1')
		$(usex test 'CUNIT_INSTALLED=' '' '1' '')
		$(usex udis86 '' 'NO_UDIS86=' '' '1')
		VERBOSE=1
	)
}

src_compile() {
	emake "${EMAKE_FLAGS[@]}" NO_PYTHON=1 \
		trace-cmd gui

	use doc && emake doc
}

src_test() {
	emake "${EMAKE_FLAGS[@]}" test
}

src_install() {
	emake "${EMAKE_FLAGS[@]}" NO_PYTHON=1 \
		DESTDIR="${D}" \
		install install_libs install_gui

	insopts -m0755
	insinto ${_datadir}/applications
	doins "${WORKDIR}"/kernelshark.desktop

	insinto ${_sysconfdir}/sysconfig
	doins trace-cmd.conf

	insinto ${_udevrulesdir}
	doins 98-trace-cmd.rules

	systemd_dounit trace-cmd.service

	use doc && emake DESTDIR="${D}" install_doc
}
