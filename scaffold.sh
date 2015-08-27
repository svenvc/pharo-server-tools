#!/bin/bash

if [ -d "~/pharo/build" ]
then
    echo This script will setup a new Pharo service
else
    echo Please run install-pharo.sh first
    exit
fi

read -p "Service name: " SERVICE_NAME
read -p "Image name (empty for service name): " IMAGE_NAME
if ["$IMAGE_NAME" = ''];
then
    IMAGE_NAME=$SERVICE_NAME
fi
read -p "User (empty for current user): " SERVICE_USER
if ["$SERVICE_USER" = ''];
then
    $SERVICE_USER=$USER
fi
read -p "Description: " DESCRIPTION
read -p "Metacello repository: " CONFIG_REPO
read -p "Metacello name: " CONFIG_NAME
read -p "Metacello user: " CONFIG_USER
read -p "Metacello password: " CONFIG_PASS
read -p "Metacello version (empty for stable): " CONFIG_VERSION
if ["$CONFIG_VERSION" = ''];
then
    $CONFIG_VERSION=stable
fi
read -p "Telnet port (empty for 42001): " TELNET_PORT
if ["$TELNET_PORT" = ''];
then
    TELNET_PORT=42001
fi
read -p "Metrics port (empty for 42002): " METRICS_PORT
if ["$METRICS_PORT" = ''];
then
    METRICS_PORT=42002
fi

mkdir ~/pharo/$SERVICE_NAME

echo Creating custom build script

m4 \
    -D_SERVICE_NAME_=$SERVICE_NAME \
    -D_IMAGE_NAME_=$IMAGE_NAME \
    -D_SERVICE_USER_=$SERVICE_USER \
    -D_DESCRIPTION_=$DESCRIPTION \
    -D_CONFIG_REPO_=$CONFIG_REPO \
    -D_CONFIG_NAME_=$CONFIG_NAME \
    -D_CONFIG_USER_=$CONFIG_USER \
    -D_CONFIG_PASS_=$CONFIG_PASS \
    -D_CONFIG_VERSION_=$CONFIG_VERSION \
    -D_TELNET_PORT_=$TELNET_PORT \
    -D_METRICS_PORT_=$METRICS_PORT \
    monit-service-check.m4 \
    > ~/pharo/build/build-$SERVICE_NAME.sh

chmod +x ~/pharo/build/build-$SERVICE_NAME.sh

~/pharo/build/build-$SERVICE_NAME.sh

mv ~/pharo/build/IMAGE_NAME.* ~/pharo/$SERVICE_NAME/

cp pharo-ctl.sh ~/pharo/$SERVICE_NAME

echo Creating custom run/startup script

m4 \
    -D_SERVICE_NAME_=$SERVICE_NAME \
    -D_IMAGE_NAME_=$IMAGE_NAME \
    -D_SERVICE_USER_=$SERVICE_USER \
    -D_DESCRIPTION_=$DESCRIPTION \
    -D_CONFIG_REPO_=$CONFIG_REPO \
    -D_CONFIG_NAME_=$CONFIG_NAME \
    -D_CONFIG_USER_=$CONFIG_USER \
    -D_CONFIG_PASS_=$CONFIG_PASS \
    -D_CONFIG_VERSION_=$CONFIG_VERSION \
    -D_TELNET_PORT_=$TELNET_PORT \
    -D_METRICS_PORT_=$METRICS_PORT \
    run.st.m4 \
    > ~/pharo/$SERVICE_NAME/run-$SERVICE_NAME.sh

echo Creating custom init.d script

m4 \
    -D_SERVICE_NAME_=$SERVICE_NAME \
    -D_IMAGE_NAME_=$IMAGE_NAME \
    -D_SERVICE_USER_=$SERVICE_USER \
    -D_DESCRIPTION_=$DESCRIPTION \
    -D_CONFIG_REPO_=$CONFIG_REPO \
    -D_CONFIG_NAME_=$CONFIG_NAME \
    -D_CONFIG_USER_=$CONFIG_USER \
    -D_CONFIG_PASS_=$CONFIG_PASS \
    -D_CONFIG_VERSION_=$CONFIG_VERSION \
    -D_TELNET_PORT_=$TELNET_PORT \
    -D_METRICS_PORT_=$METRICS_PORT \
    init.d.m4 \
    > ~/pharo/$SERVICE_NAME/init.d.script

echo Creating custom monit service check

m4 \
    -D_SERVICE_NAME_=$SERVICE_NAME \
    -D_IMAGE_NAME_=$IMAGE_NAME \
    -D_SERVICE_USER_=$SERVICE_USER \
    -D_DESCRIPTION_=$DESCRIPTION \
    -D_CONFIG_REPO_=$CONFIG_REPO \
    -D_CONFIG_NAME_=$CONFIG_NAME \
    -D_CONFIG_USER_=$CONFIG_USER \
    -D_CONFIG_PASS_=$CONFIG_PASS \
    -D_CONFIG_VERSION_=$CONFIG_VERSION \
    -D_TELNET_PORT_=$TELNET_PORT \
    -D_METRICS_PORT_=$METRICS_PORT \
    monit-service-check.m4 \
    > ~/pharo/$SERVICE_NAME/monit-service-check

echo Done
