# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *8888 ]]; then
	MY_PR=${PVR##*r}
	MY_PF=${P}.0-${MY_PR}
fi

inherit flag-o-matic toolchain-funcs prefix rhel

# Official patchlevel
# See ftp://ftp.cwru.edu/pub/bash/bash-5.0-patches/
PLEVEL="${PV##*_p}"
MY_PV="${PV/_p*}"
MY_PV="${MY_PV/_/-}"
MY_P="${PN}-${MY_PV}"

# The version of readline this bash normally ships with.
READLINE_VER="8.1"

DESCRIPTION="The standard GNU Bourne again shell"
HOMEPAGE="http://tiswww.case.edu/php/chet/bash/bashtop.html"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
SLOT="0"
[[ "${PV}" == *_rc* ]] || \
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="afs bashlogger examples mem-scramble +net nls plugins +readline"

DEPEND="
	>=sys-libs/ncurses-5.2-r2:0=
	nls? ( virtual/libintl )
	readline? ( >=sys-libs/readline-${READLINE_VER}:0= )
"
RDEPEND="
	${DEPEND}
"
# We only need yacc when the .y files get patched (bash42-005)
#BDEPEND="virtual/yacc"

PATCHES=(
	# Patches from Chet sent to bashbug ml
	"${FILESDIR}"/${PN}-5.0-syslog-history-extern.patch
)

pkg_setup() {
	# bug #7332
	if is-flag -malign-double ; then
		eerror "Detected bad CFLAGS '-malign-double'.  Do not use this"
		eerror "as it breaks LFS (struct stat64) on x86."
		die "remove -malign-double from your CFLAGS mr ricer"
	fi

	if use bashlogger ; then
		ewarn "The logging patch should ONLY be used in restricted (i.e. honeypot) envs."
		ewarn "This will log ALL output you enter into the shell, you have been warned."
	fi
}

src_prepare() {
	# Include official patches
	[[ ${PLEVEL} -gt 0 ]] && eapply -p0 $(patches -s)

	# Clean out local libs so we know we use system ones w/releases.

	rm -rf lib/{readline,termcap}/* || die
	touch lib/{readline,termcap}/Makefile.in || die # for config.status
	sed -ri -e 's:\$[{(](RL|HIST)_LIBSRC[)}]/[[:alpha:]_-]*\.h::g' Makefile.in || die

	# Prefixify hardcoded path names. No-op for non-prefix.
	hprefixify pathnames.h.in

	# Avoid regenerating docs after patches, bug #407985
	sed -i -r '/^(HS|RL)USER/s:=.*:=:' doc/Makefile.in || die
	touch -r . doc/* || die

	eapply -p0 "${PATCHES[@]}"
	eapply_user
	autoconf
}

src_configure() {
	local myconf=(
		--disable-profiling

		# Force linking with system curses ... the bundled termcap lib
		# sucks bad compared to ncurses.  For the most part, ncurses
		# is here because readline needs it.  But bash itself calls
		# ncurses in one or two small places :(.
		--with-curses

		$(use_enable mem-scramble)
		$(use_enable net net-redirections)
		$(use_enable readline)
		$(use_enable readline bang-history)
		$(use_enable readline history)
		$(use_with afs)
		$(use_with mem-scramble bash-malloc)
	)

	# For descriptions of these, see config-top.h
	# bashrc/#26952 bash_logout/#90488 ssh/#24762 mktemp/#574426
	append-cppflags \
		-DDEFAULT_PATH_VALUE=\'\"${EPREFIX}/usr/local/sbin:${EPREFIX}/usr/local/bin:${EPREFIX}/usr/sbin:${EPREFIX}/usr/bin:${EPREFIX}/sbin:${EPREFIX}/bin\"\' \
		-DSTANDARD_UTILS_PATH=\'\"${EPREFIX}/bin:${EPREFIX}/usr/bin:${EPREFIX}/sbin:${EPREFIX}/usr/sbin\"\' \
		-DSYS_BASHRC=\'\"${EPREFIX}/etc/bash/bashrc\"\' \
		-DSYS_BASH_LOGOUT=\'\"${EPREFIX}/etc/bash/bash_logout\"\' \
		-DNON_INTERACTIVE_LOGIN_SHELLS \
		-DSSH_SOURCE_BASHRC \
		$(use bashlogger && echo -DSYSLOG_HISTORY)

	# Don't even think about building this statically without
	# reading bug #7714 first.  If you still build it statically,
	# don't come crying to us with bugs ;).
	#use static && export LDFLAGS="${LDFLAGS} -static"
	use nls || myconf+=( --disable-nls )

	# Historically, we always used the builtin readline, but since
	# our handling of SONAME upgrades has gotten much more stable
	# in the PM (and the readline ebuild itself preserves the old
	# libs during upgrades), linking against the system copy should
	# be safe.
	# Exact cached version here doesn't really matter as long as it
	# is at least what's in the DEPEND up above.
	export ac_cv_rl_version=${READLINE_VER%%_*}


	# Use system readline only with released versions.
	myconf+=( --with-installed-readline=. )


	if use plugins ; then
		append-ldflags -Wl,-rpath,/usr/$(get_libdir)/bash
	else
		# Disable the plugins logic by hand since bash doesn't
		# provide a way of doing it.
		export ac_cv_func_dl{close,open,sym}=no \
			ac_cv_lib_dl_dlopen=no ac_cv_header_dlfcn_h=no

		sed -i \
			-e '/LOCAL_LDFLAGS=/s:-rdynamic::' \
			configure || die
	fi

	# bug #444070
	tc-export AR

	econf "${myconf[@]}"
	MFLAGS="CPPFLAGS=-D_GNU_SOURCE -DRECYCLES_PIDS -DDEFAULT_PATH_VALUE='\"/usr/local/bin:/usr/bin\"' `getconf LFS_CFLAGS`"
}

src_compile() {
	emake "$MFLAGS" version.h
	emake "$MFLAGS" -C builtins
	emake "$MFLAGS"

	if use plugins ; then
		emake -C examples/loadables all others
	fi
}

src_install() {
	if [ -e autoconf ]; then
	  # Yuck. We're using autoconf 2.1x.
	  export PATH=.:$PATH
	fi

	# Fix bug #83776
	sed -i -e 's,bashref\.info,bash.info,' doc/bashref.info

	local d f

	default

	rm -f ${D}/usr/share/info/dir

	dodir /bin
	mv "${ED}"/usr/bin/bash "${ED}"/bin/ || die
	dosym bash /bin/rbash
	dosym /bin/bash /usr/bin/bash

	insinto /etc/bash
	doins "${FILESDIR}"/bash_logout
	doins "$(prefixify_ro "${FILESDIR}"/bashrc)"

	keepdir /etc/bash/bashrc.d

	insinto /etc/skel
	for f in bash{_logout,_profile,rc} ; do
		newins "${WORKDIR}"/dot-${f} .${f}
	done

	local sed_args=(
		-e "s:#${USERLAND}#@::"
		-e '/#@/d'
	)

	if ! use readline ; then
		# bug #432338
		sed_args+=(
			-e '/^shopt -s histappend/s:^:#:'
			-e 's:use_color=true:use_color=false:'
		)
	fi

	sed -i \
		"${sed_args[@]}" \
		"${ED}"/etc/skel/.bashrc \
		"${ED}"/etc/bash/bashrc || die

	if use plugins ; then
		exeinto /usr/$(get_libdir)/bash
		doexe $(echo examples/loadables/*.o | sed 's:\.o::g')

		insinto /usr/include/bash-plugins
		doins *.h builtins/*.h include/*.h lib/{glob/glob.h,tilde/tilde.h}
	fi

	if use examples ; then
		for d in examples/{functions,misc,scripts,startup-files} ; do
			exeinto /usr/share/doc/${PF}/${d}
			docinto ${d}
			for f in ${d}/* ; do
				if [[ ${f##*/} != PERMISSION ]] && [[ ${f##*/} != *README ]] ; then
					doexe ${f}
				else
					dodoc ${f}
				fi
			done
		done
	fi
	doman doc/*.1
	newdoc CWRU/changelog ChangeLog
	dosym bash.info /usr/share/info/bashref.info
}

pkg_preinst() {
	if [[ -e ${EROOT}/etc/bashrc ]] && [[ ! -d ${EROOT}/etc/bash ]] ; then
		mkdir -p "${EROOT}"/etc/bash
		mv -f "${EROOT}"/etc/bashrc "${EROOT}"/etc/bash/
	fi
}

pkg_postinst() {
	# If /bin/sh does not exist, provide it
	if [[ ! -e ${EROOT}/bin/sh ]] ; then
		ln -sf bash "${EROOT}"/bin/sh
	fi
}
