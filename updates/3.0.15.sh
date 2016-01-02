#!/bin/bash
#
# GamePanelX
# Remote Scripts v3.0.15
#
# Update Script
#
# Licensed under the GPL (GNU General Public License V3)
#
has_old_dirs=

# Move ip:port accounts directories to ip.port, to fix games that dont like that : character
for user in /usr/local/gpx/users/*; do
  for gamedir in $user/*; do
    # Only dirs names ip:port
    if [ "$(echo $gamedir | grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\:[0-9]+')" ]; then
      new_dir=$(echo $gamedir | sed 's/\:/\./g')

      echo "Found dir $gamedir, moving to $new_dir ..."
      mv -v $gamedir $new_dir
      has_old_dirs="y"
    fi
    #echo "Game Dir: $gamedir"
  done
done

if [ -z "$has_old_dirs" ]; then
  echo "No directories to update.  Exiting."
  exit 1
else
  echo
  echo "..done."
fi
