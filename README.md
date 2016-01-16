# LEMP stack built on Docker

Nginx + PHP-FPM 7 webserver through FastCGI with microcaching + MariaDB + included PhpMyAdmin, cAdvisor!

Work in progress! NOT FOR PRODUCTION!

## Prerequisites

1. Linux
2. 1GB Ram
3. 20GB disk size (preferably fixed size in virtual machines)
4. Git
5. Docker Client
6. Systemd
7. Docker-compose

## Installation

Basic install script provided. Run only `./install-lemp.sh` and follow the instructions in the script! You doesn't even need to clone this repo (the script will do it anyway), just only download this file to your host and run it if you wish!

```
$ curl -L https://raw.github.com/DJviolin/LEMP/master/install-lemp.sh > $HOME/install-lemp.sh && chmod +x $HOME/install-lemp.sh && cd $HOME && ./install-lemp.sh && rm -rf $HOME/install-lemp.sh
```

The script will create the `docker-compose.yml` and `lemp.service` files inside the cloned repo, which are needed for docker-compose and systemd.

## Usage

Run docker-compose with:

```
$ docker-compose --file $HOME/server-lemp/lemp/docker-compose.yml build
```

Start the Systemd service:

```
$ cd $HOME/server-lemp/lemp
$ chmod +x service-start.sh service-stop.sh
$ ./service-start.sh
```

Stop the systemd service:

```
$ cd $HOME/server-lemp/lemp
$ ./service-stop.sh
```

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
    $ nginx -V 2>&1 | grep ngx_cache_purge -o
    ```

    All of this achieved by following [this](https://easyengine.io/wordpress-nginx/tutorials/single-site/fastcgi-cache-with-purging/) tutorial.

## Docker-compose installation on CoreOS

If you happens to be a `CoreOS` user and you want to install `docker-compose`, you can install it with superuser access:

```
$ sudo su
$ mkdir -p /opt/bin
$ curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /opt/bin/docker-compose
$ chmod +x /opt/bin/docker-compose
$ exit
```

Or without any superuser access, from the nightly release channel:

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
