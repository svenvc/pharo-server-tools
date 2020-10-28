#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
echo "Running from $script_home"

project=_SERVICE_NAME_

build_home=$script_home/../build
build_home=$(cd $build_home && pwd)
echo "Will run semi-automatic build process for project: $project"

if [ ! -f $build_home/build-$project.sh ]; then
  echo "Sorry, could not find build script: $build_home/build-$project.sh"
  exit 1
fi

# Move old build directory to archive
echo "Moving any old build directories to $build_home/_archive/"
mkdir -p $build_home/_archive
mv -v $build_home/$project-* $build_home/_archive/

# Start new build
echo "Starting new build for project: $project"
$build_home/build-$project.sh &

# Wait for new build directory and log file to be created
echo "Waiting for build directory and log file to be created..."
sleep 5

# Follow tail of build log
echo "Tailing build log until finished"
tail -f $(ls -d $build_home/$project-*)/build.log | sed '/^Build finished$/ q'

echo "Waiting for deploy script to be generated..."
while [ ! -f "$(ls -d $build_home/$project-*)/deploy.sh" ]; do
  sleep 1
done

echo "Stopping $project service"
sudo systemctl stop $project

# Deploy
$(ls -d $build_home/$project-*)/deploy.sh

echo "Starting $project service"
sudo systemctl start $project
