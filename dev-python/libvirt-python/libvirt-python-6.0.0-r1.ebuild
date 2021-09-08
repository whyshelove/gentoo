# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

DISTUTILS_USE_SETUPTOOLS=no
MY_P="${P/_rc/-rc}"

inherit distutils-r1 verify-sig rhel8-a

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://libvirt.org/git/libvirt-python.git"
	SRC_URI=""
	KEYWORDS=""
	RDEPEND="app-emulation/libvirt:=[-python(-)]"
else
	SRC_URI="${REPO_URI}/${MY_PF}.module_el8.5.0+746+bbd5d70c.src.rpm"
	KEYWORDS="amd64 arm64 ~ppc64 ~x86"
	RDEPEND="app-emulation/libvirt:0/${PV}"
fi
S="${WORKDIR}/${P%_rc*}"

DESCRIPTION="libvirt Python bindings"
HOMEPAGE="https://www.libvirt.org"
LICENSE="LGPL-2"
SLOT="0"
IUSE="examples test"
RESTRICT="!test? ( test )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/nose[${PYTHON_USEDEP}] )
	verify-sig? ( app-crypt/openpgp-keys-libvirt )"

python_test() {
	esetup.py test
}

python_install_all() {
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
	distutils-r1_python_install_all
}
