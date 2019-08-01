#!/bin/bash
script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)

curl get.pharo.org/64/70+vm | bash
rm $script_home/pharo-ui

mkdir -p ~/pharo/bin ~/pharo/build
mv $script_home/Pharo7.0-32bit-*.sources ~/pharo/build
mv $script_home/Pharo.changes ~/pharo/build
mv $script_home/Pharo.image ~/pharo/build

cp $script_home/build.sh ~/pharo/build
mv $script_home/pharo ~/pharo/bin
mv $script_home/pharo-vm ~/pharo/bin

echo "Successfully installed the following Pharo runtime:"
~/pharo/bin/pharo ~/pharo/build/Pharo.image printVersion
