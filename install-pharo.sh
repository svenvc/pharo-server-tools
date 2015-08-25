#!/bin/bash
sudo apt-get install unzip 
curl get.pharo.org/40+vm | bash
rm pharo-ui
mkdir ~/pharo
mkdir ~/pharo/bin
mkdir ~/pharo/build
mv Pharo.image ~/pharo/build
mv Pharo.changes ~/pharo/build
cp build.sh ~/pharo/build
mv pharo ~/pharo/bin
mv pharo-vm ~/pharo/bin
~/pharo/bin/pharo ~/pharo/build/Pharo.image printVersion
