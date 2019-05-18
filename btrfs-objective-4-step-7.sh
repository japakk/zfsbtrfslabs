#!/bin/bash
# Script for checking that RAID0 has been converted to RAID10

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
	Uname='btrfs-objective-4-step-7'

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

   	# Check that RAID0 and it's mountpoint have been changed to RAID10
    	ssh root@$IP_to_SSH 'btrfs filesystem df /var/raid10 | grep "Data RAID10" && btrfs filesystem df /var/raid10 | grep "Metadata RAID10" && mount | grep sdf && diskid=$(ls -l /dev/disk/by-uuid | grep -w sdd | tr -s ' ' | cut -d' ' -f9) && cat /etc/fstab | grep $diskid'

   	# Run objectiveschecks.py and update VirtualTa with correct value
    	if [ $? -eq 0 ]; then

        	echo -e "\n Success: RAID0 is converted to RAID10 and mountpoint is changed and permanent! Date: `date`\n" && touch $CheckFile
        	$DIR/objectivechecks.py $Uname True || echo -e "\n Failed to run $DIR/objectiveschecks.py! Date: `date`" >&2 && exit 1
        	exit 0

    	else

        	echo -e "Failed: RAID0 has not been converted to RAID10 or is not mounted or mountpoint is not permanent! Date: `date`\n" >&2
        	sleep $Sleep

    	fi
	done

}

START

CHECKER

exit 0