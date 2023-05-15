#!/bin/bash
script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)

vm_version=11.0
vm_home=~/pharo/lib/$vm_version

if [ -d $vm_home ]
then

    read -r -p $'You are about to re-install the Pharo $vm_version runtime to $vm_home.\nThis will delete any existing files in that directory.\nContinue? [y/N] ' response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        echo Cancelled.
	exit 1
    fi

    # Remove directory recursively
    rm -rfv $vm_home
fi

echo "Downloading and installing Pharo $vm_version runtime"
# Ensure directory exists
mkdir -p $vm_home
cd $vm_home

zeroconf_url=https://get.pharo.org/64/${vm_version/\./}+vm
curl $zeroconf_url | bash

# Remove script to run interactive / headful mode (unused)
rm $vm_home/pharo-ui

mkdir -p ~/pharo/build

echo "Successfully installed the following Pharo runtime:"
$vm_home/pharo $vm_home/Pharo.image printVersion

if [ ! -e /etc/systemd/system/unit-status-alert@.service ]
then
	echo "Copying systemd unit status alert service"
	sudo cp unit-status-alert@.service /etc/systemd/system/
	sudo systemctl daemon-reload
fi
