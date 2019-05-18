#!/bin/bash
# Script for checking that a RAIDZ3 has been created out of six disks and dataset created to the zpool

# Author - Katrin Loodus
# Modified by - Janne Pakkonen
#
# Date - 27.04.2016
# Modify Date - 13.05.2019
# Version - 0.0.1

LC_ALL=C

# set variables

START () {

	# Enable logging
	echo -e "\n$0 started on: $(date):" >> /var/log/labcheckslog.log
	exec &> >(tee -a /var/log/labcheckslog.log)

	# Step uname in VirtualTA. Must be set!
	Uname='zfs-objective-4-step-8'

	# If $CheckFile exists, then exit the script. Must be unique!
	CheckFile="/tmp/$Uname"

	if [ -f $CheckFile ]; then echo "$0 has already ran successfully" && exit 0; fi

    # Exit if there are undeclared variables
    set -o nounset     

	# Get working directory
	DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

	# IP of server/desktop where test is performed. Must be set!
	IP_to_SSH=

	# Time to sleep between running the check again
	Sleep=5


}

# Test if action is successful

CHECKER () {

	while true
	do

   	# Check if RAIDZ3 zpool zfs_pool_5 is created from /dev/sdh, /dev/sdi, /dev/sdj, /dev/sdk, /dev/sdl and /dev/sdm and dataset ds5 is created to the zpool
    	ssh root@$IP_to_SSH 'zpool_status_5=$(zpool status zfs_pool_5) && $zpool_status_5 | grep sdh && $zpool_status_5 | grep sdi && $zpool_status_5 | grep sdj && $zpool_status_5 | grep sdk && $zpool_status_5 | grep sdl && $zpool_status_5 | grep sdm && $zpool_status_5 | grep raidz3-0 && zfs list zfs_pool_5/ds5'

   	# Run objectiveschecks.py and update VirtualTa with correct value
    	if [ $? -eq 0 ]; then

        	echo -e "\n Success: Zpool zfs_pool_5 is created from /dev/sdh, /dev/sdi, /dev/sdj, /dev/sdk, /dev/sdl and /dev/sdm, dataset ds5 is created to zpool zfs_pool_5! Date: `date`\n" && touch $CheckFile
        	$DIR/objectivechecks.py $Uname True || echo -e "\n Failed to run $DIR/objectiveschecks.py! Date: `date`" >&2 && exit 1
        	exit 0

    	else

        	echo -e "Failed: Zpool zfs_pool_5 or dataset ds5 has not been created! Date: `date`\n" >&2
        	sleep $Sleep

    	fi
	done

}

START

CHECKER

exit 0