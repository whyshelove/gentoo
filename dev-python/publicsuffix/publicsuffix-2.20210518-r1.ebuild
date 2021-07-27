# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,8,9} )
inherit distutils-r1 rhel

DESCRIPTION="Get a public suffix for a domain name using the Public Suffix List."
HOMEPAGE="https://github.com/nexB/python-publicsuffix2"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}2/${PN}2-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~x86"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	>=dev-python/requests-2.7.0[${PYTHON_USEDEP}]"
BDEPEND=""

src_compile() { :; }

src_install() {
	insinto ${_datadir}/publicsuffix/
	doins -r "${WORKDIR}"/{"public_suffix_list.dat","test_psl.txt"}
	dosym public_suffix_list.dat ${_datadir}/publicsuffix/effective_tld_names.dat
}
