#!/bin/bash
#
# GamePanelX
# Remote Scripts v3.0.14
#
# Update Script
#
# Licensed under the GPL (GNU General Public License V3)
#
echo -e "\e[00;34m##################################################################"
echo "##                                                              ##"
echo "##                         GamePanelX                           ##"
echo "##                                                              ##"
echo "##       Welcome to the Remote Update Script (v3.0.14)          ##"
echo "##                                                              ##"
echo -e "##################################################################\e[00m"
echo
remote_version="3.0.14"

if [ "$UID" -ne "0" ]
then
    echo "ERROR: You must be the root user to run this script.  Exiting."
    exit
fi

echo
read -p "This will update the remote scripts to the latest.  Continue? (y/n): " sure_upd

if [[ "$sure_upd" == "y" || "$sure_upd" == "yes" || "$sure_upd" == "Y" ]]
then
	if [ ! -f ./gpx-remote-latest.tar.gz ]; then
		echo "No file ./gpx-remote-latest.tar.gz found, exiting."
		exit
	fi

	tar -zxf ./gpx-remote-latest.tar.gz -C /usr/local/gpx bin/*
else
	echo "Not updating, exiting."
	exit
fi

echo
echo "...done"
