# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit pam rhel8

if [[ ${PV} == *8888 ]]; then
	inherit autotools
else
	KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
fi
		
DESCRIPTION="Keyboard and console utilities"
HOMEPAGE="http://kbd-project.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="nls pam test"
#RESTRICT="!test? ( test )"
# Upstream has strange assumptions how to run tests (see bug #732868)
RESTRICT="test"

RDEPEND="
	app-arch/gzip
	pam? (
		!app-misc/vlock
		sys-libs/pam
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	test? ( dev-libs/check )
"

src_prepare() {
	default
	if [[ ${PV} == "9999" ]] || [[ $(ver_cut 3) -ge 90 ]] ; then
		eautoreconf
	fi
}

src_configure() {
	local myeconfargs=(
		# USE="test" installs .a files
		--disable-static
		$(use_enable nls)
		$(use_enable pam vlock)
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	# ro_win.map.gz is useless
	rm -f ${ED}/lib/kbd/keymaps/i386/qwerty/ro_win.map.gz

	# Move binaries which we use before /usr is mounted from /usr/bin to /bin.
	mkdir -p ${ED}/bin
	for binary in setfont dumpkeys kbd_mode unicode_start unicode_stop loadkeys ; do
  	   mv ${ED}/usr/bin/$binary ${ED}/bin/
	done

	# Some microoptimization
	sed -i -e 's,\<kbd_mode\>,/bin/kbd_mode,g;s,\<setfont\>,/bin/setfont,g' \
        	${ED}/bin/unicode_start

	# Link open to openvt
	ln -s openvt ${ED}/usr/bin/open

	# Install PAM configuration for vlock
	mkdir -p ${ED}/etc/pam.d
	install -m 644 ${WORKDIR}/vlock.pamd ${ED}/etc/pam.d/vlock

	# Convert X keyboard layouts (plain, no variant)
	cat layouts-list.lst | sort -u >> layouts-list-uniq.lst
	while read line; do
  	  ckbcomp "$line" | gzip > ${ED}/lib/kbd/keymaps/xkb/"$line".map.gz
	done < layouts-list-uniq.lst

	docinto html
	dodoc docs/doc/*.html

	# USE="test" installs .la files
	find "${ED}" -type f -name "*.la" -delete || die
	use pam && pamd_mimic_system vlock auth account
}
