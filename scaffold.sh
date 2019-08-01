#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
echo "Running from $script_home"

vm=~/pharo/bin/pharo
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
CONFIG_BASELINE=$CONFIG_BASELINE
read -p "Metacello group (empty for 'default'): " CONFIG_GROUP
if [ "$CONFIG_GROUPS" = '' ];
then
    CONFIG_GROUPS=default
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

mkdir -p $service_home

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
    -D_TELNET_PORT_=$TELNET_PORT \
    -D_METRICS_PORT_=$METRICS_PORT \
    $1 \
    > $2
}


echo Creating custom build script

process_template $script_home/build.sh.m4 $build_home/build-$IMAGE_NAME.sh

chmod +x $build_home/build-$IMAGE_NAME.sh

$build_home/build-$IMAGE_NAME.sh

mv $build_home/build-$IMAGE_NAME.changes $service_home/$IMAGE_NAME.changes
mv $build_home/build-$IMAGE_NAME.image $service_home/$IMAGE_NAME.image
cp $build_home/*.sources $service_home
mv $build_home/pharo-local $service_home/

cp $script_home/pharo-ctl.sh $service_home

echo Creating custom run/startup script
process_template $script_home/run.st.m4 $service_home/run-$SERVICE_NAME.st


echo Creating custom REPL script
process_template $script_home/repl.sh.m4 $service_home/repl.sh
chmod +x $service_home/repl.sh


echo Creating custom init.d script
process_template $script_home/init.d.m4 $service_home/init.d.script
chmod +x $service_home/init.d.script


echo Creating custom systemd.service script
process_template $script_home/systemd.service.m4 $service_home/systemd.service.script

echo Creating custom monit services
process_template $script_home/monit-service-init.d.m4 $service_home/monit-service-init.d
process_template $script_home/monit-service-systemd.m4 $service_home/monit-service-systemd

echo Done

echo To install the init.d script do
echo sudo cp $service_home/init.d.script /etc/init.d/$SERVICE_NAME
echo sudo update-rc.d $SERVICE_NAME defaults
echo To install the monit service check for init.d do
echo sudo cp $service_home/monit-service-init.d /etc/monit/conf.d/$SERVICE_NAME
echo ""
echo To install the systemd.service script do
echo sudo cp $service_home/systemd.service.script /etc/systemd/system/$SERVICE_NAME.service
echo sudo systemctl daemon-reload
echo sudo systemctl enable $SERVICE_NAME
echo To install the monit service check for systemd do
echo sudo cp $service_home/monit-service-systemd /etc/monit/conf.d/$SERVICE_NAME
