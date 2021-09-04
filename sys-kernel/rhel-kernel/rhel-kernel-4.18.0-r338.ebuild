# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rhel-kernel-build

DESCRIPTION="Linux kernel built with Gentoo patches"
HOMEPAGE="https://www.kernel.org/"

LICENSE="GPL-2"
KEYWORDS="amd64 ~arm arm64 ~ppc64 x86"
IUSE="test debug hardened signkernel signmodules zfcpdump +modules +up gcov realtime +zipmodules ipaclones vdso perf tools bpf"
REQUIRED_USE="debug? ( !gcov !up !vdso !ipaclones !perf )
	    signkernel? ( ^^ ( amd64 arm64 ) )
            zipmodules? ( modules )
            signmodules? ( modules )
            zfcpdump? ( !signkernel !modules )
            realtime? ( !zfcpdump !ipaclones !perf !bpf )
            s390? ( !zfcpdump )
"
RDEPEND="
	!sys-kernel/gentoo-kernel-bin:${SLOT}"
BDEPEND="
	debug? ( dev-util/pahole )"
PDEPEND="
	>=virtual/dist-kernel-${PV}"

QA_FLAGS_IGNORED="usr/src/linux-.*/scripts/gcc-plugins/.*.so"

src_prepare() {
	default
	eapply_user
}
