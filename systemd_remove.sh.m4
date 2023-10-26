#!/bin/bash

sudo systemctl disable _SERVICE_NAME_
sudo rm /etc/systemd/system/_SERVICE_NAME_.service
sudo systemctl daemon-reload
