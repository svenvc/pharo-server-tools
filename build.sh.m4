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

# Start SSH agent and add private key(s) for git authentication
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(/usr/bin/ssh-agent)
fi
/usr/bin/ssh-add

$vm $image eval --save "Metacello new repository: 'github://objectguild/NeoConsole:master'; baseline: 'NeoConsole'; load. ((Smalltalk at: #NeoConsoleTranscript) onFileNamed: 'build-{1}.log') install. Metacello new repository: '_CONFIG_REPO_'; baseline: '_CONFIG_BASELINE_'; onWarningLog; onConflictUseLoaded; load: '_CONFIG_GROUP_'. (Smalltalk at: #NeoConsoleTranscript) shutDown."

