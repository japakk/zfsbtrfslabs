#!/bin/bash
# Script for checking that a Btrfs filesystem has been created and a permanent mountpoint is created

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
	Uname='btrfs-objective-1-step-3'

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

   	# Check that /dev/sdb1 has btrfs filesystem and a permanent mountpoint exists in /etc/fstab
    	ssh root@$IP_to_SSH 'blkid /dev/sdb1 | grep btrfs && diskid=$(ls -l /dev/disk/by-uuid | grep -w sdb1 | tr -s ' ' | cut -d' ' -f9) && cat /etc/fstab | grep $diskid'

   	# Run objectiveschecks.py and update VirtualTa with correct value
    	if [ $? -eq 0 ]; then

        	echo -e "\n Success: Btrfs filesystem detected on /dev/sdb1 and filesystem is mounted at startup! Date: `date`\n" && touch $CheckFile
        	$DIR/objectivechecks.py $Uname True || echo -e "\n Failed to run $DIR/objectiveschecks.py! Date: `date`" >&2 && exit 1
        	exit 0

    	else

        	echo -e "Failed: /dev/sdb1 does not have Btrfs filesystem or mounting is not permanent! Date: `date`\n" >&2
        	sleep $Sleep

    	fi
	done

}

START

CHECKER

exit 0