#!/bin/bash
#
# GamePanelX
# Remote Scripts v3.0.12
#
# Removal Script (Remove last known gpx system user if available)
#
# Licensed under the GPL (GNU General Public License V3)
#
echo -e "\e[00;34mWelcome to the GamePanelX uninstaller!"
echo -e "This will attempt to remove any GamePanelX-related files.\e[00m"
echo

read -p "Are you sure?  Remove ALL GamePanelX Remote files? (y/n): " gpx_sure_remove

if [[ "$gpx_sure_remove" == "y" || "$gpx_sure_remove" == "yes" || "$gpx_sure_remove" == "Y" ]]
then
    # Remove main user account
    if [ -f .gpx_lastuser ]
    then
      last_user="$(cat /usr/local/gpx/.gpx_lastuser)"
    else
      # Get last system GPX user in /etc/passwd
      last_user="$(grep ':GamePanelX:' /etc/passwd | tail -1 | awk -F: '{print $1}')"
    fi

    if [ "$last_user" == "" ]
    then
      echo -e "\e[00;31mUnable to determine the last known GamePanelX User!\e[00m"
      echo "If you know the system username, you can manually run:"
      echo
      echo "pkill pure-ftpd"
      echo "userdel someuser"
      echo
      echo "Otherwise, /usr/local/gpx has been removed. Exiting."
      exit
    fi

    echo "Found '$last_user' to be the most recent GamePanelX User."
    read -p "Remove this user? (y/n): " gpx_accept

    if [[ "$gpx_accept" == "y" || "$gpx_accept" == "yes" || "$gpx_accept" == "Y" ]]
    then
        echo "Removing $last_user ..."
        userdel $last_user
        
        echo "Stopping FTP server ..."
        pkill pure-ftpd
    fi
    
    # Remove main directory
    echo "Removing /usr/local/gpx in 4 seconds ..."
    sleep 4
    rm -fr /usr/local/gpx
    
    echo
    echo "Successfully removed GamePanelX Remote."
fi
