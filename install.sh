#!/bin/bash

# set -e making the commands if they were like &&
set -e

read -e -p "Enter the path to the install dir (or hit enter for default path): " -i "$HOME/server" INSTALL_DIR
echo $INSTALL_DIR

echo -e "\nCreating folder structure:"
mkdir -p $INSTALL_DIR/mysql $INSTALL_DIR/sqlbackup $INSTALL_DIR/lemp $INSTALL_DIR/www
echo -e "\
  $INSTALL_DIR/mysql\n\
  $INSTALL_DIR/sqlbackup\n\
  $INSTALL_DIR/lemp\n\
  $INSTALL_DIR/www\n\
Done!"

if test "$(ls -A "$INSTALL_DIR/lemp")"; then
  echo -e "\n\"$INSTALL_DIR/lemp\" directory is not empty!\nYou have to remove everything from here to continue!\nRemove \"$INSTALL_DIR/lemp\" directory (y/n)?"
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    rm -rf $INSTALL_DIR/lemp/
    echo -e "\"$INSTALL_DIR/lemp\" is removed, continue installation...";
    mkdir -p $INSTALL_DIR/lemp
    echo -e "\nCloning git repo into \"$INSTALL_DIR/lemp\":"
    cd $INSTALL_DIR/lemp
    git clone https://github.com/DJviolin/LEMP.git $INSTALL_DIR/lemp
    echo -e "\nShowing working directory..."
    ls -al $INSTALL_DIR/lemp
  else
    echo -e "\nScript aborted to run\nExiting..."; exit 1;
  fi
else
  echo -e "\nCloning git repo into \"$INSTALL_DIR/lemp\":"
  cd $INSTALL_DIR/lemp
  git clone https://github.com/DJviolin/LEMP.git $INSTALL_DIR/lemp
  echo -e "\nShowing working directory..."
  ls -al $INSTALL_DIR/lemp
fi

echo -e "\nCreating additional files for the stack:"

# bash variables in Here-Doc, don't use 'EOF'
# http://stackoverflow.com/questions/4937792/using-variables-inside-a-bash-heredoc
# http://stackoverflow.com/questions/17578073/ssh-and-environment-variables-remote-and-local

echo -e "\nCreating: $INSTALL_DIR/lemp/docker-compose.yml\n"
cat <<EOF > $INSTALL_DIR/lemp/docker-compose.yml
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
ssh:
  build: ./ssh
  container_name: lemp_ssh
  ports:
    - "2222:22"
  volumes:
    - $INSTALL_DIR/www/:/var/www/:rw
    - $HOME/.ssh/:/root/.ssh/:ro
phpmyadmin:
  build: ./phpmyadmin
  container_name: lemp_phpmyadmin
  links:
    - ssh
  volumes:
    - /var/www/phpmyadmin
    - ./phpmyadmin/var/www/phpmyadmin/config.inc.php:/var/www/phpmyadmin/config.inc.php:ro
mariadb:
  build: ./mariadb
  container_name: lemp_mariadb
  env_file: ./mariadb/mariadb.env
  links:
    - ssh
  volumes:
    - /var/run/mysqld
    - $INSTALL_DIR/mysql/:/var/lib/mysql/:rw
    - ./mariadb/etc/mysql/my.cnf:/etc/mysql/my.cnf:ro
php:
  build: ./php
  container_name: lemp_php
  links:
    - ssh
  volumes:
    - /var/run/php-fpm
    - ./php/usr/local/php7/etc/php-fpm.conf:/usr/local/php7/etc/php-fpm.conf:ro
    - ./php/usr/local/php7/etc/php.ini:/usr/local/php7/etc/php.ini:ro
    - ./php/usr/local/php7/etc/php-fpm.d/www.conf:/usr/local/php7/etc/php-fpm.d/www.conf:ro
  volumes_from:
    - ssh
    - mariadb
    - phpmyadmin
nginx:
  build: ./nginx
  container_name: lemp_nginx
  links:
    - ssh
  ports:
    - "8080:80"
    - "8081:443"
  volumes:
    - ./nginx/etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    - ./nginx/etc/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
    - ./nginx/etc/nginx/conf.d/php.conf:/etc/nginx/conf.d/php.conf:ro
    - ./nginx/etc/nginx/conf.d/cert/:/etc/nginx/conf.d/cert/:ro
  volumes_from:
    - php
EOF
cat $INSTALL_DIR/lemp/docker-compose.yml

echo -e "\nCreating: $INSTALL_DIR/lemp/lemp.service\n"
cat <<EOF > $INSTALL_DIR/lemp/lemp.service
[Unit]
Description=LEMP
After=etcd.service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
#KillMode=none
ExecStartPre=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql $INSTALL_DIR/sqlbackup
ExecStartPre=-/bin/bash -c '/usr/bin/tar -zcvf $INSTALL_DIR/sqlbackup/sqlbackup_\$\$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStartPre.tar.gz $INSTALL_DIR/sqlbackup/mysql --remove-files'
ExecStartPre=-/opt/bin/docker-compose --file $INSTALL_DIR/lemp/docker-compose.yml kill
ExecStartPre=-/opt/bin/docker-compose --file $INSTALL_DIR/lemp/docker-compose.yml rm --force
ExecStart=/opt/bin/docker-compose --file $INSTALL_DIR/lemp/docker-compose.yml up -d --force-recreate
ExecStartPost=/usr/bin/etcdctl set /LEMP Running
ExecStop=/opt/bin/docker-compose --file $INSTALL_DIR/lemp/docker-compose.yml stop
ExecStopPost=/usr/bin/etcdctl rm /LEMP
ExecStopPost=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql $INSTALL_DIR/sqlbackup
ExecStopPost=-/bin/bash -c 'tar -zcvf $INSTALL_DIR/sqlbackup/sqlbackup_\$\$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStopPost.tar.gz $INSTALL_DIR/sqlbackup/mysql --remove-files'
Restart=always
#RestartSec=30s

[X-Fleet]
Conflicts=lemp.service
EOF
cat $INSTALL_DIR/lemp/lemp.service

echo -e "\n\
# Set MySQL Root Password\n\
MYSQL_ROOT_PASSWORD=`openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'`" > $INSTALL_DIR/lemp/mariadb/mariadb.env > $INSTALL_DIR/mysql-root-password.txt
cat $INSTALL_DIR/mysql-root-password.txt

cd $HOME

echo -e "\n
LEMP stack has successfully built!\n\n\
Run docker-compose with:\n\
  $ docker-compose --file $INSTALL_DIR/lemp/docker-compose.yml build\n\
Run the systemd service with:\n\
  $ cd $INSTALL_DIR/lemp && ./service-start.sh\n\
Stop the systemd service with:\n\
  $ cd $INSTALL_DIR/lemp && ./service-stop.sh"
echo -e "\nAll done! Exiting..."
