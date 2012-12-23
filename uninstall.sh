#!/bin/bash
#
# GamePanelX
# Remote Scripts v3.0.10
#
# Removal Script (Remove last known gpx system user if available)
#
# Licensed under the GPL (GNU General Public License V3)
#
echo -e "\e[00;34mWelcome to the GamePanelX uninstaller!"
echo -e "This will attempt to remove any GamePanelX-related files.\e[00m"
echo

if [ -f .gpx_lastuser ]
then
	last_user="$(cat .gpx_lastuser)"
else
	# Get last system GPX user in /etc/passwd
	last_user="$(grep 'GamePanelX' /etc/passwd | tail -1 | awk -F: '{print $1}')"
fi

if [ "$last_user" == "" ]
then
	echo -e "\e[00;31mUnable to determine the last known GamePanelX User!\e[00m"
	echo "If you know the system username, you can manually run:"
	echo
	echo "pkill pure-ftpd"
	echo "userdel someuser"
	echo "rm -frv /home/someuser"
	echo
	echo "!! Only run the 'rm' command if you are OK with deleting all related gameservers for that account!"
	echo "Also note you will need to ensure all gameservers are manually stopped."
	exit
fi

echo "Found '$last_user' to be the most recent GamePanelX User."
read -p "Remove this user and all GamePanelX files? (y/n): " gpx_accept
read -p "Also delete $last_user gameservers and related accounts? (y/n): " gpx_del_all

if [[ "$gpx_accept" == "y" || "$gpx_accept" == "yes" || "$gpx_accept" == "Y" ]]
then
	echo "Removing $last_user ..."
	userdel $last_user

	echo "Stopping FTP server ..."
	pkill pure-ftpd

	if [[ "$gpx_del_all" == "y" || "$gpx_del_all" == "yes" || "$gpx_del_all" == "Y" ]]
	then
		# Remove everything
		echo "Removing entire home directory (/home/$last_user) in 4 seconds ..."
		sleep 4
		rm -frv /home/$last_user/
	else
		# Remove all but accounts
		echo "Removing all but accounts and servers in /home/$last_user in 3 seconds ..."
		sleep 3
		rm -frv /home/$last_user/{addons,ftpd,logs,scripts,templates,tmp,uploads}
	fi

	# Remove log of this user since they are gone
	rm -f .gpx_lastuser
fi

