#!/bin/bash

script_home=$(dirname $0)
script_home=$(cd $script_home && pwd)
vm=$script_home/../bin/pharo
image=$script_home/build.image

#$vm $image config http://mc.stfx.eu/MyRepository ConfigurationOfMyApplicationServer --username=deploy@acme.com --password=secret --install=bleedingEdge

$vm $image config http://mc.stfx.eu/Neo ConfigurationOfNeoConsole --install=stable
