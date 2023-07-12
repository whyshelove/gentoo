# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="User for upmpdcli"
ACCT_USER_ID=372
ACCT_USER_GROUPS=( upmpdcli )

acct-user_add_deps
