# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel.eclass
# @MAINTAINER:
# base-system@gentoo.org
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: convenience class for extracting Red Hat Enterprise Linux Series RPMs

if [[ -z ${_RHEL_ECLASS} ]] ; then
_RHEL_ECLASS=1

inherit macros rpm

if [[ ${PV} == *8888 ]]; then
	inherit git-r3
	CENTOS_GIT_REPO_URI="https://gitlab.com/redhat/centos-stream/rpms"
	EGIT_REPO_URI="${CENTOS_GIT_REPO_URI}/${PN}.git"
	S="${WORKDIR}/${PN}"
fi

if [ -z ${MY_PF} ] ; then
	MY_PR=${PVR##*r}

	if [ ${CATEGORY} == "dev-python" ] ; then
		case ${PN} in
			cython ) MY_PF=${P^}-${MY_PR} ;;
			pyyaml ) MY_PF=${P/pyyaml/PyYAML}-${MY_PR} ;;
			configshell-fb ) MY_PF=python-${P/-fb}-${MY_PR} ;;
			pygobject ) MY_P=${P/-/3-}; MY_PF=${MY_P}-${MY_PR} ;;
			jinja ) MY_P=${P/-/2-}; MY_PF=python-${MY_P}-${MY_PR}; S="${WORKDIR}/${MY_P^}" ;;
			publicsuffix ) MY_P=${P/-2./-list-}; MY_PF=${MY_P}-${MY_PR}; S="${WORKDIR}/${MY_P}" ;;
			Babel | pytz | numpy | pyparsing | pyxdg | dbus-python | pycairo | python-dateutil \
			| pyserial) MY_PF=${P,,}-${MY_PR} ;;
			*) MY_PF=python-${P,,}-${MY_PR} ;;
		esac
	elif [ ${CATEGORY} == "dev-perl" ] || [ ${CATEGORY} == "perl-core" ] ; then
		[[ -n "${DIST_VERSION}" ]] && MY_PV=${DIST_VERSION}
		[[ -n "${MODULE_VERSION}" ]] && MY_PV=${MODULE_VERSION}
		MY_PF=perl-${PN}-${MY_PV}-${MY_PR}
		[[ ${PN} == Locale-gettext ]] && MY_PF=perl-${PN/Locale-}-${DIST_VERSION}-${MY_PR}
	else
		case ${PN} in
			tiff | db | appstream-glib | mpc \
			| talloc | tdb | tevent | ldb ) MY_PF=lib${P}-${MY_PR} ;;
			docbook-xsl-stylesheets ) MY_PF=docbook-style-xsl-${PV}-${MY_PR} ;;
			ghostscript-gpl ) MY_PF=${P/-gpl}-${MY_PR} ;;
			wayland-scanner ) MY_PF=${P/-scanner}-${MY_PR} ;;
			lm-sensors ) MY_PF=${P/-/_}-${MY_PR} ;;
			libsdl* ) MY_P=${P/lib}; MY_PF=${MY_P^^}-${MY_PR} ;;
			gdk-pixbuf ) MY_PF=${P/pixbuf/pixbuf2}-${MY_PR} ;;
			docbook-xsl-ns-stylesheets) MY_PF=docbook-style-xsl-${PV}-${MY_PR} ;;
			xauth | xbitmaps | util-macros | xinit ) MY_PF=xorg-x11-${P}-${MY_PR} ;;
			libnl | glib | openjpeg | lcms | gnupg | grub | udisks | geoclue \
			| udisks | lcms | openjpeg | glib | librsvg | gstreamer | gtksourceview \
			| gtk | gdk-pixbuf | librsvg ) MY_P=${P/-/$(ver_cut 1)-}; MY_PF=${MY_P}-${MY_PR} ;;
			libusb ) MY_PF=${P/-/x-}-${MY_PR} ;;
			sysprof-capture ) MY_PF=${P/-capture}-${MY_PR} ;;
			e2fsprogs-libs ) MY_PF=${P/-libs}-${MY_PR} ;;
			procps ) MY_P=${P/-/-ng-}; MY_PF=${MY_P}-${MY_PR} ;;
			thin-provisioning-tools ) MY_PF=device-mapper-persistent-data-${PV}-${MY_PR} ;;
			iproute2 ) MY_PF=${P/2}-${MY_PR} ;;
			mit-krb5 ) MY_PF=${P/mit-}-${MY_PR} ;;
			ninja ) MY_PF=${P/-/-build-}-${MY_PR} ;;
			shadow ) MY_PF=${P/-/-utils-}-${MY_PR} ;;
			binutils-libs ) MY_PF=${P/-libs}-${MY_PR} ;;
			webkit-gtk ) MY_PF=${P/-gtk/2gtk3}-${MY_PR} ;;
			libnsl ) MY_P=${P/-/2-}; MY_PF=${MY_P}-${MY_PR} ;;
			libpcre* ) MY_P=${P/lib}; MY_PF=${MY_P}-${MY_PR} ;;
			xorg-proto ) MY_PF=${PN/-/-x11-}-devel-${PV}-${MY_PR} ;;
			gtk+ ) MY_P=${P/+/$(ver_cut 1)}; MY_PF=${MY_P}-${MY_PR} ;;
			xz-utils ) MY_P="${PN/-utils}-${PV/_}"; MY_PF=${MY_P}-${MY_PR} ;;
			glib-utils ) MY_P="${PN/-utils}2-${PV}"; MY_PF=${MY_P}-${MY_PR} ;;	
			python ) MY_P=${P%_p*}; MY_PF=${MY_P/-/3.$(ver_cut 2)-}-${MY_PR} ;;
			nspr ) MY_P=nss-3.71.0; MY_PF=${MY_P}-${MY_PR}; S="${WORKDIR}/${MY_P/.0}";;
			qtgui | qtcore | qtwidgets | qtdbus | qtnetwork | qttest | qtxml \
			| linguist-tools | qtsql | qtconcurrent | qdbus | qtpaths \
			| qtprintsupport | designer ) MY_P="qt5-${QT5_MODULE}-${PV}"; MY_PF=${MY_P}-${MY_PR} ;;
			qtdeclarative | qtsvg | qtscript | qtgraphicaleffects | qtwayland | qtquickcontrols* \
			| qtxmlpatterns | qtwebchannel | qtx11extras ) MY_PF=qt5-${P}-${MY_PR} ;;
			gst-plugins* ) MY_PF=${P/-/reamer1-}-${MY_PR} ;;
			edk2-ovmf ) MY_PF=${P}git${GITCOMMIT}-${MY_PR} ;;
			ipxe ) MY_PF=${P}-${MY_PR}.${GIT_REV} ;;
			vte ) MY_PF=${P/-/291-}-${MY_PR} ;;
			rhel-kernel ) MY_P=${P/rhel-}; MY_PF=${MY_P}-${MY_PR}; MY_KVP=${PVR/r}.${DIST} ;;
			modemmanager ) MY_PF=${P/modemmanager/ModemManager}-${MY_PR} ;;
			networkmanager ) MY_PF=${P/networkmanager/NetworkManager}-${MY_PR} ;;
			vte ) MY_PF=${P/-/291-}-${MY_PR} ;;
			libltdl ) MY_PF=libtool-${PV}-${MY_PR} ;;
			*) MY_PF=${P}-${MY_PR} ;;
		esac
	fi
	MY_PN=${PN}
	releasever="9"
	baseurl="https://cdn.redhat.com/content/dist/rhel${releasever}/${releasever}/x86_64/${REPO:-baseos}"

	REPO_SRC="${baseurl}/source/SRPMS/Packages"
	REPO_BIN="${baseurl}/os/Packages"

	DIST_PRE_SUF_CATEGORY=${MY_PN:0:1}/${MY_PF}.${PREFIX}${DIST:=el9}${SUFFIX}

	[ ${CATEGORY} != "dev-qt" ] && SRC_URI=""
	SRC_URI="${REPO_SRC}/${DIST_PRE_SUF_CATEGORY}.src.rpm"
	BIN_URI="${REPO_BIN}/${DIST_PRE_SUF_CATEGORY}.${WhatArch:=x86_64}.rpm"
fi

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

	for a in ${@} ; do
		case ${a} in
		*.rpm) [[ ${a} =~ ".rpm" ]] && rpm_unpack "${a}" ;;
		*)	unpack "${a}" ;;
		esac
	done

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

#	FIND_FILE="${WORKDIR}/*.spec"
#	FIND_STR="pypi_source"
#	if [ `grep -c "$FIND_STR" $FIND_FILE` -ne '0' ] ;then
#		echo -e "The spec File Has\c"
#		echo -e "\033[33m $FIND_STR \033[0m\c"
#		echo "Skipp rpm build through %prep..."
#		unpack ${WORKDIR}/*.tar.*
#		return 0
#	fi

	eshopts_push -s nullglob

	#sed -i -e "/#!%{__python3}/d" \
	#	${WORKDIR}/*.spec
	
	rpmbuild -bp $WORKDIR/*.spec --nodeps

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
	if use binary; then
		rm -rf $S ${S_BASE} "${WORKDIR}/usr/lib/.build-id"
		mv "${WORKDIR}"/* "${D}"/
		tree "${ED}"
	fi
}

fi

EXPORT_FUNCTIONS src_unpack
