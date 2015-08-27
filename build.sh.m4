#!/bin/bash
../bin/pharo build.image config _CONFIG_REPO_ _CONFIG_NAME_ --username=_CONFIG_USER_ --password=_CONFIG_PASS_ --install=_CONFIG_VERSION_
../bin/pharo build.image save _IMAGE_NAME_
