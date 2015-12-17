#!/bin/bash

# Modify this line for the wanted MySQL password
MYSQL_PASS="password"
# openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'

USER="500"
SUPERUSER="0"

sudo -u ${USER} echo -e "Installing docker-compose from GitHub Latest release..." \
\
&& sudo -u ${SUPERUSER} mkdir -p /opt/bin \
&& sudo -u ${SUPERUSER} curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /opt/bin/docker-compose \
&& sudo -u ${SUPERUSER} chmod +x /opt/bin/docker-compose \
&& sudo -u ${USER} echo -e "docker-compose installed, verifying..." \
&& sudo -u ${USER} docker-compose -v \
\
&& sudo -u ${USER} echo -e "Creating folder structure..." \
&& sudo -u ${USER} mkdir -p ~/mysql ~/sqlbackup ~/work/lemp ~/www \
\
&& sudo -u ${USER} echo -e "Cloning git repo into \"~/work/lemp\"..." \
&& sudo -u ${USER} git clone https://github.com/DJviolin/LEMP.git ~/work/lemp \
\
&& sudo -u ${USER} echo -e "Showing working directory..." \
&& sudo -u ${USER} ls -al ~/work/lemp \
\
&& sudo -u ${USER} echo -e "Starting docker images and containers generation..." \
&& sudo -u ${USER} echo -e "\
# Set MySQL Root Password\n\
MYSQL_ROOT_PASSWORD=${MYSQL_PASS}" > ~/work/lemp/mariadb/mariadb.env \
&& sudo -u ${USER} cat ~/work/lemp/mariadb/mariadb.env \
#&& sudo -u ${USER} docker-compose build ~/work/lemp \
\
&& sudo -u ${USER} echo -e "LEMP stack has built...\nRun the service with ./service-start.sh command." \
&& sudo -u ${USER} echo -e "All done! Exiting..."
