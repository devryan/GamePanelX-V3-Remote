#!/bin/bash
#
# GamePanelX
# FTP Install v3.0
#
# This script supports dependency detection on RedHat/CentOS/Fedora, Debian/Ubuntu, and Gentoo
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

# Get Homedir
gpx_user_home="$(eval echo ~$gpx_user)"

# Get UID and GID for FTP mysql.conf
avail_uid="$(grep $gpx_user /etc/passwd | awk -F: '{print $3}')"
avail_gid="$(grep $gpx_user /etc/group | awk -F: '{print $3}')"

if [[ "$gpx_user_home" == "" || "$avail_uid" == "" || "$avail_gid" == "" ]]
then
	echo "FTP ERROR: Required values were left out.  Exiting."
	exit
fi

echo
read -p "Master Server MySQL Server IP Address: " gpx_master_ip
read -p "Master Server MySQL Server Port: " gpx_master_mysql_port
read -p "Master Server MySQL Server Database Name: " gpx_master_mysql_db
read -p "Master Server MySQL Server Database Username: " gpx_master_mysql_user
read -p "Master Server MySQL Server Database Password: " gpx_master_mysql_pass

echo
echo "##################################################################"
echo

##############################################################

# Check required mysql
if [[ "$gpx_user" == "" || "$gpx_master_ip" == "" || "$gpx_master_mysql_port" == "" || "$gpx_master_mysql_db" == "" || "$gpx_master_mysql_user" == "" || "$gpx_master_mysql_pass" == "" ]]
then
    echo "Required MySQL fields were left empty! Exiting."
    exit
fi

# Check for a running FTP server
if [ "$(netstat -an | awk '{print $4,$6}' | grep ':21' | grep LISTEN)" ]
then
        ftp_out="$(netstat -an | grep ':21' | grep LISTEN)"

        echo;echo
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
	if [[ "$(which make 2>&1 | grep 'no make in')" || "$(which gcc 2>&1 | grep 'no gcc in')" ]]
	then
	    yum_cmd="gcc kernel-headers"
	    apt_cmd="build-essential"
	    gentoo_cmd="sys-devel/gcc"
	fi

	# Check MySQL
	if [[ "$(which mysql 2>&1 | grep 'no mysql in')" || "$(which mysql_config 2>&1 | grep 'no mysql_config in')" ]]
	then
	    yum_cmd=$yum_cmd" mysql mysql-devel"
	    apt_cmd=$apt_cmd" libmysqlclient-dev"
	    gentoo_cmd=$gentoo_cmd"  dev-db/mysql"
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
    echo "ERROR: Unable to install the required packages!  Please make sure the GCC and MySQL development libraries are installed and try again."
    exit
fi

echo
echo -e "\e[00;32mRequirements passed!  Installing FTP Server ...\e[00m"
echo
sleep 1

##############################################################

# Prepare FTP Server
rm -fr ./gpx_tmp_ftpinstall
mkdir ./gpx_tmp_ftpinstall
cd ./gpx_tmp_ftpinstall

# Only download if needed
if [ ! -f ./gpxpro-ftpd-latest.tar.gz ]
then
	wget http://gamepanelx.com/files/gpxpro-ftpd-latest.tar.gz
fi

if [ ! -f ./gpxpro-ftpd-latest.tar.gz ]
then
	echo "ERROR: Failed to download the latest FTP Server files!  Exiting."
	exit
fi

# Compile FTP Server
tar -zxf gpxpro-ftpd-latest.tar.gz
cd gpxpro-ftpd-latest
./configure --prefix=$gpx_user_home/ftpd --with-puredb --with-extauth --with-throttling --with-ratios --with-virtualhosts --with-peruserlimits --with-everything --with-mysql
sleep 1
make
sleep 1
make install

################

if [ ! -f "$gpx_user_home/ftpd/sbin/pure-ftpd" ]
then
	echo
	echo -e "\e[00;31mERROR: The FTP Server installation failed.  Check the output above for why the FTP installation failed. Exiting.\e[00m"
	exit
fi

################

# Setup MySQL for FTP Server
echo -e "MYSQLSocket             /tmp/mysql.sock
MYSQLServer             $gpx_master_ip
MYSQLPort               $gpx_master_mysql_port
MYSQLUser               $gpx_master_mysql_user
MYSQLPassword           $gpx_master_mysql_pass
MYSQLDatabase           $gpx_master_mysql_db
MYSQLCrypt              md5
MYSQLGetPW              SELECT password FROM users WHERE username='\L' AND active='1' AND perm_ftp='1'
MYSQLGetDir             SELECT CONCAT(p.homedir, '/accounts/\L/') AS userdir FROM network AS n LEFT JOIN network AS p ON n.parentid = p.id OR n.id = p.id WHERE n.ip = '\I' LIMIT 1
MYSQLDefaultUID         $avail_uid
MYSQLDefaultGID         $avail_gid" > $gpx_user_home/ftpd/mysql.conf

################

# Create startup script
echo "#!/bin/bash" > $gpx_user_home/ftpd/start.sh
echo "$gpx_user_home/ftpd/sbin/pure-ftpd -A -B -C 5 -c 150 -E -H -R -x -X -d -j -l mysql:$gpx_user_home/ftpd/mysql.conf" >> $gpx_user_home/ftpd/start.sh
chmod u+x $gpx_user_home/ftpd/start.sh

# Security
chown root: $gpx_user_home/ftpd
chown root: $gpx_user_home/ftpd -R
chmod 600 $gpx_user_home/ftpd
chmod 600 $gpx_user_home/ftpd/mysql.conf

# Start the FTP Server
back_wd=`pwd`
cd $gpx_user_home/ftpd/
./start.sh
cd $back_wd
sleep 2

# Check if server is running
ftp_pid="$(ps -ef | grep 'pure-ftpd (SERVER)' | grep -v grep | awk '{print $2}')"

if [ "$ftp_pid" ]
then
	echo -e "\e[00;32mFTP Server started successfully with PID $ftp_pid! \e[00m"
else
	echo -e "\e[00;31mFTP Server failed to start, no running PID found! \e[00m"
fi

# Test MySQL connection
mysql_test_gpx="$(mysql $gpx_master_mysql_db --connect-timeout=10 -B -e 'SELECT 1' -h$gpx_master_ip -u$gpx_master_mysql_user -p$gpx_master_mysql_pass  2>&1 | grep ERROR)"

if [ "$mysql_test_gpx" ]
then
    # Check for eth0
    if [ "$(ifconfig | grep eth0)" ]
    then
        use_ip="$(ifconfig eth0 | grep 'inet addr' | head -1 | awk '{print $2}' | awk -F':' '{print $2}')"
    # Virtual
    elif [ "$(ifconfig | grep venet0:0)" ]
    then
        use_ip="$(ifconfig venet0:0 | grep 'inet addr' | head -1 | awk '{print $2}' | awk -F':' '{print $2}')"
    # Eth1?
    elif [ "$(ifconfig | grep eth1)" ]
    then
        use_ip="$(ifconfig eth1 | grep 'inet addr' | head -1 | awk '{print $2}' | awk -F':' '{print $2}')"
    # Unknown
    else
        use_ip="UNKNOWN"
    fi

    echo;echo;echo
    echo -e "\e[00;31mThere was a MySQL connection test problem:\e[00m"
    echo "$mysql_test_gpx"
    echo -e "\e[00;31mYour clients wont be able to use FTP until MySQL permissions are granted! "
    echo "http://gamepanelx.com/docs/index.php?title=Remote_Server_Installation#Master_Database_Privileges"
    echo
    echo "You will need to run the following SQL query as root:"
    echo
    echo "GRANT ALL ON $gpx_master_mysql_db.* TO '$gpx_master_mysql_user'@'$use_ip' IDENTIFIED BY '$gpx_master_mysql_pass';"
    echo "FLUSH PRIVILEGES;"
    echo
    echo -e "Before running that, make sure the IP Address listed in the query is correct for this server! \e[00m"
else
    echo;echo;echo
    echo -e "\e[00;32mMySQL test successfully connected to the remote database! \e[00m"
fi

################

echo
echo
echo
echo
echo -e "\e[00;32mFinished Installing the FTP Server.\e[00m"
echo
