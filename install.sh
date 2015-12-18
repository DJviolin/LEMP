#!/bin/bash

# set -e making the commands if they were like &&
set -e

# TODO: check if docker-compose is installed with if else
echo -e "Installing docker-compose from GitHub Master release channel:\n(For non-Nightly, Stable releases please visit their official GitHub page)"
mkdir -p $HOME/bin
export PATH="$HOME/bin:$PATH"
if hash docker-compose 2>/dev/null; then
  echo -e "\nDocker-compose already installed on your system, skipping step & verifying version:"
  docker-compose -v
else
  curl -L https://dl.bintray.com/docker-compose/master/docker-compose-`uname -s`-`uname -m` > $HOME/bin/docker-compose
  chmod +x $HOME/bin/docker-compose
  echo -e "\nDocker-compose installed, verifying version:"
  docker-compose -v
fi

echo -e "\nCreating folder structure:"
mkdir -p $HOME/server/mysql $HOME/server/sqlbackup $HOME/server/lemp $HOME/server/www
echo -e "\
  $HOME/server/mysql\n\
  $HOME/server/sqlbackup\n\
  $HOME/server/lemp\n\
  $HOME/server/www\n\
Done!"

if test "$(ls -A "$HOME/server/lemp")"; then
  echo -e "\n$HOME/server/lemp directory is not empty!\n\nYou have to remove everything here with\n\"$ rm -rf $HOME/server/lemp/\" command and try again to run this script!\n\nScript failed to run. Exiting..."
  exit 1
else
  echo -e "\nCloning git repo into \"$HOME/server/lemp\":"
  cd $HOME/server/lemp
  git clone https://github.com/DJviolin/LEMP.git $HOME/server/lemp
  echo -e "\nShowing working directory..."
  ls -al $HOME/server/lemp
fi

echo -e "\nCreating additional files for the stack:"

# bash variables in Here-Doc, don't use 'EOF'
# http://stackoverflow.com/questions/4937792/using-variables-inside-a-bash-heredoc
# http://stackoverflow.com/questions/17578073/ssh-and-environment-variables-remote-and-local

echo -e "\nCreating: $HOME/server/lemp/docker-compose.yml\n"
cat <<EOF > $HOME/server/lemp/docker-compose.yml
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
    - $HOME/server/www/:/var/www/:rw
    - $HOME/.ssh/:/root/.ssh/:rw
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
    - $HOME/server/mysql/:/var/lib/mysql/:rw
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
cat $HOME/server/lemp/docker-compose.yml

echo -e "\nCreating: $HOME/server/lemp/lemp.service\n"
cat <<EOF > $HOME/server/lemp/lemp.service
[Unit]
Description=LEMP
After=etcd.service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
#KillMode=none
ExecStartPre=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql $HOME/server/sqlbackup
ExecStartPre=-/bin/bash -c '/usr/bin/tar -zcvf $HOME/server/sqlbackup/sqlbackup_\$\$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStartPre.tar.gz $HOME/server/sqlbackup/mysql --remove-files'
ExecStartPre=-/opt/bin/docker-compose --file $HOME/server/lemp/docker-compose.yml kill
ExecStartPre=-/opt/bin/docker-compose --file $HOME/server/lemp/docker-compose.yml rm --force
ExecStart=/opt/bin/docker-compose --file $HOME/server/lemp/docker-compose.yml up --force-recreate
ExecStartPost=/usr/bin/etcdctl set /LEMP Running
ExecStop=/opt/bin/docker-compose --file $HOME/server/lemp/docker-compose.yml stop
ExecStopPost=/usr/bin/etcdctl rm /LEMP
ExecStopPost=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql $HOME/server/sqlbackup
ExecStopPost=-/bin/bash -c 'tar -zcvf $HOME/server/sqlbackup/sqlbackup_\$\$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStopPost.tar.gz $HOME/server/sqlbackup/mysql --remove-files'
Restart=always
#RestartSec=30s

[X-Fleet]
Conflicts=lemp.service
EOF
cat $HOME/server/lemp/lemp.service

echo -e "\n\
# Set MySQL Root Password\n\
MYSQL_ROOT_PASSWORD=`openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'`" > $HOME/server/lemp/mariadb/mariadb.env > $HOME/server/mysql-root-password.txt
cat $HOME/server/mysql-root-password.txt

cd ~

echo -e "\nLEMP stack has successfully built!\n\nRun docker-compose with:\n  $ docker-compose build $HOME/server/lemp\nRun the systemd service with:\n  $ cd $HOME/server/lemp && ./service-start.sh\nStop the systemd service with:\n  $ cd $HOME/server/lemp && ./service-stop.sh"
echo -e "\nAll done! Exiting..."
