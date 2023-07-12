# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="A user for app-admin/aerospike-amc-community"

ACCT_USER_GROUPS=( "aerospike-amc" )
ACCT_USER_ID="210"

acct-user_add_deps
