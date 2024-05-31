# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

if [[ -z ${_CS_ECLASS} ]] ; then
_CS_ECLASS=1
DEPEND="dev-util/rpmdevtools"

	EGIT_BRANCH=c8s
	EGIT_CHECKOUT_DIR=${EGIT_CHECKOUT_DIR:-${EGIT_BRANCH}}
	CENTOS_GIT_REPO_URI="https://gitlab.com/redhat/centos-stream/rpms"
	EGIT_REPO_URI="${CENTOS_GIT_REPO_URI}/${MY_PN:-${PN}}.git"

	inherit git-r3

if [[ -z ${_RHEL8_ECLASS} ]] ; then
	inherit rhel8
fi
	unset SRC_URI

fi
