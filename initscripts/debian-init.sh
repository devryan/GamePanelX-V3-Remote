### BEGIN INIT INFO
# Provides:          gpx
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start GamePanelX Remote at boot time
# Description:       GamePanelX Remote
### END INIT INFO

description "GamePanelX Remote daemon"
author "Ryan Gehrig <ryan@gamepanelx.com>"
start on runlevel [2345]
stop on runlevel [016]
respawn
expect fork
exec /usr/local/gpx/bin/debian-start
pre-stop /usr/local/gpx/bin/debian-stop
