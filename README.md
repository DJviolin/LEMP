# LEMP stack built on Docker for CoreOS hosts

Nginx + PHP-FPM 7 webserver through FastCGI with microcaching + MariaDB + included PhpMyAdmin, cAdvisor, SSH!

Work in progress! NOT FOR PRODUCTION!

Wordpress still needs some configuration, like WP specific settings in Nginx .conf files and SFTP access.

Nginx will be rebuilt from [source](https://www.nginx.com/resources/wiki/start/topics/tutorials/installoptions/) soon (list all the configured modules: `$ sudo nginx -V`).

## Prerequisites

1. Linux
2. 1GB Ram
3. 20GB disk size (preferably fixed size in virtual machines)
4. Git
5. Docker Client
6. Systemd
7. Docker-compose
8. Place your personal SSH public key in `~/.ssh/authorized_keys` file on your HOST

If you happens to be a `CoreOS` user and you want to install `docker-compose`, you can install it with superuser access. This will install it from the stable channel:

```
$ sudo su
$ mkdir -p /opt/bin
$ curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /opt/bin/docker-compose
$ chmod +x /opt/bin/docker-compose
$ exit
```

Or without any superuser access. this will install it from the Nightly channel:

```
# Removing symlink from /usr/share/skel/.bashrc in cave man style
$ cp $HOME/.bashrc $HOME/.bashrc.new
$ rm $HOME/.bashrc
$ mv $HOME/.bashrc.new $HOME/.bashrc
$ chmod a+x $HOME/.bashrc
# Echoing docker-compose PATH variable
$ echo -e 'export PATH="$PATH:$HOME/bin"' >> $HOME/.bashrc
$ curl -L https://dl.bintray.com/docker-compose/master/docker-compose-`uname -s`-`uname -m` > $HOME/bin/docker-compose
$ chmod +x $HOME/bin/docker-compose
# Reloading .bashrc without opening a new bash instance
$ source $HOME/.bashrc
```

## Installation

Basic install script provided. Run only `./install.sh` and follow the instructions in the script! You doesn't even need to clone this repo (the script will do it anyway), just only download this file to your host and run it if you wish!

```
$ curl -L https://raw.github.com/DJviolin/Lemp/master/install.sh > $HOME/install.sh
$ chmod +x $HOME/install.sh
$ cd $HOME
$ ./install.sh
$ rm -rf $HOME/install.sh
```

The script will create the `docker-compose.yml` and `lemp.service` files inside the cloned repo, which are needed for docker-compose and systemd.

## Usage

Run docker-compose with: `$ docker-compose build $HOME/server/lemp`

Run the systemd service with: `$ cd $HOME/server/lemp && ./service-start.sh`

Stop the systemd service with: `$ cd $HOME/server/lemp && ./service-stop.sh`

## PhpMyAdmin further setup

1. Create a new table called `phpmyadmin`
2. Into this new table, import `sql/create_tables.sql` from the original PhpMyAdmin archive which you can download from here: `https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz`
3. At the Privileges tab, create a new user called `pma` with the password `pmapass` and grant all privileges!
4. Please not remove the `$HOME/server/www/phpmyadmin` folder on the host, although it's empty! This is the folder of the PhpMyAdmin installation.

## Wordpress post install

1. You have to place this on the bottom of `wp-config.php`

    ```
    define('FTP_PUBKEY','/etc/ssh/ssh_host_rsa_key.pub');
    define('FTP_PRIKEY','/etc/ssh/ssh_host_rsa_key');
    define('FTP_USER','root');
    define('FTP_PASS','');
    define('FTP_HOST','127.0.0.1:22');
    ```

2. Install [Nginx Helper](https://wordpress.org/plugins/nginx-helper/) plugin and turn on `Enable Purge` option.

3. You can verify that nginx Cache Purge option is installed. It should return `nginx-cache-purge` to the console:

    ```
    $ docker exec -it lemp_nginx bash
    $ nginx -V 2>&1 | grep nginx-cache-purge -o
    ```

    All of this achieved by following [this](https://easyengine.io/wordpress-nginx/tutorials/single-site/fastcgi-cache-with-purging/) tutorial.

4. You have to add the following user/group for your Wordpress install dirs on the host: `chown -R www-data:www-data $HOME/server/www/your-wordpress-install-dir`

## Notes

PHP7 zend vs Source differences:

    Not installed in Zend PHP build: mysqlnd readline

    Not installed in source PHP build: pdo_mysql

    Zend -> Source

    OpenSSL Header Version:  OpenSSL 1.0.1f 6 Jan 2014  -> OpenSSL 1.0.1k 8 Jan 2015 

    PDO drivers:   mysql, sqlite -> sqlite

[Wordpress SSH2 tutorial](https://www.digitalocean.com/community/tutorials/how-to-configure-secure-updates-and-installations-in-wordpress-on-ubuntu)

cAdvisor + InfluxDB + Grafana monitoring stack compose script:

https://github.com/vegasbrianc/docker-monitoring

Nginx microcaching:

https://github.com/kevinohashi/WordPressVPS/blob/master/setup-nginx-php-fpm-microcache.sh

https://easyengine.io/wordpress-nginx/tutorials/single-site/fastcgi-cache-with-purging/

http://reviewsignal.com/blog/2014/06/25/40-million-hits-a-day-on-wordpress-using-a-10-vps/

Fine tuning here: /etc/defaults, /etc/sysctl.conf and /etc/security/limits.conf

Increase open files limit: https://easyengine.io/tutorials/linux/increase-open-files-limit/

EasyEngine tutorials: https://easyengine.io/tutorials/




Wordpress related:

https://deliciousbrains.com/http2-https-lets-encrypt-wordpress/

https://www.nginx.com/resources/wiki/start/topics/recipes/wordpress/

https://github.com/EasyEngine/easyengine

https://ttmm.io/tech/ludicrous-speed-wordpress-caching-with-redis/

https://www.digitalocean.com/community/tutorials/how-to-configure-redis-caching-to-speed-up-wordpress-on-ubuntu-14-04
http://www.jeedo.net/lightning-fast-wordpress-with-nginx-redis/

https://deliciousbrains.com/hosting-wordpress-yourself-server-monitoring-caching/

http://serverfault.com/questions/584403/nginx-cache-shared-between-multiple-servers

http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#example

Remove all docker containers:

    $ docker stop $(docker ps -a -q) && docker rm -f $(docker ps -a -q)
    $ docker rmi -f $(docker images -q)

Make sure that exited containers are deleted:

    $ docker rm -v $(docker ps -a -q -f status=exited)

Remove unwanted ‘dangling’ images:

    $ docker rmi $(docker images -f "dangling=true" -q)

vfs dir final cleaning with a docker image:

    $ docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes


Together:

    $ docker rm -v $(docker ps -a -q -f status=exited); docker rmi $(docker images -f "dangling=true" -q); docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes
    $ rm -rf /var/lib/docker/overlay/*
    $ rm -rf /var/lib/docker/linkgraph.db

Build options info

    $ ./configure --help

    ^.*(?=(\[1563\]:))

Managing persistent data backups with Docker (ie. databases)

    http://stackoverflow.com/questions/18496940/how-to-deal-with-persistent-storage-e-g-databases-in-docker

    http://container42.com/2013/12/16/persistent-volumes-with-docker-container-as-volume-pattern/

    http://container42.com/2014/11/18/data-only-container-madness/

    https://docs.docker.com/engine/reference/commandline/volume_create/

    http://stackoverflow.com/questions/23544282/what-is-the-best-way-to-manage-permissions-for-docker-shared-volumes/27021154#27021154

Change Virtualbox Disk Size:

    $ VBoxManage clonehd D:\VM\coreos-01\coreos_production_884.0.0.vdi D:\VM\coreos-01\coreos_production_884.0.0-fixed.vdi --variant Fixed
    $ VBoxManage modifyhd D:\VM\coreos-01\coreos_production_884.0.0-fixed.vdi --resize 20480

### Not installed for production, only in development

    $ curl vim man

    $ build-essential fakeroot devscripts module-assistant
    $ m-a prepare -y; m-a update

    $ python make gcc g++
    $ software-properties-common

Superuser tester script:

```
# Place su tester script in $HOME
RUN echo -e '\
#!/bin/bash\n\
echo "uid is ${UID}"\n\
echo "user is ${USER}"\n\
echo "username is ${USERNAME}"' >> /home/root/sutest.sh
```
