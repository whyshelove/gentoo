#!/usr/bin/sh

for _dir in "$@"; do

	if [[ -d "/var/db/repos/gentoo/${_dir}" ]]; then

		pushd /var/db/repos/gentoo/"${_dir}"

			sed -i "/src.rpm/d" /var/db/repos/gentoo/"${_dir}"/Manifest
			sed -i "/<<<<<<</d" /var/db/repos/gentoo/"${_dir}"/Manifest
			sed -i "/>>>>>>>/d" /var/db/repos/gentoo/"${_dir}"/Manifest
			sed -i "/=======/d" /var/db/repos/gentoo/"${_dir}"/Manifest

			pkgdev manifest

			x=$?

		        if [[ $x != 0 ]]; then
		            break
		        fi
		popd
	fi
done
