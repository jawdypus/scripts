#!/bin/bash

if [[ $EUID -ne 0 ]]
then
    echo "$(tput setaf 1)$(tput bold)This script must be run as root$(tput setaf 7)" 1>&2
    exit 1
fi

echo -e "\n$(tput setaf 2)$(tput bold)UPDATING$(tput setaf 7)"
apt-get update
atp-get upgrade -y

#
# Installing pacages
#
pacages=("nginx" "mysql-server" "mysql-client" "php" "php-fpm" "php-mysql" "phpmyadmin" "aptitude")
len=${#pacages[@]}

echo -e "\n$(tput setaf 2)$(tput bold)INSTALING PACAGES$(tput setaf 7)"

for (( i=0; i<len; i++ ))
do
	apt-get install ${pacages[$i]} -y
done

#
# Starting services
#
serv=("nginx" "mysql" "php7.4-fpm")
len=${#serv[@]}

echo -e "\n$(tput setaf 2)$(tput bold)STARTING SERVICES$(tput setaf 7)\n"

for (( i=0; i<len; i++ ))
do
    systemctl enable --now ${serv[$i]} &> /dev/null
    echo "${serv[$i]} started and enabled"
done

echo -e "\n$(tput setaf 2)$(tput bold)FIXIN' CONFIGS$(tput setaf 7)"
# Settin' a better default config
rm /etc/nginx/sites-available/default
cp configs/default /etc/nginx/sites-available/
rm /etc/php/7.4/fpm/php.ini
cp configs/php.ini /etc/php/7.4/fpm/

# Movin' some files to website dir
cp configs/info.php /var/www/html/
rm /var/www/html/index.html
ln -s /usr/share/phpmyadmin /var/www/html

systemctl reload nginx
systemctl reload php7.4-fpm	

echo -e "\n$(tput setaf 2)$(tput bold)BASIC SETUP DONE$(tput setaf 7)\n\n"

#
# MySql basic setup
#
read -r -p "Do you want to automaticaly setup mysql? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]
    then
        echo "Can't find expect. Trying install it..."
        aptitude -y install expect &> /dev/null
    fi
    chmod +x additional-scripts/mysql_secure_installation.sh
    ./additional-scripts/mysql_secure_installation.sh
fi

#
# MySql user setup
#
read -r -p "Do you want to add user? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]
    then
        echo "Can't find expect. Trying install it..."
        aptitude -y install expect &> /dev/null
    fi
    chmod +x additional-scripts/create_new_user.sh
    ./additional-scripts/create_new_user.sh
fi

echo -e "\n$(tput setaf 2)$(tput bold)ALL DONE$(tput setaf 7)\n"

exit 0
