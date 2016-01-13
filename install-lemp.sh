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
    echo -e "\nShowing working directory..."
    ls -al $REPO_DIR
  else
    echo -e "\nScript aborted to run\nExiting..."; exit 1;
  fi
else
  echo -e "\nCloning git repo into \"$REPO_DIR\":"
  cd $REPO_DIR
  git clone https://github.com/DJviolin/LEMP.git $REPO_DIR
  echo -e "Showing working directory..."
  ls -al $REPO_DIR
fi

echo -e "\nCreating additional files for the stack:"

echo -e "\nGenerating MySQL root password!\nBe advised that auto-generating password NOT THE FIRST TIME + already having a MySQL database can CAUSE MISCONFIGURATION errors with already created databases!\nSo the recommended method is to CHOOSE THE NO OPTION and use one password and just STICK WITH IT!\nChoose Yes to auto-generate or No to type it manually (y/n)?"
read answer
if echo "$answer" | grep -iq "^y" ;then
  MYSQL_GENPASS=($echo -e MYSQL_ROOT_PASSWORD=`openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'`)
  #echo -e "MYSQL_ROOT_PASSWORD=`openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'`" > "${MYSQL_GENPASS}"
  #cat $REPO_DIR/mariadb/mariadb.env > $DB_DIR-root-password.txt
  #cat $DB_DIR-root-password.txt
else
  read -e -p "Enter the MySQL root password: " MYSQL_PASS
  MYSQL_GENPASS=$(echo -e MYSQL_ROOT_PASSWORD=$MYSQL_PASS)
  #echo -e "MYSQL_ROOT_PASSWORD=$MYSQL_PASS" > "${MYSQL_GENPASS}"
  #cat $REPO_DIR/mariadb/mariadb.env > $DB_DIR-root-password.txt
  #cat $DB_DIR-root-password.txt
fi

echo -e "\nYour MySQL password ENV variable is: " $MYSQL_GENPASS

# bash variables in Here-Doc, don't use 'EOF'
# http://stackoverflow.com/questions/4937792/using-variables-inside-a-bash-heredoc
# http://stackoverflow.com/questions/17578073/ssh-and-environment-variables-remote-and-local

echo -e "\nCreating: $REPO_DIR/docker-compose.yml\n"
cat <<EOF > $REPO_DIR/docker-compose.yml
cadvisor:
  image: google/cadvisor:latest
  container_name: lemp_cadvisor
  ports:
    - "8082:8080"
  volumes:
    - "/:/rootfs:ro"
    - "/var/run:/var/run:rw"
    - "/sys:/sys:ro"
    - "/var/lib/docker/:/var/lib/docker:ro"
base:
  build: ./base
  container_name: lemp_base
  volumes:
  - $WWW_DIR/:/var/www/:rw
phpmyadmin:
  build: ./phpmyadmin
  container_name: lemp_phpmyadmin
  links:
    - base
  volumes:
    - /var/www/phpmyadmin
    - ./phpmyadmin/var/www/phpmyadmin/config.inc.php:/var/www/phpmyadmin/config.inc.php:rw
mariadb:
  build: ./mariadb
  container_name: lemp_mariadb
  #env_file: ./mariadb/mariadb.env
  environment:
    - $MYSQL_GENPASS
  links:
    - base
  volumes:
    - /var/run/mysqld
    - $DB_DIR/:/var/lib/mysql/:rw
    - ./mariadb/etc/mysql/my.cnf:/etc/mysql/my.cnf:ro
php:
  build: ./php
  container_name: lemp_php
  links:
    - base
  volumes:
    - /var/run/php-fpm
    - ./php/usr/local/php7/etc/php-fpm.conf:/usr/local/php7/etc/php-fpm.conf:ro
    - ./php/usr/local/php7/etc/php.ini:/usr/local/php7/etc/php.ini:ro
    - ./php/usr/local/php7/etc/php-fpm.d/www.conf:/usr/local/php7/etc/php-fpm.d/www.conf:ro
  volumes_from:
    - base
    - phpmyadmin
    - mariadb
nginx:
  build: ./nginx
  container_name: lemp_nginx
  links:
    - base
  ports:
    - "8080:80"
    - "8081:443"
  volumes:
    - /var/cache/nginx
    - ./nginx/etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  volumes_from:
    - php
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
  $ cd $REPO_DIR && chmod +x service-start.sh && ./service-start.sh\n\
Stop the systemd service with:\n\
  $ cd $REPO_DIR && chmod +x service-stop.sh && ./service-stop.sh"
echo -e "\nAll done! Exiting..."
