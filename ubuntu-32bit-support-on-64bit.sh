#!/bin/bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386
sudo apt-get install libssl1.0.0:i386
sudo apt-get install libfreetype6:i386
