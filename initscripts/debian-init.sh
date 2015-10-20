#!/bin/bash
### BEGIN INIT INFO
# Provides:          gpx
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start GamePanelX Remote at boot time
# Description:       GamePanelX Remote
### END INIT INFO

set -e

# /etc/init.d/gpx: start and stop the GamePanelX Remote daemon(s)

test -x /usr/local/gpx/bin/GPXManager || exit 0
umask 022
. /lib/lsb/init-functions

case "$1" in
  start)
        log_daemon_msg "Starting GamePanelX Remote" "gpx" || true
        if start-stop-daemon --start --quiet --oknodo --pid /usr/local/gpx/gpxmanager.pid --exec /usr/local/gpx/bin/daemon-start; then
            log_end_msg 0 || true
        else
            log_end_msg 1 || true
        fi
        ;;
  stop)
        log_daemon_msg "Stopping GamePanelX Remote" "gpx" || true
        if start-stop-daemon --start --quiet --oknodo --pid /usr/local/gpx/gpxmanager.pid --exec /usr/local/gpx/bin/daemon-stop; then
            log_end_msg 0 || true
        else
            log_end_msg 1 || true
        fi
        ;;
  restart)
        log_daemon_msg "Restarting GamePanelX Remote" "gpx" || true
        start-stop-daemon --start --quiet --oknodo --retry 30 --pid /usr/local/gpx/gpxmanager.pid --exec /usr/local/gpx/bin/daemon-stop
        if start-stop-daemon --start --quiet --oknodo --exec /usr/local/gpx/bin/daemon-start; then
            log_end_msg 0 || true
        else
            log_end_msg 1 || true
        fi
        ;;
  *)
        log_action_msg "Usage: /etc/init.d/gpx {start|stop|restart}" || true
        exit 1
esac
exit 0
