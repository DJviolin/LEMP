#!/bin/bash

# set -e making the commands if they were like &&
set -e

echo -e "Installing docker-compose from GitHub Latest release..."
mkdir -p ~/bin
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > ~/bin/docker-compose
chmod +x ~/bin/docker-compose
export PATH="~/bin:$PATH"
echo -e "docker-compose installed, verifying:"
docker-compose -v

echo -e "Creating folder structure..."
mkdir -p ~/mysql ~/sqlbackup ~/work/lemp ~/www

echo -e "Cloning git repo into \"~/work/lemp\"..."
git clone https://github.com/DJviolin/LEMP.git ~/work/lemp
echo -e "Showing working directory..."
ls -al ~/work/lemp

echo -e "Starting docker images and containers generation..."
echo -e "\
# Set MySQL Root Password\n\
MYSQL_ROOT_PASSWORD=`openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'`" > ~/work/lemp/mariadb/mariadb.env
cat ~/work/lemp/mariadb/mariadb.env
#docker-compose build ~/work/lemp

echo -e "LEMP stack has built...\nRun the service with ./service-start.sh command." \
echo -e "All done! Exiting..."
