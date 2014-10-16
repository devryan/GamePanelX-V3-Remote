#!/bin/bash
#
# GamePanelX
# FTP Install v3.0.14
#
# This script supports dependency detection on RedHat/CentOS/Fedora, Debian/Ubuntu, and Gentoo
# Note: As of 3.0.14, MySQL is no longer needed.  System users only; e.g. basic install.
#
# Usage: ./ftp.sh -u someuser
#
# Licensed under the GPL (GNU General Public License V3)
#
if [ "$UID" -ne "0" ]
then
    echo "ERROR: You must be the root user to run this script.  Exiting."
    exit
fi

while getopts "u:" OPTION
do
     case $OPTION in
	 u)
	     gpx_user=$OPTARG
	     ;;
         ?)
             exit
             ;;
     esac
done

if [ "$gpx_user" == "" ]
then
	echo "FTP ERROR: No username specified!  Exiting."
	exit
fi

##############################################################

# Check for a running FTP server
ftp_out="$(netstat -an | grep ':21 ' | grep LISTEN)"

if [ "$ftp_out" ]
then
        echo
        echo
        echo -e "\e[00;31mFTP ERROR: There is already a running FTP server on port 21:\e[00m"
        echo "$ftp_out"
        echo -e "\e[00;31mYou must manually stop the other FTP server first.  SKIPPING FTP server installation.\e[00m"
        exit
fi

# Function to check required
gpx_checkreq () {
	yum_cmd=
	apt_cmd=

	# Check GCC Compiler
	if [[ ! -f /usr/bin/make && ! -f /usr/local/bin/make && ! -f /bin/make ]]; then
	    yum_cmd="gcc kernel-headers make"
	    apt_cmd="build-essential"
	    gentoo_cmd="sys-devel/gcc"
	elif [[ ! -f /usr/bin/gcc && ! -f /usr/local/bin/gcc && ! -f /bin/gcc ]]; then
            yum_cmd="gcc kernel-headers make"
            apt_cmd="build-essential"
            gentoo_cmd="sys-devel/gcc"
	fi
}

# Check required
gpx_checkreq

# CentOS / RedHat
if [ -f /etc/redhat-release ]
then
	if [ "$yum_cmd" ]
	then
		echo
		read -p "(RedHat) Missing requirements!  Is it OK to install packages via Yum (yum install $yum_cmd)? (y/n): " gpx_ok_yum

		if [[ "$gpx_ok_yum" == "y" || "$gpx_ok_yum" == "yes" || "$gpx_ok_yum" == "Y" ]]
		then
        yum -y install $yum_cmd
		fi
	fi
# Debian / Ubuntu
elif [ -f /etc/debian_version ]
then
	if [ "$apt_cmd" ]
	then
		echo
		read -p "(Debian) Missing requirements!  Is it OK to install packages via APT (apt-get install $apt_cmd)? (y/n): " gpx_ok_apt

		if [[ "$gpx_ok_apt" == "y" || "$gpx_ok_apt" == "yes" || "$gpx_ok_apt" == "Y" ]]
		then
        apt-get --yes install $apt_cmd
		fi
	fi
# Gentoo
elif [ -f /etc/gentoo-release ]
then
	if [ "$gentoo_cmd" ]
	then
		echo
		read -p "(Gentoo) Missing requirements!  Is it OK to install packages via Portage (emerge $gentoo_cmd)? (y/n): " gpx_ok_gentoo

		if [[ "$gpx_ok_gentoo" == "y" || "$gpx_ok_gentoo" == "yes" || "$gpx_ok_gentoo" == "Y" ]]
    then
        emerge $gentoo_cmd
    fi
	fi
fi

# Check again
gpx_checkreq

if [ "$yum_cmd" ]
then
    echo "ERROR: Unable to install the required packages!  Please make sure GCC is installed and try again."
    exit
fi

echo
echo -e "\e[00;32mRequirements passed!  Installing FTP Server ...\e[00m"
echo
sleep 1

##############################################################

# Prepare FTP Server
rm -fr /usr/local/gpx/ftpd/src
mkdir -p /usr/local/gpx/ftpd/src
cd /usr/local/gpx/ftpd/src

# Only download if needed
if [ ! -f ./ftpd-latest.tar.gz ]
then
    wget http://gamepanelx.com/files/ftpd-latest.tar.gz
fi

if [ ! -f ./ftpd-latest.tar.gz ]
then
    echo "ERROR: Failed to download the latest FTP Server files!  Exiting."
    exit
fi

# Compile FTP Server
tar -zxf ftpd-latest.tar.gz
cd ftpd-latest
./configure --prefix=/usr/local/gpx/ftpd
sleep 1
make
sleep 1
make install

################

if [ ! -f "/usr/local/gpx/ftpd/sbin/pure-ftpd" ]
then
    echo
    echo -e "\e[00;31mERROR: The FTP Server installation failed (no binary).  Check the output above for why the FTP installation failed. Exiting.\e[00m"
    exit
fi

################

# Create startup script
echo '#!/bin/bash' > /usr/local/gpx/ftpd/start.sh
echo "/usr/local/gpx/ftpd/sbin/pure-ftpd -A -B -C 5 -c 150 -E -H -R -x -X -d -j" >> /usr/local/gpx/ftpd/start.sh
chmod u+x /usr/local/gpx/ftpd/start.sh

# Security
chown root: /usr/local/gpx/ftpd -R
chmod 600 /usr/local/gpx/ftpd

# Start the FTP Server
/usr/local/gpx/ftpd/start.sh
sleep 2

# Check if server is running
ftp_pid="$(ps -ef | grep 'pure-ftpd (SERVER)' | grep -v grep | awk '{print $2}')"

if [ "$ftp_pid" ]
then
    # Save PID
    echo $ftp_pid > /usr/local/gpx/ftpd/pure-ftpd.pid
    
    echo -e "\e[00;32mFTP Server started successfully with PID $ftp_pid! \e[00m"
else
    rm -f /usr/local/gpx/ftpd/pure-ftpd.pid
    
    echo -e "\e[00;31mFTP Server failed to start, no running PID found! \e[00m"
fi

################

echo
echo
echo
echo
echo -e "\e[00;32mFinished Installing the FTP Server.\e[00m"
echo
