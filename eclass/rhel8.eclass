# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel8.eclass
# @MAINTAINER:
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: backports packages Red Hat Enterprise Linux 8 Series RPMs

if [[ -z ${_RHEL8_ECLASS} ]] ; then
_RHEL8_ECLASS=1

if [[ ${PV} == *8888 ]]; then
	inherit git-r3
	CENTOS_GIT_REPO_URI="https://gitlab.com/redhat/centos-stream/src"
	EGIT_REPO_URI="${CENTOS_GIT_REPO_URI}/${PN}.git"
	S="${WORKDIR}/${P}"
else
	inherit rhel
	if [ -z ${MIRROR} ] ; then MIRROR="https://vault.centos.org"; fi
	DIST="el8"
	RELEASE="8-stream"
	REPO_URI="${MIRROR}/${RELEASE}/${REPO:-BaseOS}/Source/SPackages"

	if [ -z ${MIRROR_BIN} ] ; then MIRROR_BIN="http://mirror.centos.org/centos"; fi
	REPO_BIN="${MIRROR_BIN}/${RELEASE}/${REPO:-BaseOS}/x86_64/os/Packages"

	if [ -z ${MY_PF} ] ; then
		MY_PR=${PVR##*r}

		case ${PN} in
			tiff | db | appstream-glib ) MY_PF=lib${P}-${MY_PR} ;;
			docbook-xsl-stylesheets ) MY_PF=docbook-style-xsl-${PV}-${MY_PR} ;;
			thin-provisioning-tools ) MY_PF=device-mapper-persistent-data-${PV}-${MY_PR} ;;
			multipath-tools ) MY_PF=device-mapper-multipath-${PV}-${MY_PR} ;;
			iproute2 ) MY_PF=${P/2}-${MY_PR} ;;
			mit-krb5 ) MY_PF=${P/mit-}-${MY_PR} ;;
			lxml ) MY_PF=python-${P}-${MY_PR} ;;
			ninja) MY_PF=${P/-/-build-}-${MY_PR} ;;
			shadow ) MY_PF=${P/-/-utils-}-${MY_PR} ;;
			webkit-gtk ) MY_PF=${P/-gtk/2gtk3}-${MY_PR} ;;
			libpcre* ) MY_P=${P/lib}; MY_PF=${MY_P}-${MY_PR} ;;
			libnsl ) MY_P=${P/-/2-}; MY_PF=${MY_P}-${MY_PR} ;;
			xorg-proto ) MY_PF=${PN/-/-x11-}-devel-${PV}-${MY_PR} ;;
			xorg-server ) MY_PF=${P/-/-x11-}-2 ;;
			gtk+ ) MY_P=${P/+/$(ver_cut 1)}; MY_PF=${MY_P}-${MY_PR} ;;
			xz-utils ) MY_P="${PN/-utils}-${PV/_}"; MY_PF=${MY_P}-${MY_PR} ;;
			python ) MY_PR=${PVR##*p}; MY_P=${P%_p*}; MY_PF=${MY_P/-/3$(ver_cut 2)-}-${MY_PR} ;;
			udisks | gnupg | grub | lcms | glib | enchant | gstreamer \
			| gtksourceview ) MY_P=${P/-/$(ver_cut 1)-}; MY_PF=${MY_P}-${MY_PR} ;;
			mpc | talloc | tdb | tevent | ldb ) MY_PF=lib${P}-${MY_PR}; [[ ${PN} == mpc ]] && MY_PF=${MY_PF}.1 ;;
			go ) MY_PF=${P/-/lang-}-${MY_PR} ;;
			cunit ) MY_PF=${P^^[cu]}-${MY_PR} ;;
			libusb ) MY_PF=${P/-/x-}-${MY_PR} ;;
			gtk-doc-am ) MY_PF=${P/-am}-${MY_PR} ;;
			e2fsprogs-libs ) MY_PF=${P/-libs}-${MY_PR} ;;
			openssh ) PARCH=${P/_}; MY_PF=${PARCH}-${MY_PR} ;;
			procps ) MY_P=${P/-/-ng-}; MY_PF=${MY_P}-${MY_PR} ;;
			qtgui | qtcore | qtdbus | qtnetwork | qttest | qtxml \
			| linguist-tools | qtsql | qtconcurrent | qdbus | qtpaths \
			| qtprintsupport | designer ) MY_P="qt5-${QT5_MODULE}-${PV}"; MY_PF=${MY_P}-${MY_PR} ;;
			qtdeclarative | qtsvg | qtscript | qtgraphicaleffects | qtwayland | qtquickcontrols* \
			| qtxmlpatterns | qtwebchannel | qtsensors ) MY_PF=qt5-${P}-${MY_PR} ;;
			gst-plugins* ) MY_PF=${P/-/reamer1-}-${MY_PR} ;;
			edk2-ovmf ) MY_PF=${P}git${GITCOMMIT}-${MY_PR} ;;
			ipxe ) MY_PF=${P}-${MY_PR}.${GIT_REV} ;;
			vte ) MY_PF=${P/-/291-}-${MY_PR} ;;
			rhel-kernel ) MY_P=${P/rhel-}; MY_PF=${MY_P}-${MY_PR}; MY_KVP=${PVR/r}.${DIST} ;;
			*) MY_PF=${P}-${MY_PR} ;;
		esac
	fi
	SRC_URI="${REPO_URI}/${MY_PF}.${DIST}.src.rpm"
fi

fi
