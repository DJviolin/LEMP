# LEMP stack built on Docker for CoreOS hosts

Work in progress!

## Prerequisites

1. Your VM needs at least 1GB of Ram, otherwise MariaDB install will throw an error.
2. In virtual machines use fixed size disks to avoid problems.

## Usage

1. Clone this repo into your `/home/core/work/lemp` folder on your CoreOS host (this environment works with other local folders / linux OS, but in this case you have to manually adjust every single local folder which are hardcoded into the scripts).
2. Navigate to this folder on your Linux Host OS with Docker installed (preferably CoreOS).
3. Create a folder in `/home/core/www`. This will be the folder to your webserver files.
4. Create a folder in `/home/core/sql`. This will be the folder to your sql backups.
5. Place your personal SSH public key in `debian/root/.ssh/authorized_keys` file (you have to create this folder structure here in your locally cloned repo).
6. Create a file in `mariadb/mariadb.env` with the following content:

    ```
    # Set MySQL Root Password
    MYSQL_ROOT_PASSWORD=type-your-secret-password-here
    ```

7. On CoreOS, you have to install docker-compose! Use the provided install script here `./docker-compose-1.5.2-coreos-installer.sh` or refresh this script with the latest version from the original repo (recommended). If the script fails to run as superuser, than type in the commands from the script manually!
8. Run the `$ chmod +x service-start.sh service-stop.sh && ./service-start.sh` commands.
9. If everything works, now you have a working Nginx + PHP-FPM 7 webserver through FastCGI!
10. Visit the index page on your localhost IP at port `:8080`. You will have to see a basic `phpinfo();`.
11. If you want to stop the environment, type `./service-stop.sh`.

##### Notes

Remove all docker containers

    $ docker stop $(docker ps -a -q)
    $ docker rm -f $(docker ps -a -q)

Managing persistent data backups with Docker (ie. databases)

    http://stackoverflow.com/questions/18496940/how-to-deal-with-persistent-storage-e-g-databases-in-docker

    http://container42.com/2013/12/16/persistent-volumes-with-docker-container-as-volume-pattern/

    http://container42.com/2014/11/18/data-only-container-madness/

    https://docs.docker.com/engine/reference/commandline/volume_create/

    http://stackoverflow.com/questions/23544282/what-is-the-best-way-to-manage-permissions-for-docker-shared-volumes/27021154#27021154

Change Virtualbox Disk Size:

    $ VBoxManage clonehd D:\VM\coreos-01\coreos_production_884.0.0.vdi D:\VM\coreos-01\coreos_production_884.0.0-fixed.vdi --variant Fixed
    $ VBoxManage modifyhd D:\VM\coreos-01\coreos_production_884.0.0-fixed.vdi --resize 20480
