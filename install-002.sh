#!/bin/bash

# Modify this line for the wanted MySQL password
MYSQL_PASS="password"
# openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'

#USER="500"
#SUPERUSER="0"

echo -e "Installing docker-compose from GitHub Latest release..." \
\
&& sudo mkdir -p /opt/bin \
&& sudo curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /opt/bin/docker-compose \
&& sudo chmod +x /opt/bin/docker-compose \
&& echo -e "docker-compose installed, verifying..." \
&& docker-compose -v \
\
&& echo -e "Creating folder structure..." \
&& mkdir -p ~/mysql ~/sqlbackup ~/work/lemp ~/www \
\
&& echo -e "Cloning git repo into \"~/work/lemp\"..." \
&& git clone https://github.com/DJviolin/LEMP.git ~/work/lemp \
\
&& echo -e "Showing working directory..." \
&& ls -al ~/work/lemp \
\
&& echo -e "Starting docker images and containers generation..." \
&& echo -e "\
# Set MySQL Root Password\n\
MYSQL_ROOT_PASSWORD=${MYSQL_PASS}" > ~/work/lemp/mariadb/mariadb.env \
&& cat ~/work/lemp/mariadb/mariadb.env \
\
&& echo -e "LEMP stack has built...\nRun the service with ./service-start.sh command." \
&& echo -e "All done! Exiting..."
