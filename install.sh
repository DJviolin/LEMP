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
mkdir -p ~/server/mysql ~/server/sqlbackup ~/server/lemp ~/server/www

echo -e "Cloning git repo into \"~/work/lemp\"..."
git clone https://github.com/DJviolin/LEMP.git ~/server/lemp
echo -e "Showing working directory..."
ls -al ~/server/lemp

echo -e "Creating additional files for the stack..."
echo -e "\
# Set MySQL Root Password\n\
MYSQL_ROOT_PASSWORD=`openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'`" > ~/work/lemp/mariadb/mariadb.env > ~/work/mysqlpass.txt
cat ~/server/mysqlpass.txt

echo -e "Starting docker-compose\nCreating images and containers..."
#docker-compose build ~/server/lemp

echo -e "LEMP stack has built...\nRun the service with ./service-start.sh command." \
echo -e "All done! Exiting..."
