# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rhel8.eclass
# @MAINTAINER:
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: backports packages Red Hat Enterprise Linux 8 Series RPMs

if [[ -z ${_RHEL8_ECLASS} ]] ; then
_RHEL8_ECLASS=1

	if [ -z ${MY_PF} ] ; then
		MY_PR=${PVR##*r}

		S="${WORKDIR}/${P/_p*}"

		case ${PN} in
			tiff | db | appstream-glib ) MY_P=lib${P} ;;
			docbook-xsl*) MY_P=docbook-style-xsl-${PV} ;;
			thin-provisioning-tools ) MY_P=device-mapper-persistent-data-${PV} ;;
			multipath-tools ) MY_P=device-mapper-multipath-${PV} ;;
			iproute2 ) MY_P=${P/2} ;;
			lxml ) MY_P=python-${P} ;;
			ninja) MY_P=${P/-/-build-} ;;
			shadow ) MY_P=${P/-/-utils-} ;;
			binutils-libs ) MY_P=${P/-libs} ;;
			webkit-gtk ) MY_P=${P/-gtk/2gtk3} ;;
			libpcre* ) MY_P=${P/lib}; S="${WORKDIR}/${MY_P/_p*}" ;;
			libnsl ) MY_P=${P/-/2-} ;;
			xorg-proto ) MY_P=${PN/-/-x11-}-devel-${PV} ;;
			xorg-server ) MY_P=${P/-/-x11-} ;;
			gtk+ ) MY_P=${P/+/$(ver_cut 1)} ;;
			xz-utils ) MY_P="${P/-utils}"; S="${WORKDIR}/${MY_P/_p*}" ;;
			udisks | gnupg | grub | lcms | glib | enchant | gstreamer \
			| gtksourceview ) MY_P=${P/-/$(ver_cut 1)-} ;;
			mpc | talloc | tdb | tevent | ldb ) MY_P=lib${P} ;;
			go ) MY_P=${P/-/lang-} ;;
			cunit ) MY_P=${P^^[cu]} ;;
			libusb ) MY_P=${P/-/x-} ;;
			gtk-doc-am ) MY_P=${P/-am}; S="${WORKDIR}/${MY_P/_p*}" ;;
			e2fsprogs-libs ) MY_P=${P/-libs} ;;
			openssh ) MY_P=${P/_} ;;
			procps ) MY_P=${P/-/-ng-}; MY_P=${MY_P} ;;
			gst-plugins* ) MY_P=${P/-/reamer1-} ;;
			modemmanager ) MY_P=${P/modemmanager/ModemManager} ;;
			sgabios | edk2-ovmf ) MY_P=${P/_p*}git${GIT_COMMIT} ;;
			vte ) MY_P=${P/-/291-} ;;
			linux-headers ) MY_P=${P/linux/kernel} ;;
			rhel-kernel ) MY_PN=${PN/rhel-}; MY_P=${P/rhel-} ;;
			shim-unsigned ) MY_P=${PN}-x64-${PV}; S=${WORKDIR}/${P/-unsigned} ;;
			*) MY_P=${P} ;;
		esac

		MY_P=${MY_P/_p*}

		case ${PN} in
			libyaml ) S="${WORKDIR}/${MY_P/lib}" ;;
			nspr ) S="${WORKDIR}/${MY_P/.0}" ;;
			nss ) S="${WORKDIR}/${MY_P/.0}/${PN}" ;;
			mit-krb5 ) MY_P=${MY_P/mit-}; S="${WORKDIR}/${MY_P}/src" ;;
			python ) MY_PV=${PV%_p*}; S="${WORKDIR}/${MY_P^^[p]}"; MY_P=${MY_P/-/3$(ver_cut 2)-} ;;
			*)  ;;
		esac

		DISTNUM=${BASH_SOURCE:0-8:1}

		inherit rpmbuild
	fi

fi
