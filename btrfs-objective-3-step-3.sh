#!/bin/bash
# Script for checking that an additional disk has been added to Btrfs volume

# Author - Katrin Loodus
# Modified by - Janne Pakkonen
#
# Date - 27.04.2016
# Modify Date - 15.05.2019
# Version - 0.0.1

LC_ALL=C

# set variables

START () {

	# Enable logging
	echo -e "\n$0 started on: $(date):" >> /var/log/labcheckslog.log
	exec &> >(tee -a /var/log/labcheckslog.log)

	# Step uname in VirtualTA. Must be set!
	Uname='btrfs-objective-3-step-3'

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

   	# Check that /dev/sde has been added to the filesystem mounted on /var/data
    	ssh root@$IP_to_SSH 'btrfs filesystem show /var/data | grep sde'

   	# Run objectiveschecks.py and update VirtualTa with correct value
    	if [ $? -eq 0 ]; then

        	echo -e "\n Success: Disk /dev/sde has been added to the filesystem mounted on /var/data! Date: `date`\n" && touch $CheckFile
        	$DIR/objectivechecks.py $Uname True || echo -e "\n Failed to run $DIR/objectiveschecks.py! Date: `date`" >&2 && exit 1
        	exit 0

    	else

        	echo -e "Failed: /var/data has not been expanded! Date: `date`\n" >&2
        	sleep $Sleep

    	fi
	done

}

START

CHECKER

exit 0