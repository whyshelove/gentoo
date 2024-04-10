# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

subrelease="$(ver_cut 7).1"
DPREFIX="${subrelease}."
DSUFFIX="_$(ver_cut 5)"

inherit rhel-kernel-build

DESCRIPTION="kernel - The Linux kernel, based on version 4.18.0, heavily modified with backports"
HOMEPAGE="https://www.kernel.org/"

LICENSE="GPL-2"
KEYWORDS="amd64 ~arm64 ~s390 ~ppc64"
IUSE="test debug +signkernel +signmodules zfcpdump +modules +up gcov realtime +zipmodules ipaclones +vdso perf tools bpf"
REQUIRED_USE="debug? ( !gcov !up !vdso !ipaclones !perf )
	    signkernel? ( ^^ ( amd64 arm64 ) )
            zipmodules? ( modules )
            signmodules? ( modules )
            zfcpdump? ( !signkernel !modules )
            realtime? ( !zfcpdump !ipaclones !perf !bpf )
            s390? ( !zfcpdump )
"
RDEPEND=""
BDEPEND="
	debug? ( dev-util/pahole )"

QA_FLAGS_IGNORED="usr/src/linux-.*/scripts/gcc-plugins/.*.so"

src_prepare() {
	default
	eapply_user
}
