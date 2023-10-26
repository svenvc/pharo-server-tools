#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
echo "Running from $script_home"

sudo cp $script_home/systemd.service.script /etc/systemd/system/_SERVICE_NAME_.service
sudo systemctl daemon-reload
sudo systemctl enable _SERVICE_NAME_
