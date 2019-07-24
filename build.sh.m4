#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
vm=$script_home/../bin/pharo
image=$script_home/build-_IMAGE_NAME_.image

if [ -f $image ];
then
    echo This script will build a _IMAGE_NAME_ image
else
    $vm $script_home/Pharo.image save build-_IMAGE_NAME_
    echo This script will build a _IMAGE_NAME_ image    
fi

# Start SSH agent and add private key for git authentication
eval $(/usr/bin/ssh-agent)
/usr/bin/ssh-add ~/.ssh/id_ed25519

# Uncomment if you want to load NeoConsole during build
#$vm $image eval --save "Metacello new repository: 'github://svenvc/NeoConsole:master'; baseline: 'NeoConsole'; load."

# Change transcript to write to stdout, so we can spot Git authentication issues.
$vm $image eval --save "NonInteractiveTranscript stdout install. Metacello new repository: '_CONFIG_REPO_'; baseline: '_CONFIG_BASELINE_'; onWarningLog; onConflictUseLoaded; load: '_CONFIG_GROUP_'."

echo
