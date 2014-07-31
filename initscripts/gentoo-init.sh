#!/sbin/runscript
# GamePanelX Remote

depend() {
	need net
}

start() {
	ebegin "Starting GamePanelX Remote"
	start-stop-daemon --start --quiet --oknodo --pid /usr/local/gpx/gpxmanager.pid --exec /usr/local/gpx/bin/daemon-start
	eend $?
}

stop() {
	ebegin "Stopping GamePanelX Remote"
	start-stop-daemon --start --quiet --oknodo --pid /usr/local/gpx/gpxmanager.pid --exec /usr/local/gpx/bin/daemon-stop
	eend $?
}
