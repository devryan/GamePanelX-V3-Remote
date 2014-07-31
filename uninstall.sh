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
    # Optionally remove client system accounts
    echo
    total_clients=$(grep -c ':GamePanelX User:' /etc/passwd)

    if [ $total_clients -gt 0 ]; then
        read -p "Also remove ALL GamePanelX client system accounts (e.g. gpxuser123) from this server? (y/n): " gpx_sure_rm_clients

        if [[ "$gpx_sure_rm_clients" == "y" || "$gpx_sure_rm_clients" == "yes" || "$gpx_sure_rm_clients" == "Y" ]]; then
            echo "OK, removing ALL GamePanelX client system accounts ($total_clients total) in 4 seconds (CTRL+C to stop) ..."
            sleep 4

            for gpxclient in $(grep ':GamePanelX User:' /etc/passwd | awk -F':' '{print $1}' | grep -E '^gpx')
            do
                if [[ "$gpxclient" && "$gpxclient" != "root" ]]; then
            	echo "Removing system account $gpxclient and their homedir ..."
                    userdel -r $gpxclient
                fi
            done
        else
            echo "We will NOT be removing any GamePanelX client system accounts."
        fi
    fi

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
        echo "Removing $last_user and their homedir ..."
        userdel -r $last_user
        
        echo "Stopping FTP server ..."
        pkill pure-ftpd
    fi
    
    # Remove main directory
    echo "Removing /usr/local/gpx in 4 seconds (CTRL+C to stop) ..."
    sleep 4
    rm -fr /usr/local/gpx

    ## Remove from boot

    # CentOS / RedHat
    if [ -f /etc/redhat-release ]; then
        echo "Removing RedHat system GamePanelX service ..."
        chkconfig gpx off
    # Debian / Ubuntu
    elif [ -f /etc/debian_version ]; then
        echo "Removing Debian system GamePanelX service ..."
        update-rc.d -f gpx remove
    # Gentoo
    elif [ -f /etc/gentoo-release ]; then
        echo "Removing Gentoo system GamePanelX service ..."
        rc-update del gpx default
    fi
    rm -f /etc/init.d/gpx
   
    echo
    echo "Successfully removed GamePanelX Remote."
fi
