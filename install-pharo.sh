#!/bin/bash
script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)

if [ -d ~/pharo/bin ]
then

    read -r -p $'You are about to re-install the Pharo runtime to ~/pharo/bin.\nThis will delete any existing files in that directory.\nContinue? [y/N] ' response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        echo Cancelled.
	exit 1
    fi
fi

rm -rfv ~/pharo/bin

curl get.pharo.org/64/80+vm | bash
rm $script_home/pharo-ui

mkdir -p ~/pharo/build
mv $script_home/Pharo*.sources ~/pharo/build
mv $script_home/Pharo.changes ~/pharo/build
mv $script_home/Pharo.image ~/pharo/build

mkdir -p ~/pharo/bin
mv $script_home/pharo ~/pharo/bin
mv $script_home/pharo-vm ~/pharo/bin

echo "Successfully installed the following Pharo runtime:"
~/pharo/bin/pharo ~/pharo/build/Pharo.image printVersion
