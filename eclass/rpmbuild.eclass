# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2`

# @ECLASS: rhel.eclass
# @MAINTAINER:
# base-system@gentoo.org
# @SUPPORTED_EAPIS: 5 6 7 8
# @BLURB: convenience class for extracting Red Hat Enterprise Linux Series RPMs

if [[ -z ${_RPMBUILD_ECLASS} ]] ; then
_RPMBUILD_ECLASS=1
_RHEL_ECLASS=1

inherit macros rpm

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
		S="${WORKDIR}/${P/_p*}"
		case ${PN} in
			tiff | db | appstream-glib | mpc \
			| talloc | tdb | tevent | ldb )  MY_P=lib${P} ;;
			docbook-xsl-stylesheets )  MY_P=docbook5-style-xsl-${PV} ;;
			docbook-xsl-ns-stylesheets )  MY_P=docbook-style-xsl-${PV} ;;
			ghostscript-gpl )  MY_P=${P/-gpl} ;;
			wayland-scanner )  MY_P=${P/-scanner} ;;
			lm-sensors )  MY_P=${P/-/_} ;;
			libsdl* ) MY_PT=${P/lib};  MY_P=${MY_PT^^} ;;
			gdk-pixbuf )  MY_P=${P/pixbuf/pixbuf2} ;;
			xauth | xbitmaps | util-macros | xinit )  MY_P=xorg-x11-${P} ;;
			libnl | glib | openjpeg | lcms | gnupg | grub | udisks | geoclue \
			| udisks | lcms | openjpeg | glib | librsvg | gstreamer | gtksourceview \
			| gtk | gdk-pixbuf | librsvg ) MY_P=${P/-/$(ver_cut 1)-} ;;
			libusb )  MY_P=${P/-/x-} ;;
			sysprof-capture )  MY_P=${P/-capture};S="${WORKDIR}/${MY_P}" ;;
			e2fsprogs-libs )  MY_P=${P/-libs} ;;
			procps ) MY_P=${P/-/-ng-} ;;
			thin-provisioning-tools )  MY_P=device-mapper-persistent-data-${PV} ;;
			iproute2 )  MY_P=${P/2} ;;
			mit-krb5 )  MY_P=${P/mit-} ;;
			ninja )  MY_P=${P/-/-build-} ;;
			openssl-compat ) MY_P=compat-openssl11-${PV} ;;
			openssh )  MY_P=${P/_} ;;
			shadow )  MY_P=${P/-/-utils-} ;;
			cups )  MY_P=${P/_p*}op2 ;;
			binutils-libs )  MY_PN="binutils"; MY_P=${P/-libs} ;;
			webkit-gtk )  MY_P=${P/-gtk/2gtk3} ;;
			libnsl ) MY_P=${P/-/2-} ;;
			libpcre* ) MY_P=${P/lib} ;;
			xorg-proto )  MY_P=${PN/-/-x11-}-devel-${PV} ;;
			xtrans )  MY_P=xorg-x11-${PN}-devel-${PV} ;;
			gtk+ ) MY_P=${P/+/$(ver_cut 1)} ;;
			xz-utils ) MY_P="${PN/-utils}-${PV/_}" ;;
			glib-utils ) MY_P=${P/-utils}; S=${WORKDIR}/${MY_P}; MY_P="${MY_P/-/2-}" ;;	
			nspr ) MY_P=nss-${NSS_VER}; S="${WORKDIR}/${MY_P/.0}";;
			qtgui | qtcore | qtwidgets | qtdbus | qtnetwork | qttest | qtxml \
			| linguist-tools | qtsql | qtconcurrent | qdbus | qtpaths \
			| qtprintsupport | designer ) MY_P="qt5-${QT5_MODULE}-${PV}" ;;
			qtdeclarative | qtsvg | qtscript | qtgraphicaleffects | qtwayland | qtquickcontrols* \
			| qtxmlpatterns | qtwebchannel | qtx11extras )  MY_P=qt5-${P} ;;
			gst-plugins* )  MY_P=${P/-/reamer1-} ;;
			edk2-ovmf )  MY_P=${P}git${GITCOMMIT} ;;
			ipxe )  MY_P=${P}.${GIT_REV} ;;
			vte )  MY_P=${P/-/291-} ;;
			linux-headers ) MY_P=${P/linux/kernel} ;;
			rhel-kernel ) MY_PN=${PN/rhel-}; MY_P=${P/rhel-} ;;
			modemmanager )  MY_P=${P/modemmanager/ModemManager} ;;
			networkmanager )  MY_P=${P/networkmanager/NetworkManager} ;;
			vte )  MY_P=${P/-/291-} ;;
			libltdl )  MY_P=libtool-${PV} ;;
			shim-unsigned ) MY_P=${PN}-x64-${PV}; S=${WORKDIR}/${P/-unsigned} ;;
			autoconf ) MY_P=${P}; [[ ${PV} == 2.71 ]] && MY_P="${PN}-latest-${PV}" ;;
			*) MY_P=${P} ;;
		esac
	fi

		MY_P=${MY_P/_p*}

		case ${PN} in
			asciidoc ) S="${WORKDIR}/${P/-/-py-}" ;;
			libyaml ) S="${WORKDIR}/${MY_P/lib}" ;;
			nss ) S="${WORKDIR}/${MY_P/.0}/${PN}" ;;
			mit-krb5 ) MY_P=${MY_P/mit-}; S="${WORKDIR}/${MY_P}/src" ;;
			python ) MY_PV=${PV%_p*}; S="${WORKDIR}/${MY_P^^[p]}"; MY_P=${MY_P/-/3.$(ver_cut 2)-} ;;
			*)  ;;
		esac
fi

rpm_clean() {
	# delete everything
	rm -f *.patch
	local a
	for a in *.tar.{gz,bz2,xz} *.t{gz,bz2,xz,pxz} *.zip *.ZIP ; do
		rm -f "${a}"
	done
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
	ln -s $WORKDIR/${EGIT_CHECKOUT_DIR} $RPMBUILD/SOURCES
	ln -s $WORKDIR $RPMBUILD/BUILD
}

# @FUNCTION: rpmbuild_prep
# @DESCRIPTION:
# build through %prep (unpack sources and apply patches) from <specfile>
rpmbuild_prep() {
#	FIND_FILE="${WORKDIR}/*.spec"
#	FIND_STR="pypi_source"
#	if [ `grep -c "$FIND_STR" $FIND_FILE` -ne '0' ] ;then
#		echo -e "The spec File Has\c"
#		echo -e "\033[33m $FIND_STR \033[0m\c"
#		echo "Skipp rpm build through %prep..."
#		unpack ${WORKDIR}/*.tar.*
#		return 0
#	fi

	#sed -i -e "/#!%{__python3}/d" \
	#	${WORKDIR}/*.spec
	
	if [[ ${unused_patches} ]]; then
		local p

		for p in "${unused_patches[@]}"; do
			sed -i "/${p}/d" ${WORKDIR}/${EGIT_CHECKOUT_DIR}/*.spec || die
		done
	fi

	if [[ ${STAGE} != "unprep" ]]; then
		rpmbuild -bp $WORKDIR/${EGIT_CHECKOUT_DIR}/*.spec --nodeps
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

rhel_src_unpack() {
	rpmbuild_src_unpack
}

# @FUNCTION: rpmbuild_src_unpack
# @DESCRIPTION:
# Automatically unpack all archives in ${A} including rpms.  If one of the
# archives in a source rpm, then the sub archives will be unpacked as well.
rpmbuild_src_unpack() {
	if [[ ${PVR} == *9999 ]] || [[ -n ${_CS_ECLASS} ]]; then
		git-r3_src_unpack
		rpmbuild_env_setup
		ln -s $DISTDIR/${MY_PN:-${PN}}* $WORKDIR/${EGIT_CHECKOUT_DIR}/ 
		rpmdev-spectool -l -R ${WORKDIR}/${EGIT_CHECKOUT_DIR}/*.spec
		rpmbuild_prep
		return
	fi

	local a
	for a in ${A} ; do
		case ${a} in
		*.src.rpm) [[ ${a} =~ ".src.rpm" ]] && srcrpmbuild_unpack "${a}" ;;
		*.rpm) [[ ${a} =~ ".rpm" ]] && rpm_unpack "${a}" && mkdir -p $S ;;
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
