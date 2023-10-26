[Unit]
Description=_DESCRIPTION_
# Limit unit start, if started more than 5 times within 120 seconds
StartLimitIntervalSec=120
StartLimitBurst=5
OnFailure=unit-status-alert@%n.service
After=network.target

[Service]
Type=forking
User=_SERVICE_USER_
WorkingDirectory=/home/_SERVICE_USER_/pharo/_SERVICE_NAME_
ExecStart=/home/_SERVICE_USER_/pharo/_SERVICE_NAME_/pharo-ctl.sh run-_SERVICE_NAME_ start _IMAGE_NAME_
ExecStop=/home/_SERVICE_USER_/pharo/_SERVICE_NAME_/pharo-ctl.sh run-_SERVICE_NAME_ stop _IMAGE_NAME_
PIDFile=/home/_SERVICE_USER_/pharo/_SERVICE_NAME_/run-_SERVICE_NAME_.pid
LimitRTPRIO=2:2
TimeoutSec=3
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
