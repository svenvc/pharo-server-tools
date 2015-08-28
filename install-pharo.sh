#!/bin/bash
script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
sudo apt-get install unzip 
curl get.pharo.org/40+vm | bash
rm $script_home/pharo-ui
mkdir ~/pharo
mkdir ~/pharo/bin
mkdir ~/pharo/build
mv $script_home/Pharo.image ~/pharo/build
mv $script_home/Pharo.changes ~/pharo/build
cp $script_home/build.sh ~/pharo/build
mv $script_home/pharo ~/pharo/bin
mv $script_home/pharo-vm ~/pharo/bin
~/pharo/bin/pharo ~/pharo/build/Pharo.image printVersion
