# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11,12} )

inherit distutils-r1

DESCRIPTION="Email client autoconfiguration service"
HOMEPAGE="https://rseichter.github.io/automx2/"
SRC_URI="https://github.com/rseichter/automx2/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="acct-user/automx2
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/flask-migrate[${PYTHON_USEDEP}]
	dev-python/flask-sqlalchemy[${PYTHON_USEDEP}]
	dev-python/ldap3[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/${P}-setupcfg.patch"
)

distutils_enable_tests unittest

python_test() {
	local -x AUTOMX2_CONF="tests/unittest.conf"
	eunittest tests/
}

python_install_all() {
	local DOCS=( "${S}"/docs/*.adoc "${S}"/contrib/*sample.conf )
	local HTML_DOCS=( "${S}"/docs/*.{html,svg} )
	newconfd "${FILESDIR}/confd" "${PN}"
	newinitd "${FILESDIR}/init-r1" "${PN}"
	insinto /etc
	newins "${FILESDIR}/conf" "${PN}.conf"
	distutils-r1_python_install_all
}
