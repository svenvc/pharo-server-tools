#!/bin/bash

# Default Alert Healthcheck ID
hcid=0e6d6383-40db-48fc-b49d-e51957ca2cc3

# Ping Healthchecks.io with failure, using first argument as payload
curl -fsS --retry 3 --data-raw "$1" -o /dev/null "https://hc-ping.com/${hcid}/fail"
