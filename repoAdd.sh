#!/usr/bin/sh
echo $1
pushd /var/db/repos/gentoo/$1
repoman manifest
popd
