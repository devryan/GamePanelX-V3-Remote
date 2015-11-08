#!/bin/bash
#
# GamePanelX
# Remote Scripts v3.0.15
#
# Update Script
#
# Licensed under the GPL (GNU General Public License V3)
#
remote_version="3.0.15"

echo -e "\e[00;34m##################################################################"
echo "                                                              "
echo "                         GamePanelX                           "
echo "                                                              "
echo "       Welcome to the Remote Update Script (v$remote_version)          "
echo "                                                              "
echo -e "##################################################################\e[00m"
echo

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

sleep 1

##################################################################

 # Stop manager
if [ "$(ps -ef | grep 'GPXManager' | grep -v grep)" ]; then
        killall GPXManager
fi

# Start manager
/usr/local/gpx/bin/GPXManager

##################################################################

# Set permissions
if [ -f .gpx_lastuser ]
then
	gpx_user="$(cat /usr/local/gpx/.gpx_lastuser)"
else
	# Get last system GPX user in /etc/passwd
	gpx_user="$(grep ':GamePanelX:' /etc/passwd | tail -1 | awk -F: '{print $1}')"
fi

if [ "$gpx_user" == "" ]; then
	echo "No gpx user found, exiting."
	exit
fi

#chown $gpx_user: /usr/local/gpx -R
#chown root:$gpx_user /usr/local/gpx/users -R
chown root: /usr/local/gpx/ftpd -R
#chmod 0660 /usr/local/gpx/users -R
chmod 0750 /usr/local/gpx/{logs,templates} -R
chmod 0660 /usr/local/gpx/logs/*
#chmod 0700 /usr/local/gpx/{addons,queue,tmp,etc,uploads,users} -R
chmod 0700 /usr/local/gpx/{addons,queue,tmp,etc,uploads} -R
chmod 0760 /usr/local/gpx/queue /usr/local/gpx/tmp
chmod 0774 /usr/local/gpx/users
chmod 0555 /usr/local/gpx/bin
chmod 0754 /usr/local/gpx/bin/*

##################################################################

echo
echo "...done"
