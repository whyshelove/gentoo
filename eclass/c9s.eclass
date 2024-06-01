# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

if [[ -z ${_C9S_ECLASS} ]] ; then
_C9S_ECLASS=1

if [[ -n ${EGIT_COMMIT} ]] ; then
	inherit cs9
	return
fi

if [[ -z ${_RPMBUILD_ECLASS} ]] ; then
	inherit rpmbuild
fi

 	DISTNUM=${BASH_SOURCE:0-9:1}
	releasever="${DISTNUM}"
	baseurl="http://mirror.stream.centos.org/${releasever}-stream/${REPO:-BaseOS}"

	REPO_SRC="${baseurl}/source/tree/Packages"
	REPO_BIN="${baseurl}/os/Packages"

	MY_PF=${MY_P}-${MY_PR} 

	case ${PN} in
		cython | modemmanager ) MY_P=${P} ;;
		*)  ;;
	esac

	DIST_PRE_SUF=${MY_PF}.${DPREFIX}${DIST:=el${DISTNUM}}${DSUFFIX}

	SRC_URI="${REPO_SRC}/${DIST_PRE_SUF}.src.rpm"
	BIN_URI="${REPO_BIN}/${DIST_PRE_SUF}.${WhatArch:=x86_64}.rpm"

	SRC_URI+=" https://kojihub.stream.centos.org/kojifiles/packages/${MY_P/-//}/${MY_PR}.el9/src/${MY_PF}.el9.src.rpm"
fi
