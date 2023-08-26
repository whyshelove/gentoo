# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="Python library to parse, validate and create SPDX documents"
HOMEPAGE="
	https://github.com/spdx/tools-python/
	https://pypi.org/project/spdx-tools/
"

LICENSE="Apache-2.0"
SLOT="0/0.7"
KEYWORDS="~amd64 ~riscv"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/ply[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/rdflib[${PYTHON_USEDEP}]
	dev-python/uritools[${PYTHON_USEDEP}]
	dev-python/xmltodict[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
