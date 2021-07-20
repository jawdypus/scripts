#!/bin/bash

#
# Check the bash shell script is being run by root
#
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Check is expect package installed
#
if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Can't find expect. Trying install it..."
    aptitude -y install expect &> /dev/null

fi

#
# Input daata about new user
#
echo -n -e "Enter your current mysql root password: "; read -s root_passwd
echo -n -e "\nEnter username: "; read username
echo -n -e "Enter host: "; read host
echo -n -e "Enter password: "; read -s password

echo -e "\n\nThis might take a while... \n"

USER=$(expect -c "

set timeout 3
spawn mysql -u root -p

expect \"Enter password: \"
send \"$root_passwd\r\"

expect \"mysql>\"
send \"create user $username@'$host' identified by '$password';\r\"

expect \"mysql>\"
send \"grant all privileges on *.* to $username@'$host';\r\"

expect \"mysql>\"
send \"flush privileges;\r\"

expect eof
")

echo "$USER" &> /dev/null

exit 0
