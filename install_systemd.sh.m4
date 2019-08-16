#!/bin/bash

sudo cp systemd.service.script /etc/systemd/system/_SERVICE_NAME_.service
sudo systemctl daemon-reload
sudo systemctl enable _SERVICE_NAME_