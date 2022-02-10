# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,8,9,10} )

DISTUTILS_USE_SETUPTOOLS=no

MY_P="${P/_rc/-rc}"

inherit distutils-r1 verify-sig rhel8-a

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://libvirt.org/git/libvirt-python.git"
	RDEPEND="app-emulation/libvirt:=[-python(-)]"
else
	SRC_URI="${REPO_URI}/${MY_PF}.module_el8.6.0+1046+bd8eec5e.src.rpm"
	KEYWORDS="amd64 arm64 ~ppc64 ~x86"
	RDEPEND="app-emulation/libvirt:0/${PV}"
fi
S="${WORKDIR}/${P%_rc*}"

DESCRIPTION="libvirt Python bindings"
HOMEPAGE="https://www.libvirt.org"
LICENSE="LGPL-2"
SLOT="0"
VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/libvirt.org.asc
IUSE="examples test"
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
	test? (
		dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
	)
	verify-sig? ( sec-keys/openpgp-keys-libvirt )
"

distutils_enable_tests setup.py

python_install_all() {
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
	distutils-r1_python_install_all
}
