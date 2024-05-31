# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

if [[ -z ${_C8S_ECLASS} ]] ; then
_C8S_ECLASS=1

if [[ -n ${EGIT_COMMIT} ]] ; then
	inherit cs8
	return
fi

if [[ -z ${_RHEL8_ECLASS} ]] ; then
	inherit rhel8
fi

 	DISTNUM=${BASH_SOURCE:0-9:1}
	releasever="${DISTNUM}"
	baseurl="https://${MIRROR_BIN:-vault}.centos.org/${MIRROR_BIN:+centos}/${releasever}-stream/${REPO:-BaseOS}"

	REPO_SRC="${baseurl}/Source/SPackages"
	REPO_BIN="${baseurl}/${WhatArch:=x86_64}/os/Packages"

	MY_PF=${MY_P}-${MY_PR} 

	case ${PN} in
		cython | modemmanager ) MY_P=${P} ;;
		*)  ;;
	esac

	#DIST_PRE_SUF=${MY_PF}.${DPREFIX}${DIST:=el${DISTNUM}}${DSUFFIX}

	#SRC_URI="${REPO_SRC}/${DIST_PRE_SUF}.src.rpm"
	#BIN_URI="${REPO_BIN}/${DIST_PRE_SUF}.${WhatArch:=x86_64}.rpm"

	SRC_URI+=" https://kojihub.stream.centos.org/kojifiles/packages/${MY_P/-//}/${MY_PR}.${DPREFIX}el8/src/${MY_PF}.${DPREFIX}el8.src.rpm"
fi
