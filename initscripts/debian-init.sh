# gpx - gpx job file

description "GamePanelX Remote daemon"
author "Ryan Gehrig <ryan@gamepanelx.com>"
start on runlevel [2345]
stop on runlevel [016]
respawn
expect fork
exec ./debian-start
pre-stop ./debian-stop
