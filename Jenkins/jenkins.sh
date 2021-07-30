#!/bin/bash

if [[ $EUID -ne 0 ]]
then
    echo "$(tput setaf 1)$(tput bold)This script must be run as root$(tput setaf 7)" 1>&2
    exit 1
fi

echo -e "\n$(tput setaf 2)$(tput bold)UPDATING$(tput setaf 7)"
apt-get update

echo -e "\n$(tput setaf 2)$(tput bold)INSTALING JAVA 8$(tput setaf 7)"

apt-get install openjdk-8-jre -y

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -

sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

apt-get update
apt-get install jenkins -y

echo -e "\n$(tput setaf 2)$(tput bold)JENKINS PASSWD$(tput setaf 7)"
cat /var/lib/jenkins/secrets/initialAdminPassword
