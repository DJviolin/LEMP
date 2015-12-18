# LEMP stack built on Docker for CoreOS hosts

Nginx + PHP-FPM 7 webserver through FastCGI with microcaching + MariaDB + included PhpMyAdmin, cAdvisor, SSH!

Work in progress! NOT FOR PRODUCTION!

PHP 7 using the nightly release channel from Zend. It will be built from source in the future for further optimization (probably Nginx too).

Wordpress still needs some configuration, like WP specific settings in Nginx .conf files and SFTP access.

## Prerequisites

1. Your VM needs at least 1GB of Ram, otherwise MariaDB install will throw an error.
2. In virtual machines use fixed size disks to avoid problems (preferably 20gb minimum).
3. Keep the original folder structure on the host (or you have to inspect and manually adjust every host folder in `docker-compose.yml` and `lemp.service` files)!
4. Use CoreOS! This environment works with other local folders / linux OS, but in this case read 3.).
5. Place your personal SSH public key in `~/.ssh/authorized_keys` file on your HOST (usually this is already done by the cloud-config file on CoreOS first boot)! This is the key that you use for login into your host VM, for example on your DigitalOcean VPS.
6. Also, generate a new SSH private/public key pairs on your Host VM for Wordpress' [SSH SFTP Updater Support](https://wordpress.org/plugins/ssh-sftp-updater-support/) plugin. Command: `$ ssh-keygen -b 4096 -t rsa -N '' -C "your_email@example.com" -f ~/.ssh/wordpress_rsa`. This way you don't need SFTP support with libssh2 and you can dismiss ftp build configuration from PHP.
7. Add this public key pair for the `authorized_keys` file too: `$ cat ~/.ssh/wordpress_rsa.pub >> ~/.ssh/authorized_keys`

## Usage (New)

Basic install script provided. Run only `./install.sh` and it will take the rest! You doesn't even need to clone this repo, just only download this script to your host and run it if you wish!

The script will create the `docker-compose.yml` and `lemp.service` files inside the cloned repo.

## Usage (Old)

1. Clone this repo into your `/home/core/work/lemp` folder on your CoreOS host.
2. Navigate to this folder on your Linux Host OS with Docker installed (preferably CoreOS).
3. Create a folder in `/home/core/www`. This will be the shared folder for your webserver files.
4. Create a folder in `/home/core/mysql`. This will be the shared folder for your MySQL database. The container will populate this folder at the first boot and locking down the sub-folders and files to superuser access (you have to `sudo su` on the host able to access these files).
5. Create a folder in `/home/core/sqlbackup`. This will be the folder for your MySQL backups. The tar archives here created straight from the container by the systemd init script. So you will have a shared folder at `/home/core/mysql` which is the actual database and a `/home/core/sqlbackup` folder with tar archives in it, which is a backup when the service halted for some reason.

6. Create a file in `mariadb/mariadb.env` with the following content:

    ```
    # Set MySQL Root Password
    MYSQL_ROOT_PASSWORD=type-your-secret-password-here
    ```

7. On CoreOS, you have to install docker-compose! Use the provided install script here `./docker-compose-1.5.2-coreos-installer.sh` or refresh this script with the latest version from the original repo (recommended). If the script fails to run as superuser, than type in the commands from the script manually!
8. Run the `$ chmod +x service-start.sh service-stop.sh && ./service-start.sh` commands.
9. If everything works, now you have a working LEMP stack on steroids.
10. Visit the index page on your localhost IP with a port redirected to `:8080`.
11. If you want to stop the environment, type `./service-stop.sh` (60 seconds wait time was introduced to have enough time to `fleetctl stop` making the sql backups from the container. If your sql database is huuuge, change this wait time accordingly).

## PhpMyAdmin further setup

1. Create a new table called `phpmyadmin`
2. Into this new table, import `sql/create_tables.sql` from the original PhpMyAdmin archive which you can download from here: `https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz`
3. At the Privileges tab, create a new user called `pma` with the password `pmapass` and grant all privileges!
4. Please not remove the `/home/core/www/phpmyadmin` folder on the host, although it's empty! This is the folder of the PhpMyAdmin installation.

## Wordpress post install

1. You have to place this on the bottom of `wp-config.php`

    ```
    define('FTP_PUBKEY','/root/.ssh/wp_rsa.pub');
    define('FTP_PRIKEY','/root/.ssh/wp_rsa');
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

4. You have to add the following user/group for your Wordpress install dirs on the host: `chown -R www-data:www-data ~/www/your-wordpress-install-dir`

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
