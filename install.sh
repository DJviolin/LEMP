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

cat <<'EOF' > ~/server/lemp/docker-compose-eof.yml
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
    - /home/core/server/www/:/var/www/:rw
    - /home/core/.ssh/:/root/.ssh/:rw
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
    - /home/core/server/mysql/:/var/lib/mysql/:rw
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
cat ~/server/lemp/docker-compose-eof.yml

cat <<'EOF' > ~/server/lemp/lemp-eof.service
[Unit]
Description=LEMP
After=etcd.service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
#KillMode=none
ExecStartPre=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql /home/core/server/sqlbackup
ExecStartPre=-/bin/bash -c '/usr/bin/tar -zcvf /home/core/server/sqlbackup/sqlbackup_$$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStartPre.tar.gz /home/core/server/sqlbackup/mysql --remove-files'
ExecStartPre=-/opt/bin/docker-compose --file /home/core/server/lemp/docker-compose.yml kill
ExecStartPre=-/opt/bin/docker-compose --file /home/core/server/lemp/docker-compose.yml rm --force
ExecStart=/opt/bin/docker-compose --file /home/core/server/lemp/docker-compose.yml up --force-recreate
ExecStartPost=/usr/bin/etcdctl set /LEMP Running
ExecStop=/opt/bin/docker-compose --file /home/core/server/lemp/docker-compose.yml stop
ExecStopPost=/usr/bin/etcdctl rm /LEMP
ExecStopPost=-/usr/bin/docker cp lemp_mariadb:/var/lib/mysql /home/core/server/sqlbackup
ExecStopPost=-/bin/bash -c 'tar -zcvf /home/core/server/sqlbackup/sqlbackup_$$(date +%%Y-%%m-%%d_%%H-%%M-%%S)_ExecStopPost.tar.gz /home/core/server/sqlbackup/mysql --remove-files'
Restart=always
#RestartSec=30s

[X-Fleet]
Conflicts=lemp.service
EOF
cat ~/server/lemp/lemp-eof.service

echo -e "\
# Set MySQL Root Password\n\
MYSQL_ROOT_PASSWORD=`openssl rand -base64 37 | sed -e 's/^\(.\{37\}\).*/\1/g'`" > ~/server/lemp/mariadb/mariadb.env > ~/server/mysqlpass.txt
cat ~/server/mysqlpass.txt

echo -e "Starting docker-compose\nCreating images and containers..."
#docker-compose build ~/server/lemp

echo -e "LEMP stack has built...\nRun the service with ./service-start.sh command." \
echo -e "All done! Exiting..."
