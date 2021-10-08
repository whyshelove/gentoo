# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Merge this to pull in all Plasma 5 packages on rhel8"
HOMEPAGE="https://kde.org/plasma-desktop/"

LICENSE="metapackage"
SLOT="5"
KEYWORDS="amd64 ~arm arm64 ~ppc64 x86"
IUSE="+display-manager +sddm elogind systemd"
RDEPEND="
	kde-plasma/plasma-desktop
	kde-plasma/systemsettings
	kde-plasma/powerdevil
	kde-plasma/kwallet-pam
	kde-plasma/kscreen
	kde-apps/ark
	kde-apps/konsole
	kde-apps/kwrite
	kde-apps/dolphin
	kde-apps/kfind
	kde-apps/gwenview
	kde-plasma/plasma-nm
	kde-plasma/kinfocenter
	kde-plasma/plasma-systemmonitor
	kde-plasma/plasma-pa
	display-manager? (
		sddm? (
			x11-misc/sddm[elogind?,systemd?]
		)
		!sddm? ( x11-misc/lightdm )
	)
"
pkg_postinst() {
	systemctl --user enable pulseaudio.service
	use sddm && systemctl enable sddm && usermod -a -G video sddm \
		sed -i 's/^DISPLAYMANAGER=.*/DISPLAYMANAGER="sddm"/' /etc/conf.d/display-manager

	ewarn "An existing installation of sys-auth/consolekit was detected even though"
	ewarn "${PN} was configured with USE $(usex elogind elogind systemd)."
	ewarn "There can only be one session manager at runtime, otherwise random issues"
	ewarn "may occur. Please make sure USE consolekit is nowhere enabled in make.conf"
	ewarn "or package.use and remove sys-auth/consolekit before raising bugs."
	ewarn "For more information, visit https://wiki.gentoo.org/wiki/KDE"
}
