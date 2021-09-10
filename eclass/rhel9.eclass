# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel9.eclass
# @MAINTAINER:
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: backports packages Red Hat Enterprise Linux 9 Series RPMs

if [[ -z ${_RHEL9_ECLASS} ]] ; then
_RHEL9_ECLASS=1

inherit rhel

MIRROR="https://odcs.stream.centos.org/production/latest-CentOS-Stream"
DIST="el9"
RELEASE="compose"
REPO_URI="${MIRROR}/${RELEASE}/${REPO:-BaseOS}/source/tree/Packages"

if [ -z ${MY_PF} ] ; then
	MY_PR=${PVR##*r}

	if [ ${CATEGORY} == "dev-python" ] && [ ${PN} != lxml ] ; then
		case ${PN} in
			cython ) MY_PF=${P^}-${MY_PR} ;;
			pyyaml ) MY_PF=${P/pyyaml/PyYAML}-${MY_PR} ;;
			configshell-fb ) MY_PF=python-${P/-fb}-${MY_PR} ;;
			pygobject ) MY_P=${P/-/3-}; MY_PF=${MY_P}-${MY_PR} ;;
			jinja ) MY_P=${P/-/2-}; MY_PF=python-${MY_P}-${MY_PR}; S="${WORKDIR}/${MY_P^j}" ;;
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
			tiff ) MY_PF=lib${P}-${MY_PR} ;;
			ghostscript-gpl ) MY_PF=${P/-gpl}-${MY_PR} ;;
			wayland-scanner ) MY_PF=${P/-scanner}-${MY_PR} ;;
			libsdl* ) MY_P=${P/lib}; MY_PF=${MY_P^^}-${MY_PR} ;;
			gdk-pixbuf ) MY_PF=${P/gdk-pixbuf/gdk-pixbuf2}-${MY_PR} ;;
			docbook-xsl-ns-stylesheets) MY_PF=docbook-style-xsl-${PV}-${MY_PR} ;;
			xauth | xbitmaps | util-macros | xinit ) MY_PF=xorg-x11-${P}-${MY_PR} ;;
			libnl | glib | openjpeg ) MY_P=${P/-/$(ver_cut 1)-}; MY_PF=${MY_P}-${MY_PR} ;;
			gtk+ ) MY_P=${P/+/$(ver_cut 1)}; MY_PF=${MY_P}-${MY_PR} ;;
			modemmanager ) MY_PF=${P/modemmanager/ModemManager}-${MY_PR} ;;
			networkmanager ) MY_PF=${P/networkmanager/NetworkManager}-${MY_PR} ;;
			*) MY_PF=${P}-${MY_PR} ;;
		esac

	fi
fi
SRC_URI="${REPO_URI}/${MY_PF}.${DIST}.src.rpm"

fi
