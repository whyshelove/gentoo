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
			cython )  MY_P=${P^} ;;
			pyyaml )  MY_P=${P/pyyaml/PyYAML} ;;
			configshell-fb )  MY_P=python-${P/-fb} ;;
			pygobject ) MY_P=${P/-/3-} ;;
			jinja ) MY_P=${P/-/2-}; S="${WORKDIR}/${MY_P^};  MY_P=python-${MY_P}" ;;
			publicsuffix ) MY_P=${P/-2./-list-}; S="${WORKDIR}/${MY_P}" ;;
			Babel | pytz | numpy | pyparsing | pyxdg | dbus-python | pycairo | python-dateutil \
			| pyserial)  MY_P=${P,,} ;;
			*)  MY_P=python-${P,,} ;;
		esac
	elif [ ${CATEGORY} == "dev-perl" ] || [ ${CATEGORY} == "perl-core" ] ; then
		[[ -n "${DIST_VERSION}" ]] && MY_PV=${DIST_VERSION}
		[[ -n "${MODULE_VERSION}" ]] && MY_PV=${MODULE_VERSION}
		 MY_P=perl-${PN}-${MY_PV}
		[[ ${PN} == Locale-gettext ]] &&  MY_P=perl-${PN/Locale-}-${DIST_VERSION}
	else
		case ${PN} in
			tiff | db | appstream-glib | mpc \
			| talloc | tdb | tevent | ldb )  MY_P=lib${P} ;;
			docbook-xsl-stylesheets )  MY_P=docbook-style-xsl-${PV} ;;
			ghostscript-gpl )  MY_P=${P/-gpl} ;;
			wayland-scanner )  MY_P=${P/-scanner} ;;
			lm-sensors )  MY_P=${P/-/_} ;;
			libsdl* ) MY_PT=${P/lib};  MY_P=${MY_PT^^} ;;
			gdk-pixbuf )  MY_P=${P/pixbuf/pixbuf2} ;;
			docbook-xsl-ns-stylesheets)  MY_P=docbook-style-xsl-${PV} ;;
			xauth | xbitmaps | util-macros | xinit )  MY_P=xorg-x11-${P} ;;
			libnl | glib | openjpeg | lcms | gnupg | grub | udisks | geoclue \
			| udisks | lcms | openjpeg | glib | librsvg | gstreamer | gtksourceview \
			| gtk | gdk-pixbuf | librsvg ) MY_P=${P/-/$(ver_cut 1)-} ;;
			libusb )  MY_P=${P/-/x-} ;;
			sysprof-capture )  MY_P=${P/-capture} ;;
			e2fsprogs-libs )  MY_P=${P/-libs} ;;
			procps ) MY_P=${P/-/-ng-} ;;
			thin-provisioning-tools )  MY_P=device-mapper-persistent-data-${PV} ;;
			iproute2 )  MY_P=${P/2} ;;
			mit-krb5 )  MY_P=${P/mit-} ;;
			ninja )  MY_P=${P/-/-build-} ;;
			shadow )  MY_P=${P/-/-utils-} ;;
			binutils-libs )  MY_P=${P/-libs} ;;
			webkit-gtk )  MY_P=${P/-gtk/2gtk3} ;;
			libnsl ) MY_P=${P/-/2-};  MY_P=${MY_P} ;;
			libpcre* ) MY_P=${P/lib};  MY_P=${MY_P} ;;
			xorg-proto )  MY_P=${PN/-/-x11-}-devel-${PV} ;;
			gtk+ ) MY_P=${P/+/$(ver_cut 1)} ;;
			xz-utils ) MY_P="${PN/-utils}-${PV/_}" ;;
			glib-utils ) MY_P="${PN/-utils}2-${PV}" ;;	
			python ) MY_P=${P%_p*};  MY_P=${MY_P/-/3.$(ver_cut 2)-} ;;
			nspr ) MY_P=nss-3.71.0; S="${WORKDIR}/${MY_P/.0}";;
			qtgui | qtcore | qtwidgets | qtdbus | qtnetwork | qttest | qtxml \
			| linguist-tools | qtsql | qtconcurrent | qdbus | qtpaths \
			| qtprintsupport | designer ) MY_P="qt5-${QT5_MODULE}-${PV}" ;;
			qtdeclarative | qtsvg | qtscript | qtgraphicaleffects | qtwayland | qtquickcontrols* \
			| qtxmlpatterns | qtwebchannel | qtx11extras )  MY_P=qt5-${P} ;;
			gst-plugins* )  MY_P=${P/-/reamer1-} ;;
			edk2-ovmf )  MY_P=${P}git${GITCOMMIT} ;;
			ipxe )  MY_P=${P}.${GIT_REV} ;;
			vte )  MY_P=${P/-/291-} ;;
			rhel-kernel ) MY_P=${P/rhel-};  MY_P=${MY_P}; MY_KVP=${PVR/r}.${DIST} ;;
			modemmanager )  MY_P=${P/modemmanager/ModemManager} ;;
			networkmanager )  MY_P=${P/networkmanager/NetworkManager} ;;
			vte )  MY_P=${P/-/291-} ;;
			libltdl )  MY_P=libtool-${PV} ;;
			*) MY_P=${P} ;;
		esac
	fi

		case ${PN} in
			asciidoc ) S="${WORKDIR}/${P/-/-py-}" ;;
			*)  ;;
		esac

	releasever="9"
	baseurl="https://cdn.redhat.com/content/dist/rhel${releasever}/${releasever}/x86_64/${REPO:-baseos}"

	REPO_SRC="${baseurl}/source/SRPMS/Packages"
	REPO_BIN="${baseurl}/os/Packages"

	MY_PF=${MY_P/_p*}-${MY_PR} 
	DIST_PRE_SUF_CATEGORY=${MY_P:0:1}/${MY_PF}.${DPREFIX}${DIST:=el9}${DSUFFIX}

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
