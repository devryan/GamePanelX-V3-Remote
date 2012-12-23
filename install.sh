#!/bin/bash
#
# GamePanelX
# Remote Scripts v3.0.10
#
# Installation Script
#
# Licensed under the GPL (GNU General Public License V3)
#
echo -e "\e[00;34m##################################################################"
echo "##                                                              ##"
echo "##                         GamePanelX                           ##"
echo "##                                                              ##"
echo "##       Welcome to the Remote Server installer (v3.0.10)       ##"
echo "##                                                              ##"
echo -e "##################################################################\e[00m"
echo

if [ "$UID" -ne "0" ]
then
    echo "ERROR: You must be the root user to run this script.  Exiting."
    exit
fi

# Check for GNU Screen
if [ "$(which screen 2>&1 | grep 'no screen in')" ]
then
        # CentOS / RedHat
        if [ -f /etc/redhat-release ]
        then
                echo
                read -p "(RedHat) Missing requirements!  Is it OK to install packages via Yum (yum install screen)? (y/n): " gpx_ok_yum

                if [[ "$gpx_ok_yum" == "y" || "$gpx_ok_yum" == "yes" || "$gpx_ok_yum" == "Y" ]]
                then
                        yum -y install screen
                fi
        # Debian / Ubuntu
        elif [ -f /etc/debian_version ]
        then 
                echo
                read -p "(Debian) Missing requirements!  Is it OK to install packages via APT (apt-get install screen)? (y/n): " gpx_ok_apt

                if [[ "$gpx_ok_apt" == "y" || "$gpx_ok_apt" == "yes" || "$gpx_ok_apt" == "Y" ]]
                then
                        apt-get --yes install screen
                fi
        # Gentoo
        elif [ -f /etc/gentoo-release ]
        then
                echo
                read -p "(Gentoo) Missing requirements!  Is it OK to install packages via Portage (emerge screen)? (y/n): " gpx_ok_gentoo

                if [[ "$gpx_ok_gentoo" == "y" || "$gpx_ok_gentoo" == "yes" || "$gpx_ok_gentoo" == "Y" ]]
                then
                        emerge screen
                fi
        fi
fi

##############################################################

# User input
read -p "Create this Linux user for game/voice servers: " gpx_user
echo

# Check required
if [ "$gpx_user" == "" ]
then
    # echo "You must specify a username!  Exiting."
    echo -e "\e[00;31mYou must specify a username!  Exiting.\e[00m"
    exit
fi

# Check if user already exists
chk_exist="$(cat /etc/passwd | awk -F':' '{print $1}' | grep $gpx_user)"
if [ "$chk_exist" ]
then
    echo "ERROR: That user already exists ($chk_exist).  Please choose a different username and try again.  Exiting."
    exit
fi

# Create the gpx user
useradd -m -c "GamePanelX" -s /bin/bash $gpx_user
gpx_user_home="$(eval echo ~$gpx_user)"

# Log this username
echo $gpx_user > .gpx_lastuser

# Make sure homedir exists
if [ ! -d "$gpx_user_home" ]
then
        echo "ERROR: Failed to find the users homedir!  Exiting."
        exit
fi

# Untar the Remote files
if [ -f "./gpx-remote-latest.tar.gz" ]
then
        tar -zxf ./gpx-remote-latest.tar.gz -C $gpx_user_home/
else
        echo "ERROR: Latest remote server files (./gpx-remote-latest.tar.gz) not found!  Try re-downloading the remote files and try again.  Exiting."
        exit
fi

# Change ownership of all the new files
chown $gpx_user:$gpx_user $gpx_user_home
chown $gpx_user:$gpx_user $gpx_user_home -R

# Set system password
echo
echo "-- Enter a password for GamePanelX user \"$gpx_user\" "
passwd $gpx_user

#############################################################################################################

# FTP Server Installation
echo;echo
read -p "Install GamePanelX FTP server? (y/n): " gpx_ftp_ans

if [[ "$gpx_ftp_ans" == "y" || "$gpx_ftp_ans" == "yes" || "$gpx_ftp_ans" == "Y" ]]
then
	if [ ! -f ./ftp.sh ]
	then
		echo "No FTP script (./ftp.sh) found!  Exiting."
		exit
	fi

	chmod u+x ftp.sh
	./ftp.sh -u $gpx_user
fi

echo
echo
echo "##################################################################"
echo
echo -e "\e[00;32mCompleted GamePanelX Remote Server Installation! \e[00m"
echo
exit
