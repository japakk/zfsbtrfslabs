#!/bin/bash
# Script for checking that a striped mirrored RAIDZ has been created out of four disks and dataset created to the zpool

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
	Uname='zfs-objective-4-step-5'

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

   	# Check if mirrored zpool zfs_pool_4 is created from /dev/sdh, /dev/sdi, /dev/sdj and /dev/sdk and dataset ds4 is created to the zpool
    	ssh root@$IP_to_SSH 'zpool_status_4=$(zpool status zfs_pool_4) && $zpool_status_4 | grep sdh && $zpool_status_4 | grep sdi && $zpool_status_4 | grep sdj && $zpool_status_4 | grep sdk && $zpool_status_4 | grep mirror-0 && $zpool_status_4 | grep mirror-1 && zfs list zfs_pool_4/ds4'

   	# Run objectiveschecks.py and update VirtualTa with correct value
    	if [ $? -eq 0 ]; then

        	echo -e "\n Success: Zpool zfs_pool_4 is created from /dev/sdh, /dev/sdi, /dev/sdj and /dev/sdk, dataset ds4 is created to zpool zfs_pool_4! Date: `date`\n" && touch $CheckFile
        	$DIR/objectivechecks.py $Uname True || echo -e "\n Failed to run $DIR/objectiveschecks.py! Date: `date`" >&2 && exit 1
        	exit 0

    	else

        	echo -e "Failed: Zpool zfs_pool_4 has not been created or dataset ds4 has not been created! Date: `date`\n" >&2
        	sleep $Sleep

    	fi
	done

}

START

CHECKER

exit 0