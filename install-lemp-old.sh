#!/bin/bash

# set -e making the commands if they were like &&
set -e

read -e -p "Enter the path to the install dir (or hit enter for default path): " -i "$HOME/server-lemp" INSTALL_DIR
echo $INSTALL_DIR
DB_DIR=$INSTALL_DIR/mariadb
DBBAK_DIR=$INSTALL_DIR/dbbackup
REPO_DIR=$INSTALL_DIR/lemp
WWW_DIR=$INSTALL_DIR/www

echo -e "\nCreating folder structure:"
mkdir -p $DB_DIR $DBBAK_DIR $REPO_DIR $WWW_DIR
echo -e "\
  $DB_DIR\n\
  $DBBAK_DIR\n\
  $REPO_DIR\n\
  $WWW_DIR\n\
Done!"

if test "$(ls -A "$REPO_DIR")"; then
  echo -e "\n\"$REPO_DIR\" directory is not empty!\nYou have to remove everything from here to continue!\nRemove \"$REPO_DIR\" directory (y/n)?"
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    rm -rf $REPO_DIR/
    echo -e "\"$REPO_DIR\" is removed, continue installation...";
    mkdir -p $REPO_DIR
    echo -e "\nCloning git repo into \"$REPO_DIR\":"
    cd $REPO_DIR
    git clone https://github.com/DJviolin/LEMP.git $REPO_DIR
    chmod +x $REPO_DIR/service-start.sh $REPO_DIR/service-stop.sh
    echo -e "\nShowing working directory..."
    ls -al $REPO_DIR
  else
    echo -e "\nScript aborted to run\nExiting..."; exit 1;
  fi
else
  echo -e "\nCloning git repo into \"$REPO_DIR\":"
  cd $REPO_DIR
  git clone https://github.com/DJviolin/LEMP.git $REPO_DIR
  chmod +x $REPO_DIR/service-start.sh $REPO_DIR/service-stop.sh
  echo -e "Showing working directory..."
  ls -al $REPO_DIR
fi

echo -e "\nCreating additional files for the stack:"

echo -e "\nGenerating MySQL root password:"
read -e -p "Type here: " MYSQL_PASS
MYSQL_GENERATED_PASS=$(echo -e MYSQL_ROOT_PASSWORD=$MYSQL_PASS)

echo -e "\nYour MySQL password ENV variable is:" $MYSQL_GENERATED_PASS

# bash variables in Here-Doc, don't use 'EOF'
# http://stackoverflow.com/questions/4937792/using-variables-inside-a-bash-heredoc
# http://stackoverflow.com/questions/17578073/ssh-and-environment-variables-remote-and-local

echo -e "\nCreating: $REPO_DIR/docker-compose.yml\n"
cat <<EOF > $REPO_DIR/docker-compose.yml
version: 2

services:
  cadvisor:
    image: google/cadvisor:latest
    container_name: lemp_cadvisor
    ports:
      - "8080:8080"
    volumes:
      - "/:/rootfs:ro"
      - "/var/run:/var/run:rw"
      - "/sys:/sys:ro"
      - "/var/lib/docker/:/var/lib/docker:ro"
  base:
    build: ./base
    container_name: lemp_base
    volumes:
      - /root/lemp_base_volume
  www:
    image: lemp_base
    container_name: lemp_www
    volumes_from:
      - base
    volumes:
      - $WWW_DIR:/var/www:rw
  phpmyadmin:
    build: ./phpmyadmin
    container_name: lemp_phpmyadmin
    volumes_from:
      - base
    volumes:
      - /var/www/phpmyadmin
      - ./phpmyadmin/var/www/phpmyadmin/config.inc.php:/var/www/phpmyadmin/config.inc.php:rw
  ffmpeg:
    build: ./ffmpeg
    container_name: lemp_ffmpeg
    volumes_from:
      - base
    volumes:
      - /usr/ffmpeg
  mariadb:
    build: ./mariadb
    container_name: lemp_mariadb
    environment:
      - $MYSQL_GENERATED_PASS
    volumes_from:
      - base
    volumes:
      - /var/run/mysqld
      - $DB_DIR:/var/lib/mysql:rw
      - ./mariadb/etc/mysql/my.cnf:/etc/mysql/my.cnf:ro
  php:
    build: ./php
    container_name: lemp_php
    volumes_from:
      - www
      - phpmyadmin
      - ffmpeg
      - mariadb
    volumes:
      - /var/run/php-fpm
      - ./php/usr/local/php7/etc/php-fpm.conf:/usr/local/php7/etc/php-fpm.conf:ro
      - ./php/usr/local/php7/etc/php.ini:/usr/local/php7/etc/php.ini:ro
      - ./php/usr/local/php7/etc/php-fpm.d/www.conf:/usr/local/php7/etc/php-fpm.d/www.conf:ro
      - ./php/etc/cron.d:/etc/cron.d:ro
  nginx:
    build: ./nginx
    container_name: lemp_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes_from:
      - php
    volumes:
      - /var/cache/nginx
      - ./nginx/etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro

volumes:
  www:
    driver: default

# Changing the settings of the app-wide default network
#networks:
#  default:
    # Use the overlay driver for multi-host communication
#    driver: overlay
EOF
cat $REPO_DIR/docker-compose.yml

echo -e "\nCreating: $REPO_DIR/lemp.service\n"
cat <<EOF > $REPO_DIR/lemp.service
[Unit]
Description=LEMP
After=etcd.service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
#KillMode=none
ExecStartPre=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql $DBBAK_DIR
ExecStartPre=-/bin/bash -c '/usr/bin/tar -zcvf $DBBAK_DIR/sqlbackup_\$\$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStartPre.tar.gz $DBBAK_DIR/mysql --remove-files'
ExecStartPre=-/opt/bin/docker-compose --file $REPO_DIR/docker-compose.yml kill
ExecStartPre=-/opt/bin/docker-compose --file $REPO_DIR/docker-compose.yml rm --force
ExecStart=/opt/bin/docker-compose --file $REPO_DIR/docker-compose.yml up --force-recreate
ExecStartPost=/usr/bin/etcdctl set /LEMP Running
ExecStop=/opt/bin/docker-compose --file $REPO_DIR/docker-compose.yml stop
ExecStopPost=/usr/bin/etcdctl rm /LEMP
ExecStopPost=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql $DBBAK_DIR
ExecStopPost=-/bin/bash -c 'tar -zcvf $DBBAK_DIR/sqlbackup_\$\$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStopPost.tar.gz $DBBAK_DIR/mysql --remove-files'
Restart=always
#RestartSec=30s

[X-Fleet]
Conflicts=lemp.service
EOF
cat $REPO_DIR/lemp.service

cd $HOME

echo -e "\n
LEMP stack has successfully built!\n\n\
Run docker-compose with:\n\
  $ docker-compose --file $REPO_DIR/docker-compose.yml build\n\
Run the systemd service with:\n\
  $ cd $REPO_DIR && ./service-start.sh\n\
Stop the systemd service with:\n\
  $ cd $REPO_DIR && ./service-stop.sh"
echo -e "\nAll done! Exiting..."
