# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

inherit rpmbuild

	DISTNUM=${BASH_SOURCE:0-8:1}
	releasever="${DISTNUM}"
	baseurl="https://cdn.redhat.com/content/dist/rhel${releasever}/${releasever}/x86_64/${REPO:-baseos}"

	REPO_SRC="${baseurl}/source/SRPMS/Packages"
	REPO_BIN="${baseurl}/os/Packages"

	MY_PF=${MY_P}-${MY_PR} 

	case ${PN} in
		cython | modemmanager ) MY_P=${P} ;;
		*)  ;;
	esac

	DIST_PRE_SUF_CATEGORY=${MY_P:0:1}/${MY_PF}.${DPREFIX}${DIST:=el${DISTNUM}}${DSUFFIX}

	SRC_URI="${REPO_SRC}/${DIST_PRE_SUF_CATEGORY}.src.rpm"
	BIN_URI="${REPO_BIN}/${DIST_PRE_SUF_CATEGORY}.${WhatArch:=x86_64}.rpm"
