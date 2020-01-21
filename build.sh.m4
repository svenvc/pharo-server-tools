#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
echo "Running from $script_home"

vm=$script_home/../bin/pharo

builddir=$script_home/_SERVICE_NAME_-$(date +%Y%m%d%H%M)
mkdir -p $builddir

image=$builddir/_IMAGE_NAME_.image
$vm $script_home/Pharo.image save $builddir/_IMAGE_NAME_

# Start SSH agent and add private key(s) for git authentication
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(/usr/bin/ssh-agent)
fi
/usr/bin/ssh-add

cat << EOF > $builddir/run-build.st
Metacello new
    repository: 'github://svenvc/NeoConsole:master';
    baseline: 'NeoConsole';
    load.
Metacello new
    repository: '_CONFIG_REPO_';
    baseline: '_CONFIG_BASELINE_';
    onWarningLog;
    onConflictUseLoaded;
    load: '_CONFIG_GROUP_'.

"Clean image and prepare for running headless."
Smalltalk cleanUp: true except: {} confirming: false.
World closeAllWindowsDiscardingChanges.
Deprecation
    raiseWarning: false;
    showWarning: false.

"<Disabled> CAUTION - Enable to run without sources and changes files:
NoChangesLog install.
NoPharoFilesOpener install.
FFICompilerPlugin install.
</Disabled>"

"<Disabled> CAUTION - Remove tests and examples packages:
RPackageOrganizer default packages
    select: [ :p | #('Test' 'Example' 'Mock' 'Demo') anySatisfy: [ :aString | p name includesSubstring: aString ] ]
    thenDo: #removeFromSystem.
</Disabled>"

EpMonitor reset.
5 timesRepeat: [ Smalltalk garbageCollect ].

WorldState serverMode: true.
EOF

cp Pharo*.sources $builddir/

cd $builddir
$vm $image st --save --quit $builddir/run-build.st > $builddir/build.log 2>&1
cd $script_home

# Kill SSH agent started earlier
eval $(/usr/bin/ssh-agent -k)

cat << EOF > $builddir/deploy.sh
#!/bin/bash

deploydir=~/pharo/_SERVICE_NAME_

continue=true
if [ -d \$deploydir/pharo-local ] || [ -e \$deploydir/_IMAGE_NAME_.image ] || [ -e \$deploydir/_IMAGE_NAME_.changes ]
then

    read -r -p $'You are about to deploy this build to ~/pharo/_SERVICE_NAME_.\nThis will overwrite existing .image and .changes files and pharo-local/ directory.\nContinue? [y/N] ' response
    if [[ ! "\$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        continue=false
        echo Cancelled.
    fi
fi

if [ "\$continue" = "true" ]
then

    if [ -d \$deploydir/pharo-local ]
    then
        echo Removing ~/pharo/_SERVICE_NAME_/pharo-local/ directory
        rm -rf ~/pharo/_SERVICE_NAME_/pharo-local
    fi

    echo Copying pharo-local/ directory
    cp -r pharo-local ~/pharo/_SERVICE_NAME_/
    echo Copying .image and .changes files
    cp -bv _IMAGE_NAME_.* ~/pharo/_SERVICE_NAME_/

    echo Done.
fi
EOF
chmod +x $builddir/deploy.sh
