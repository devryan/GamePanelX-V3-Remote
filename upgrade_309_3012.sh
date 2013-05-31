#!/bin/bash
# Upgrade GamePanelX Remote <= 3.0.9 to 3.0.12
# Ryan Gehrig
#
echo 'Welcome to the GamePanelX Remote upgrade script!'
echo
read -p "Old GamePanelX System User? " gpxuser
usr_exist="$(grep "^$gpxuser:" /etc/passwd)"

if [[ "$gpxuser" == "" || "$usr_exist" == "" ]]; then
    echo "Empty user or that user account does not exist.  Exiting."
    exit
fi

# Ensure old user had a gpx setup
if [[ ! -d /home/$gpxuser/accounts || ! -d /home/$gpxuser/templates ]]; then
    echo "There does not appear to be a GamePanelX accounts or templates directory for that user ($gpxuser), exiting."
    exit
fi

# They must install 3.0.12 first (since it won't conflict, it's best to have it already done)
if [ ! -d /usr/local/gpx ]; then
    echo "Please install GamePanelX Remote 3.0.12 first, then run this script!"
    exit
fi

for gpxnew_user in $(ls /home/$gpxuser/accounts); do
    # Generate random password (they can change it later)
    rand_pass=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

    # Create system user
    useradd -m -p "$rand_pass" -d /usr/local/gpx/users/$gpxnew_user -s /bin/bash -c "GamePanelX User" gpx$gpxnew_user
    gpasswd -a gpx$gpxnew_user $gpxuser
    gpasswd -d gpx$gpxnew_user wheel 2>&1 >> /dev/null

    # Check
    if [ ! -d /usr/local/gpx/users/$gpxnew_user ]; then
        echo "User ($user) account directory (/usr/local/gpx/users/$gpxnew_user) not created!  Exiting."
        exit
    fi

    # Move old files over
    mv /home/$gpxuser/accounts/$gpxnew_user/* /usr/local/gpx/users/$gpxnew_user/
    chown gpx$gpxnew_user: /usr/local/gpx/users/$gpxnew_user -R
done

# Move old templates over
mv /home/$gpxuser/templates/* /usr/local/gpx/templates/

echo
echo
echo 'Successfully upgraded to 3.0.12!'
echo
echo

read -p "Remove old gamepanelx directories? (y/n): " rm_old

if [[ "$rm_old" == "y" || "$rm_old" == "yes" || "$rm_old" == "Y" || "$rm_old" == "YES" ]]; then
    rm -fr /home/$gpxuser/*
fi

echo
echo
echo 'Complete!'

