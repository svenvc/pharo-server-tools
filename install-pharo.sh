#!/bin/bash
script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)

# If needed, modify VM version here
vm_version_short=8

# Some magick to switch VM options by version
# See https://stackoverflow.com/a/18124325
vm_version="$vm_version_short.0"
vm_options_8="--vm-display-null"
vm_options_9="--headless"
vm_options_10="--headless"
vm_options_11="--headless"
vm_options_var=vm_options_$vm_version_short
vm_options=${!vm_options_var}

vm_home=$(/usr/bin/realpath $script_home/../pharo/lib/$vm_version)
vm=$vm_home/pharo-vm/pharo

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
$vm $vm_options $vm_home/Pharo.image printVersion

if [ ! -e /etc/systemd/system/unit-status-alert@.service ]
then
	echo "Copying systemd unit status alert service"
	sudo cp unit-status-alert@.service /etc/systemd/system/
	sudo systemctl daemon-reload
fi
