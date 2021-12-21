# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic libtool multilib-minimal usr-ldscript rhel9

DESCRIPTION="Access control list utilities, libraries, and headers"
HOMEPAGE="https://savannah.nongnu.org/projects/acl"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"
IUSE="nls static-libs"

RDEPEND="
	>=sys-apps/attr-2.4.47-r1[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="nls? ( sys-devel/gettext )"

src_prepare() {
	default

	# bug #580792
	elibtoolize
}

multilib_src_configure() {
	# Filter out -flto flags as they break getfacl/setfacl binaries
	# bug #667372
	filter-flags -flto*

	local myeconfargs=(
		--bindir="${EPREFIX}"/bin
		$(use_enable static-libs static)
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)
		$(use_enable nls)
	)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_test() {
	# make the test-suite use the just built library (instead of the system one)
	export LD_LIBRARY_PATH="$D/usr/$(get_libdir):${LD_LIBRARY_PATH}"

	if ./setfacl -m "u:$(id -u):rwx" .; then
		if test 0 = "$(id -u)"; then
			# test/root/permissions.test requires the 'daemon' user to be a member
			# of the 'bin' group in order not to fail.  Prevent the test from
			# running if we detect that its requirements are not met (#1085389).
			if id -nG daemon | { ! grep bin >/dev/null; }; then
				sed -e 's|test/root/permissions.test||' \
					-i test/Makemodule.am Makefile.in Makefile
			fi

			# test/root/setfacl.test fails if 'bin' user cannot access build dir
			if ! runuser -u bin -- "${PWD}/setfacl" --version; then
				sed -e 's|test/root/setfacl.test||' \
					-i test/Makemodule.am Makefile.in Makefile
			fi
		fi
		# Tests call native binaries with an LD_PRELOAD wrapper
		# bug #772356
		multilib_is_native_abi && default || exit $?
	else
		echo '*** ACLs are probably not supported by the file system,' \
			'the test-suite will NOT run ***'
	fi
}

multilib_src_install() {
	default

	# Move shared libs to /
	gen_usr_ldscript -a acl
}

multilib_src_install_all() {
	if ! use static-libs ; then
		find "${ED}" -type f -name "*.la" -delete || die
	fi
}
