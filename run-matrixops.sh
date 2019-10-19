#! /bin/bash -xe

#   Copyright 2019 Safayet N Ahmed
#   All rights reserved

#
#   Run the following commands (as root: sudo -s) to ensure kernel
#   power management does not change clock freuqnecy during run.
#   
#   Our timematrixop utility sets affinity to CPU0, so we are only
#   interested in CPU0.
#
#   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
#   sudo echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
#   echo 2500000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
#
#   After collecting times, restore power-management settings:
#   sudo echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#

# Compile
gcc -O3 -Wall -Wpedantic ./timematrixop.c -o ./timematrixop -lrt

# Run
sudo ./timematrixop 0 > matrix-0-optime.csv
sudo ./timematrixop 2 > matrix-2-optime.csv
sudo ./timematrixop 7 > matrix-7-optime.csv
sudo ./timematrixop 22 > matrix-22-optime.csv
sudo ./timematrixop 63 > matrix-63-optime.csv
sudo ./timematrixop 110 > matrix-110-optime.csv
sudo ./timematrixop 361 > matrix-361-optime.csv
sudo ./timematrixop 886 > matrix-886-optime.csv
sudo ./timematrixop 1000 > matrix-1000-optime.csv

