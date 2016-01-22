#!/bin/bash

while getopts "c:d:v:" OPTION
do
	case ${OPTION} in
		c) CLOUD_CONFIG="${OPTARG}" ;;
		d) DEVICE="${OPTARG}" ;;
		v) VERSION="${OPTARG}" ;;
		*) 2>&1 echo "Usage: ${0} [-c cloud-config.yml] [-d /dev/sdX] [-v 0.X.Y]" && exit 1 ;;
	esac
done

if [ -z "${DEVICE}" ]
then
	if [ -e "/dev/sda" ]
	then
		DEVICE="/dev/sda"
	elif [ -e "/dev/vda" ]
	then
		DEVICE="/dev/vda"
	else
		2>&1 echo "Error: could not automatically determine device to install to, use -d to specify"
		exit 1
	fi
fi

if [ -z "${CLOUD_CONFIG}" ]
then
	CLOUD_CONFIG="/tmp/cloud-config.yml"
	cat > "${CLOUD_CONFIG}" <<- EOF
		#cloud-config
		EOF
fi

set -x

if which apt-get > /dev/null
then
	export DEBIAN_FRONTEND=noninteractive
	apt-get -qq update
	apt-get -qq install --no-install-recommends ca-certificates git grub2
fi

if [ -z "${VERSION}" ]
then
	VERSION=$(wget -q -O - https://releases.rancher.com/os/releases.yml | grep current | cut -d: -f3)
else
	VERSION=$(echo "${VERSION}" | sed 's/^v*/v/')
fi

git clone --branch "${VERSION}" https://github.com/rancher/os.git rancheros
ln -fs ../../build.conf rancheros/scripts/installer/build.conf
ln -fs `pwd`/rancheros/scripts/installer /scripts
mkdir dist
wget -q -P dist "https://github.com/rancher/os/releases/download/${VERSION}/initrd"
wget -q -P dist "https://github.com/rancher/os/releases/download/${VERSION}/vmlinuz"

rancheros/scripts/installer/set-disk-partitions "${DEVICE}"
rancheros/scripts/installer/lay-down-os -c "${CLOUD_CONFIG}" -d "${DEVICE}" -i dist -t generic
