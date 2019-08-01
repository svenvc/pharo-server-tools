#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
echo "Running from $script_home"

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

$vm $image eval --save "NonInteractiveTranscript stdout install. Metacello new repository: 'github://svenvc/NeoConsole/src'; baseline: 'NeoConsole'; load. Metacello new repository: '_CONFIG_REPO_'; baseline: '_CONFIG_BASELINE_'; onWarningLog; onConflictUseLoaded; load: '_CONFIG_GROUP_'."

echo
