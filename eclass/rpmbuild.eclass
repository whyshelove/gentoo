# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel.eclass
# @MAINTAINER:
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: convenience class for extracting Red Hat Enterprise Linux Series RPMs

if [[ -z ${_RPMBUILD_ECLASS} ]] ; then
_RPMBUILD_ECLASS=1
_RHEL_ECLASS=1

inherit macros rpm

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

rpm_clean() {
	# delete everything
	rm -f *.patch
	local a
	for a in *.tar.{gz,bz2,xz} *.t{gz,bz2,xz,pxz} *.zip *.ZIP ; do
		rm -f "${a}"
	done
}

rhel_unpack() {
	rpmbuild_unpack
}

# @FUNCTION: rpmbuild_unpack
# @USAGE: <rpms>
# @DESCRIPTION:
# Unpack the contents of the specified Red Hat Enterprise Linux Series rpms like the unpack() function.
rpmbuild_unpack() {
	[[ $# -eq 0 ]] && set -- ${A}

	for a in ${@} ; do
		case ${a} in
		*.rpm) [[ ${a} =~ ".rpm" ]] && rpm_unpack "${a}" ;;
		*)	unpack "${a}" ;;
		esac
	done
}

# @FUNCTION: rpmbuild_env_setup
# @DESCRIPTION:
# rpmbuild_env_setup
rpmbuild_env_setup() {
	RPMBUILD=$HOME/rpmbuild
	mkdir -p $RPMBUILD
	ln -s $WORKDIR $RPMBUILD/SOURCES
	ln -s $WORKDIR $RPMBUILD/BUILD
}

# @FUNCTION: rpmbuild_prep
# @DESCRIPTION:
# build through %prep (unpack sources and apply patches) from <specfile>
rpmbuild_prep() {
	sed -i  -e "/#!%{__python3}/d" \
		-e "/@exec_prefix@/d" \
		-e "/py_provides/d" \
		-e "/%python_provide/d" \
		${WORKDIR}/*.spec
	
	if [[ ${unused_patches} ]]; then
		local p

		for p in "${unused_patches[@]}"; do
			sed -i "/${p}/d" ${WORKDIR}/*.spec || die
		done
	fi

	if [[ ${STAGE} != "unprep" ]]; then
		rpmbuild -bp $WORKDIR/*.spec --nodeps
	fi
}

# @FUNCTION: srcrpmbuild_unpack
# @USAGE: <rpms>
# @DESCRIPTION:
# Unpack the contents of the specified rpms like the unpack() function as well
# as any archives that it might contain.  Note that the secondary archive
# unpack isn't perfect in that it simply unpacks all archives in the working
# directory (with the assumption that there weren't any to start with).
srcrpmbuild_unpack() {
	[[ $# -eq 0 ]] && set -- ${A}
	rpm_unpack "$@"

	# no .src.rpm files, then nothing to do
	[[ "$* " != *".src.rpm " ]] && return 0

	eshopts_push -s nullglob

	rpmbuild_env_setup
	rpmbuild_prep

	eshopts_pop

	return 0
}

# @FUNCTION: rpmbuild_src_unpack
# @DESCRIPTION:
# Automatically unpack all archives in ${A} including rpms.  If one of the
# archives in a source rpm, then the sub archives will be unpacked as well.
rpmbuild_src_unpack() {
	if [[ ${PVR} == *9999 ]] || [[ -n ${_CS_ECLASS} ]]; then
		git-r3_src_unpack
		rpmbuild_env_setup
		mv $WORKDIR/${EGIT_CHECKOUT_DIR}/*  ${WORKDIR}/
		[[ -n ${SRC_URI} ]] && ln -s $DISTDIR/${MY_PN:-${PN}}* $WORKDIR/  || get_files='-g'
		rpmdev-spectool -l ${get_files} -R ${WORKDIR}/*.spec
		rpmbuild_prep
		return
	fi

	local a
	for a in ${A} ; do
		case ${a} in
		*.src.rpm) [[ ${a} =~ ".src.rpm" ]] && srcrpmbuild_unpack "${a}" ;;
		*.rpm) rpm_unpack "${a}" && mkdir -p $S ;;
		*)     unpack "${a}" ;;
		esac
	done
}

# @FUNCTION: rpmbuild_compile
# @DESCRIPTION:
# build through %build (%prep, then compile) from <specfile>
rpmbuild_compile() {
	rpmbuild  -bc $WORKDIR/*.spec --nodeps --nodebuginfo
}

# @FUNCTION: rpmbuild_install
# @DESCRIPTION:
# build through %install (skip straight to specified stage %prep, %build) from <specfile>
rpmbuild_install() {
	sed -i  -e '/rm -rf $RPM_BUILD_ROOT/d' \
		-e '/meson_install/d' \
		${WORKDIR}/*.spec

	rpmbuild --short-circuit -bi $WORKDIR/*.spec --nodeps --rmsource --nocheck --nodebuginfo --buildroot="${ED}"
}

# @FUNCTION: rhel_bin_install
# @DESCRIPTION:
rhel_bin_install() {
	rm -rf "${S_BASE}" "${WORKDIR}"/usr/lib/.build-id

	mv "${WORKDIR}"/* "${ED}"/

	mv "${ED}"/${P/_p*} "${WORKDIR}"/
}

# @FUNCTION: rpmbuild_pkg_postinst
# @DESCRIPTION:
rpmbuild_pkg_postinst() {
	if [[ -n ${QLIST} ]] ; then
		einfo "\033[31mqlist ${PN}\033[0m"
		qlist ${PN}
	fi
}

fi

EXPORT_FUNCTIONS src_unpack pkg_postinst
