# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel9.eclass
# @MAINTAINER:
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: backports packages Red Hat Enterprise Linux 9 Series RPMs

if [[ -z ${_RHEL9_ECLASS} ]] ; then
_RHEL9_ECLASS=1

if [ -z ${MY_PF} ] ; then
	MY_PR=${PVR##*r}

	if [ ${CATEGORY} == "dev-python" ] ; then
		case ${PN} in
			cython )  MY_P=${P^} ;;
			pyyaml )  MY_P=${P/pyyaml/PyYAML} ;;
			configshell-fb )  MY_P=python-${P/-fb} ;;
			pygobject ) MY_P=${P/-/3-} ;;
			jinja ) MY_P=${P/-/2-}; S=${WORKDIR}/${MY_P^}; MY_P=python-${MY_P} ;;
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
		S="${WORKDIR}/${P/_p*}"

		case ${PN} in
			tiff ) MY_P=lib${P} ;;
			ghostscript-gpl ) MY_P=${P/-gpl} ;;
			wayland-scanner ) MY_P=${P/-scanner} ;;
			lm-sensors ) MY_P=${P/-/_} ;;
			binutils-libs ) MY_P=${P/-libs} ;;
			libsdl* ) MY_P=${P/lib}; MY_P=${MY_P^^} ;;
			gdk-pixbuf ) MY_P=${P/gdk-pixbuf/gdk-pixbuf2} ;;
			xauth | xbitmaps | util-macros | xinit ) MY_P=xorg-x11-${P} ;;
			sysprof-capture )  MY_P=${P/-capture};S="${WORKDIR}/${MY_P}" ;;
			gst-plugins* )  MY_P=${P/-/reamer1-} ;;
			libnl | glib | openjpeg | gstreamer ) MY_P=${P/-/$(ver_cut 1)-} ;;
			gtk+ ) MY_P=${P/+/$(ver_cut 1)} ;;
			modemmanager ) MY_P=${P/modemmanager/ModemManager} ;;
			networkmanager ) MY_P=${P/networkmanager/NetworkManager} ;;
			*) MY_P=${P} ;;
		esac
	fi

	MY_P=${MY_P/_p*}

	DISTNUM=${BASH_SOURCE:0-8:1}

	inherit rpmbuild

fi

fi
