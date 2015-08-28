#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
vm=$script_home/../bin/pharo
image=$script_home/build.image

if [ -d $build_home ];
then
    echo This script will build a $_IMAGE_NAME_ image
else
    $vm $script_home/Pharo.image save build
    echo This script will build a $_IMAGE_NAME_ image    
fi

$vm $image config _CONFIG_REPO_ _CONFIG_NAME_ --username=_CONFIG_USER_ --password=_CONFIG_PASS_ --install=_CONFIG_VERSION_
$vm $image save _IMAGE_NAME_
