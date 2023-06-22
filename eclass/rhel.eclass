# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel.eclass
# @MAINTAINER:
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: convenience class for extracting Red Hat Enterprise Linux Series RPMs

if [[ -z ${_RHEL_ECLASS} ]] ; then
_RHEL_ECLASS=1

inherit macros rpm

rpm_clean() {
	# delete everything
	rm -f *.patch
	local a
	for a in *.tar.{gz,bz2,xz} *.t{gz,bz2,xz,pxz} *.zip *.ZIP ; do
		rm -f "${a}"
	done
}

# @FUNCTION: rhel_unpack
# @USAGE: <rpms>
# @DESCRIPTION:
# Unpack the contents of the specified Red Hat Enterprise Linux Series rpms like the unpack() function.
rhel_unpack() {
	[[ $# -eq 0 ]] && set -- ${A}

	rpm_unpack "$@"

	RPMBUILD=$HOME/rpmbuild
	mkdir -p $RPMBUILD
	ln -s $WORKDIR $RPMBUILD/SOURCES
	ln -s $WORKDIR $RPMBUILD/BUILD
}

# @FUNCTION: srcrhel_unpack
# @USAGE: <rpms>
# @DESCRIPTION:
# Unpack the contents of the specified rpms like the unpack() function as well
# as any archives that it might contain.  Note that the secondary archive
# unpack isn't perfect in that it simply unpacks all archives in the working
# directory (with the assumption that there weren't any to start with).
srcrhel_unpack() {
	[[ $# -eq 0 ]] && set -- ${A}
	rhel_unpack "$@"

	# no .src.rpm files, then nothing to do
	[[ "$* " != *".src.rpm " ]] && return 0

	eshopts_push -s nullglob

	sed -i  -e "/%{gpgverify}/d" \
		-e "/#!%{__python3}/d" \
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

	eshopts_pop

	return 0
}

# @FUNCTION: rhel_src_unpack
# @DESCRIPTION:
# Automatically unpack all archives in ${A} including rpms.  If one of the
# archives in a source rpm, then the sub archives will be unpacked as well.
rhel_src_unpack() {
	if [[ ${PV} == *8888 ]]; then
		git-r3_src_unpack
		return
	fi

	local a
	for a in ${A} ; do
		case ${a} in
		*.src.rpm) [[ ${a} =~ ".src.rpm" ]] && srcrhel_unpack "${a}" ;;
		*.rpm) [[ ${a} =~ ".rpm" ]] && rpm_unpack "${a}" && mkdir -p $S ;;
		*)     unpack "${a}" ;;
		esac
	done
}

# @FUNCTION: rhel_src_compile
# @DESCRIPTION:
rhel_src_compile() {
	rpmbuild  -bc $WORKDIR/*.spec --nodeps --nodebuginfo
}

# @FUNCTION: rhel_src_install
# @DESCRIPTION:
rhel_src_install() {
	sed -i  -e '/rm -rf $RPM_BUILD_ROOT/d' \
		-e '/meson_install/d' \
		${WORKDIR}/*.spec

	rpmbuild --short-circuit -bi $WORKDIR/*.spec --nodeps --rmsource --nocheck --nodebuginfo --buildroot=$D
}

# @FUNCTION: rhel_bin_install
# @DESCRIPTION:
rhel_bin_install() {
	rm -rf "${S_BASE}" "${WORKDIR}"/usr/lib/.build-id

	insinto /
	doins -r "${WORKDIR}"/*

	rm -rf "${ED}"/${P}
}

rhel_pkg_postinst() {
	if [[ -n ${QLIST} ]] ; then
		einfo "\033[31mqlist ${PN}\033[0m"
		qlist ${PN}
	fi
}

fi

EXPORT_FUNCTIONS src_unpack pkg_postinst
