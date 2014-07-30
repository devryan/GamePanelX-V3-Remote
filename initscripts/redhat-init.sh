#!/bin/bash
##
# GamePanelX V3
# RedHat/CentOS/Fedora initscript
# chkconfig: 345 55 25
# description: GamePanelX Remote
#
if [ -f /etc/rc.d/init.d/functions ]; then . /etc/rc.d/init.d/functions; fi
serverlog=/usr/local/gpx/logs/servers.log

case "$1" in
start)
        echo -n "Starting GamePanelX Manager:"

	# Start manager
        /usr/local/gpx/bin/GPXManager

	# Start FTP server
	if [ -f /usr/local/gpx/ftpd/start.sh ]; then
		/usr/local/gpx/ftpd/start.sh
	fi

	# Start all previously running game servers
	if [ -d /usr/local/gpx/srv.d ]; then
		for gamesrv in $(ls /usr/local/gpx/srv.d); do
			if [ "$gamesrv" ]; then
				if [ -f /usr/local/gpx/srv.d/$gamesrv ]; then
					this_srvfile=/usr/local/gpx/srv.d/$gamesrv
					srv_user=$(grep '^user\:\ ' $this_srvfile | awk '{print $2}')
					srv_ip=$(grep '^ip\:\ ' $this_srvfile | awk '{print $2}')
					srv_port=$(grep '^port\:\ ' $this_srvfile | awk '{print $2}')
					srv_pid=$(grep '^pid\:\ ' $this_srvfile | awk '{print $2}')
					srv_workingdir=$(grep '^workingdir\:\ ' $this_srvfile | awk '{print $2}')
					srv_cmd=$(grep '^gpxcmd\:\ ' $this_srvfile | awk '{$1=""; print $0}')
					srv_taskset=$(grep '^taskset\:\ ' $this_srvfile | awk '{print $2}')

					# Ensure user exists
					if [ "$(grep "^gpx$srv_user:" /etc/passwd)" ]; then
						# Start up gameserver
						echo "$(date) $(hostname) initscript: Starting server $srv_ip:$srv_port for user $srv_user ..." >> $serverlog
						su - gpx$srv_user -c "/usr/local/gpx/bin/Restart -u $srv_user -i $srv_ip -p $srv_port -P \"$srv_pid\" -w \"$srv_workingdir\" -o '$srv_cmd'" >> /dev/null 2>&1 &
					else
						echo "$(date) $(hostname) initscript: Found srv.d/$gamesrv for startup, but user did not exist.  Skipping." >> $serverlog
					fi
				fi
			fi
		done
	fi

        echo_success
        echo
        ;;
stop)
        echo -n "Stopping GamePanelX Manager:"

	# Stop manager
	if [ -f /usr/local/gpx/gpxmanager.pid ]; then
		pid_gpxman=$(cat /usr/local/gpx/gpxmanager.pid)

		if [ -e /proc/$pid_gpxman ]; then
			kill $(cat /usr/local/gpx/gpxmanager.pid)
		fi
	fi

	# Stop FTP server
	if [ -f /usr/local/gpx/ftpd/start.sh ]; then
		if [ "$(ps -ef | grep 'pure-ftpd (SERVER)' | grep -v grep)" ]; then
			killall pure-ftpd
		fi
	fi

	# Stop all previously running game servers
	if [ -d /usr/local/gpx/srv.d ]; then
                for gamesrv in $(ls /usr/local/gpx/srv.d); do
                        if [ "$gamesrv" ]; then
                                if [ -f /usr/local/gpx/srv.d/$gamesrv ]; then
                                        this_srvfile=/usr/local/gpx/srv.d/$gamesrv
                                        srv_user=$(grep '^user\:\ ' $this_srvfile | awk '{print $2}')
                                        srv_ip=$(grep '^ip\:\ ' $this_srvfile | awk '{print $2}')
                                        srv_port=$(grep '^port\:\ ' $this_srvfile | awk '{print $2}')
                                        srv_pid=$(grep '^pid\:\ ' $this_srvfile | awk '{print $2}')
                                        srv_workingdir=$(grep '^workingdir\:\ ' $this_srvfile | awk '{print $2}')
                                        srv_cmd=$(grep '^gpxcmd\:\ ' $this_srvfile | awk '{$1=""; print $0}')
                                        srv_taskset=$(grep '^taskset\:\ ' $this_srvfile | awk '{print $2}')

                                        # Ensure user exists
                                        if [ "$(grep "^gpx$srv_user:" /etc/passwd)" ]; then
						# Use the proper current script PID
						if [ "$BASHPID" ]
                                                then
                                                    script_pid=$BASHPID
                                                else
                                                    script_pid=$$
                                                fi

						# Stop gameserver
                                                echo "$(date) $(hostname) initscript: Stopping server $srv_ip:$srv_port for user $srv_user ..." >> $serverlog
                                                su - gpx$srv_user -c "/usr/local/gpx/bin/Stop -u $srv_user -i $srv_ip -p $srv_port -r $script_pid -n yes" >> /dev/null 2>&1 &
                                        else
                                                echo "$(date) $(hostname) initscript: Found srv.d/$gamesrv file, but user did not exist.  Skipping." >> $serverlog
                                        fi
                                fi
                        fi
                done
        fi

        echo_success
        echo
        ;;
restart)
        $0 stop
        $0 start
        ;;
*)
        echo "usage: $0 [start|stop|restart|condrestart]"
esac
exit 0
