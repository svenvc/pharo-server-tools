#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
echo "Running from $script_home"

vm=$script_home/../bin/pharo

project=_SERVICE_NAME_

# Define build directory using date/time and create
builddir=$script_home/$project-$(date +%Y%m%d%H%M)
mkdir -pv $builddir

# Save copy of Pharo base image to build directory
$vm $script_home/Pharo.image save $builddir/$project

# If needed, start SSH agent and add private key(s) for git authentication
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(/usr/bin/ssh-agent)
    agent_started_by_me=true
    /usr/bin/ssh-add
fi

# Print out Smalltalk script to run the build
cat << EOF > $builddir/run-build.st
"Disable Epicea monitor during loading of baseline(s)"
EpMonitor current disable.
Metacello new
    repository: 'github://objectguild/NeoConsole:master';
    baseline: 'NeoConsole';
    load.

"Hotfix to log git repository if we get a not found/authorized error."
IceLibgitErrorVisitor compile: 'visitEEOF: aLGit_GIT_EEOF
        aLGit_GIT_EEOF messageText trimmed = ''ERROR: Repository not found.''
                ifTrue: [ IceCloneRemoteNotFound signalFor: context url ].
        Transcript show: 'Error context repository: ' , context url asString; cr.
        ^ self visitGenericError: aLGit_GIT_EEOF'.

Metacello new
    repository: '_CONFIG_REPO_';
    baseline: '_CONFIG_BASELINE_';
    onWarningLog;
    onConflictUseLoaded;
    load: #( "Intentional new line to allow replacement with M4"
        '_CONFIG_GROUP_' 
    ).

"Clean image and prepare for running headless."
Smalltalk cleanUp: true except: {} confirming: false.
World closeAllWindowsDiscardingChanges.
Deprecation
    raiseWarning: false;
    showWarning: false.

"CAUTION - Enable to run without sources and changes files:
NoChangesLog install.
NoPharoFilesOpener install.
FFICompilerPlugin install."

"CAUTION - Remove tests and examples packages:
RPackageOrganizer default packages
    select: [ :p | #('Test' 'Example' 'Mock' 'Demo') anySatisfy: [ :aString | p name includesSubstring: aString ] ]
    thenDo: #removeFromSystem."

EpMonitor reset.
5 timesRepeat: [ Smalltalk garbageCollect ].

WorldState serverMode: true.

Transcript cr; show: 'Build finished'; cr.
EOF

# Copy required Pharo sources to build directory
cp Pharo*.sources $builddir/

# Actually run the build, saving and exiting the image, while redirecting output to a build log file
cd $builddir
$vm $project.image st --save --quit $builddir/run-build.st > $builddir/build.log 2>&1
cd $script_home

# Kill SSH agent if started earlier
if [ "$agent_started_by_me" = "true" ]; then
    eval $(/usr/bin/ssh-agent -k)
fi

# Print out a deploy script to copy the build result to the deployment directory
cat << EOF > $builddir/deploy.sh
#!/bin/bash

script_home=\$(dirname \$0)
script_home=\$(cd \$script_home && pwd)
echo "Running from \$script_home"

project=$project
deploydir=~/pharo/\$project

continue=true
if [ -d \$deploydir/pharo-local ] || [ -e \$deploydir/\$project.image ] || [ -e \$deploydir/\$project.changes ]
then

    read -r -p $"You are about to deploy this build to \$deploydir.
This will move any existing .image and .changes files and pharo-local/ directory to a backup location.
Continue? [y/N] " response
    if [[ ! "\$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        continue=false
        echo Cancelled.
    fi
fi

if [ "\$continue" = "true" ]
then

    backupdir=\$deploydir/_archive/backup_\$(date +%Y%m%d%H%M)
    echo Creating backup directory: \$backupdir
    mkdir -p \$backupdir

    if [ -d \$deploydir/pharo-local ]
    then

        echo Backing up pharo-local/ directory
        mv -v \$deploydir/pharo-local \$backupdir/
    fi

    echo Copying new pharo-local/ directory
    cp -r pharo-local \$deploydir/

    if [ -e \$deploydir/\$project.image ] || [ -e \$deploydir/\$project.changes ]
    then

        echo Backing up .image and .changes files
        mv -v \$deploydir/\$project.image \$backupdir/
        mv -v \$deploydir/\$project.changes \$backupdir/
    fi

    echo Copying new .image and .changes files
    cp -v \$script_home/\$project.image \$deploydir/
    cp -v \$script_home/\$project.changes \$deploydir/

    echo Done.
fi
EOF

# Make the deploy script executable
chmod +x $builddir/deploy.sh
