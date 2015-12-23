#!/bin/bash

# set -e making the commands if they were like &&
set -e

read -e -p "Enter the path to the install dir (or hit enter for default path): " -i "$HOME/server" INSTALL_DIR
echo $INSTALL_DIR

echo -e "\nAre you sure you want to continue the installation of the DJviolin/LEMP stack (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo "Continue installation...";
else
    echo "Exiting..."; exit 1;
fi

echo -e "\nInstalling docker-compose from GitHub Master release channel:\n(For non-Nightly, Stable releases please visit their official GitHub page)"
if hash docker-compose 2>/dev/null; then
  echo -e "\nDocker-compose already installed on your system, skipping step & verifying version:"
  echo -n "  "; docker-compose -v
  echo -e "Install path:\n  `which docker-compose`"
else
  mkdir -p $HOME/bin
    cp $HOME/.bashrc $HOME/.bashrc.new
    rm $HOME/.bashrc
    mv $HOME/.bashrc.new $HOME/.bashrc
    echo -n 'export PATH="$PATH:$HOME/bin"' >> $HOME/.bashrc
    # Refreshing env variables, without replacing the current bash process, but this script stays in it's own process, so verify will not work here
    source $HOME/.bashrc
    # Fixes that this script will also get the env refresh
    #
  curl -L https://dl.bintray.com/docker-compose/master/docker-compose-`uname -s`-`uname -m` > $HOME/bin/docker-compose
  chmod +x $HOME/bin/docker-compose
  echo -e "\nDocker-compose installed, verifying version:"
  echo -n "  "; docker-compose -v
  echo -e "Install path:\n  `which docker-compose`"
fi

echo -e "\nCreating folder structure:"
mkdir -p $INSTALL_DIR/mysql $INSTALL_DIR/sqlbackup $INSTALL_DIR/lemp $INSTALL_DIR/www
echo -e "\
  $INSTALL_DIR/mysql\n\
  $INSTALL_DIR/sqlbackup\n\
  $INSTALL_DIR/lemp\n\
  $INSTALL_DIR/www\n\
Done!"

if test "$(ls -A "$INSTALL_DIR/lemp")"; then
  echo -e "\n$INSTALL_DIR/lemp directory is not empty!\n\nYou have to remove everything here with\n\"$ rm -rf $INSTALL_DIR/lemp/\" command and try again to run this script!\n\nScript failed to run. Exiting..."
  exit 1
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

echo -e "\nLEMP stack has successfully built!\n\nRun docker-compose with:\n  $ docker-compose build $INSTALL_DIR/lemp\nRun the systemd service with:\n  $ cd $INSTALL_DIR/lemp && ./service-start.sh\nStop the systemd service with:\n  $ cd $INSTALL_DIR/lemp && ./service-stop.sh"
echo -e "\nAll done! Exiting..."
