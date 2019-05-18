#!/bin/bash
# Script for checking if zpool is created on two disks and a dataset has been created to the created Zpool

# Author - Katrin Loodus
# Modified by - Janne Pakkonen
#
# Date - 27.04.2016
# Modify Date - 12.05.2019
# Version - 0.0.1

LC_ALL=C

# set variables

START () {

	# Enable logging
	echo -e "\n$0 started on: $(date):" >> /var/log/labcheckslog.log
	exec &> >(tee -a /var/log/labcheckslog.log)

	# Step uname in VirtualTA. Must be set!
	Uname='zfs-objective-2-step-0'

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

   	# Check if zpool zfs_pool_2 has been created on /dev/sdc and /dev/sdd and dataset ds2 has been created
    	ssh root@$IP_to_SSH 'zpool_status=$(zpool status zfs_pool_2)" && $zpool_status | grep sdc && $zpool_status | grep sdd && zfs list zfs_pool_2/ds2'

   	# Run objectiveschecks.py and update VirtualTa with correct value
    	if [ $? -eq 0 ]; then

        	echo -e "\n Success: Zpool zfs_pool_2 has been created on /dev/sdc and /dev/sdd and dataset ds2 has been created to zfs_pool_2! Date: `date`\n" && touch $CheckFile
        	$DIR/objectivechecks.py $Uname True || echo -e "\n Failed to run $DIR/objectiveschecks.py! Date: `date`" >&2 && exit 1
        	exit 0

    	else

        	echo -e "Failed: Zpool zfs_pool_2 has not been created on /dev/sdc and /dev/sdd or dataset ds has not been created to zfs_pool_2! Date: `date`\n" >&2
        	sleep $Sleep

    	fi
	done

}

START

CHECKER

exit 0