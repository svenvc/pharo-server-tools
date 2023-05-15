#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
echo "Running from $script_home"

# Assume we're using Pharo 11.0 runtime
vm_home=~/pharo/lib/11.0
vm=$vm_home/pharo
build_home=~/pharo/build

if [ -d $build_home ];
then
    echo This script will setup a new Pharo service under ~/pharo
else
    echo Please run install-pharo.sh first
    exit
fi

read -p "Service name: " SERVICE_NAME
read -p "Image name (empty for service name): " IMAGE_NAME
if [ "$IMAGE_NAME" = '' ];
then
    IMAGE_NAME=$SERVICE_NAME
fi
read -p "User (empty for current user): " SERVICE_USER
if [ "$SERVICE_USER" = '' ];
then
    SERVICE_USER=$USER
fi
read -p "Description: " DESCRIPTION
read -p "Metacello repository: " CONFIG_REPO
read -p "Metacello baseline (excluding any 'BaselineOf' prefix): " CONFIG_BASELINE
read -p "Metacello group (empty for 'default'): " CONFIG_GROUP
if [ "$CONFIG_GROUP" = '' ];
then
    CONFIG_GROUP=default
fi
read -p "Host prefix (empty for service name): " HOST_PREFIX
if [ "$HOST_PREFIX" = '' ];
then
    HOST_PREFIX=$SERVICE_NAME
fi
read -p "HTTP proxy port (empty for 8080): " PROXY_PORT
if [ "$PROXY_PORT" = '' ];
then
    PROXY_PORT=8080
fi
read -p "Telnet port (empty for 42001): " TELNET_PORT
if [ "$TELNET_PORT" = '' ];
then
    TELNET_PORT=42001
fi
read -p "Metrics port (empty for 42002): " METRICS_PORT
if [ "$METRICS_PORT" = '' ];
then
    METRICS_PORT=42002
fi

service_home=~/pharo/$SERVICE_NAME

mkdir -pv $service_home

function process_template() {
    if [ "$#" -ne 2 ]; 
        then echo "This function expects two arguments, the input and output file";
        return;
    fi

    m4 \
    -D_SERVICE_NAME_=$SERVICE_NAME \
    -D_IMAGE_NAME_=$IMAGE_NAME \
    -D_SERVICE_USER_=$SERVICE_USER \
    -D_DESCRIPTION_="$DESCRIPTION" \
    -D_CONFIG_REPO_=$CONFIG_REPO \
    -D_CONFIG_BASELINE_=$CONFIG_BASELINE \
    -D_CONFIG_GROUP_=$CONFIG_GROUP \
    -D_HOST_PREFIX_=$HOST_PREFIX \
    -D_PROXY_PORT_=$PROXY_PORT \
    -D_TELNET_PORT_=$TELNET_PORT \
    -D_METRICS_PORT_=$METRICS_PORT \
    $1 \
    > $2
}


echo Creating custom build script
process_template $script_home/build-_SERVICE_NAME_.sh.m4 $build_home/build-$SERVICE_NAME.sh
chmod +x $build_home/build-$SERVICE_NAME.sh
process_template $script_home/build.sh.m4 $service_home/build.sh
chmod +x $service_home/build.sh

cp $vm_home/Pharo*.sources $service_home
cp $script_home/pharo-ctl.sh $service_home


echo Creating custom run/startup script
process_template $script_home/run.st.m4 $service_home/run-$SERVICE_NAME.st

echo Creating custom REPL script
process_template $script_home/repl.sh.m4 $service_home/repl.sh
chmod +x $service_home/repl.sh

echo Creating custom systemd.service script
process_template $script_home/systemd.service.m4 $service_home/systemd.service.script

echo Creating custom nginx site configuration
process_template $script_home/nginx-site.m4 $service_home/nginx-site

echo Creating custom monit services
process_template $script_home/monit-service-systemd.m4 $service_home/monit-service-systemd

echo Done

process_template $script_home/systemd_install.sh.m4 $service_home/systemd_install.sh
chmod +x $service_home/systemd_install.sh
process_template $script_home/systemd_remove.sh.m4 $service_home/systemd_remove.sh
chmod +x $service_home/systemd_remove.sh

echo To install $SERVICE_NAME as a systemd service, run $service_home/install_systemd.sh
echo ""
echo To install/enable the nginx site do
echo sudo ln -s $service_home/nginx-site /etc/nginx/sites-enable/$SERVICE_NAME
echo ""

if [ -z /etc/nginx/conf.d/proxy_websockets.conf ];
then
    echo Adding nginx proxy websockets configuration
    sudo cp $script_home/proxy_websockets.conf /etc/nginx/conf.d/
fi

echo To install the monit service check do
echo sudo cp $service_home/monit-service-systemd /etc/monit/conf.d/$SERVICE_NAME
