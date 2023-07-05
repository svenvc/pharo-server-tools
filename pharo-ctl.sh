#!/bin/bash

function usage() {
    cat <<END
Usage: $0 <script> <command> <image>
    manage a Pharo server
Naming
    script       is used as unique identifier
    script.st    must exist and is the Pharo startup script  
    script.pid   will be used to hold the process id
    image.image  is the Pharo image that will be started
Commands:
    start    start the server in background
    stop     stop the server
    restart  restart the server
    run      run the server in foreground
    pid      print the process id 
END
    exit 1
}

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)

script=$1
command=$2
image=$3

echo Executing $0 $script $command $image
echo Working directory $script_home

if [ "$#" -ne 3 ]; then
    usage
fi

image="$script_home/$image.image"

if [ ! -e "$image" ]; then
    echo $image not found
    exit 1
fi

st_file="$script_home/$script.st"

if [ ! -e "$st_file" ]; then
    echo $st_file not found
    exit 1
fi

pid_file="$script_home/$script.pid"

# If needed, modify VM version here
vm_version_short=8

# Some magick to switch VM options by version
# See https://stackoverflow.com/a/18124325
vm_version="$vm_version_short.0"
vm_options_8="--vm-display-null"
vm_options_9="--headless"
vm_options_10="--headless"
vm_options_11="--headless"
vm_options_var=vm_options_$vm_version_short
vm_options=${!vm_options_var}

vm_home=$(/usr/bin/realpath $script_home/../lib/$vm_version)
# Using lower level script to make sure 'ps' lists only 1 process
vm=$vm_home/pharo-vm/pharo

function start() {
    echo Starting $script in background
    if [ -e "$pid_file" ]; then
	rm -f $pid_file
    fi
    echo $vm $vm_options $image $st_file
    $vm $vm_options $image $st_file 2>&1 >/dev/null &
    echo $! >$pid_file
}

function run() {
    echo Running $script in foreground
    echo $vm $vm_options $image $st_file
    $vm $vm_options $image $st_file
}

function stop() {
    echo Stopping $script
    if [ -e "$pid_file" ]; then
        pid=`cat $pid_file`
        echo Killing $pid
	kill $pid 
	rm -f $pid_file
    else
        echo Pid file not found: $pid_file
	echo Searching in process list for $script
	pids=`ps ax | grep $script | grep -v grep | grep -v $0 | awk '{print $1}'`
	if [ -z "$pids" ]; then
            echo No pids found!
	else
            for p in $pids; do
		if [ $p != "$pid" ]; then
                    echo Killing $p
                    kill $p
		fi
            done
	fi
    fi
}

function restart() {
    echo Restarting $script
    stop
    start
}

function printpid() {
    if [ -e $pid_file ]; then
	cat $pid_file
    else
        echo Pid file not found: $pid_file
	echo Searching in process list for $script
	pids=`ps ax | grep $script | grep -v grep | grep -v $0 | awk '{print $1}'`
	if [ -z "$pids" ]; then
            echo No pids found!
	else
	    echo $pids
	fi 
    fi
}

case $command in
    start)
		start
		;;
    stop)
		stop
		;;
    restart)
		restart
		;;
    run)
		run
		;;
    pid)
	        printpid
		;;
    *)
		usage
		;;
esac

