#!/bin/bash
# Script for checking zfs dataset creation and mountpoint change

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
	Uname='zfs-objective-1-step-7'

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

   	# Check if dataset ds1 has been created in zpool zfs_pool_1 and has specifically /var/data set as mountpoint
    	ssh root@$IP_to_SSH 'zfs list zfs_pool_1/ds1 | grep -w "/var/data"'

   	# Run objectiveschecks.py and update VirtualTa with correct value
    	if [ $? -eq 0 ]; then

        	echo -e "\n Success: Dataset ds1 has been created in pool zfs_pool_1 and mountpoint is /var/data! Date: `date`\n" && touch $CheckFile
        	$DIR/objectivechecks.py $Uname True || echo -e "\n Failed to run $DIR/objectiveschecks.py! Date: `date`" >&2 && exit 1
        	exit 0

    	else

        	echo -e "Failed: Dataset ds1 has not been created in pool zfs_pool_1 or mountpoint is not /var/data! Date: `date`\n" >&2
        	sleep $Sleep

    	fi
	done

}

START

CHECKER

exit 0