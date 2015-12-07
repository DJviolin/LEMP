# LEMP stack built on Docker

Work in progress!

## Usage

1. Clone this repo into your `/home/core/work/lemp` folder on your CoreOS host (this environment works with other local folders / linux OS, but in this case you have to manually adjust every single local folder which are hardcoded into the scripts).
2. Navigate to this folder on your Linux Host OS with Docker installed (preferably CoreOS).
3. Create a folder in `/home/core/www`. This will be the folder to your webserver files.
3. Place your personal SSH public key in `debian/root/.ssh/authorized_keys` file (you have to create this folder structure here in your locally cloned repo).
4. On CoreOS, you have to install docker-compose! Use the provided install script here `./docker-compose-1.5.2-coreos-installer.sh` or refresh this script with the latest version from the original repo (recommended). If the script fails to run as superuser, than type in the commands from the script manually!
5. Run the `$ chmod +x service-start.sh service-stop.sh && ./service-start.sh` commands.
6. If everything works, now you have a working Nginx + PHP-FPM 7 webserver through FastCGI!
7. Visit the index page on your localhost IP at port `:8080`. You will have to see a basic `phpinfo();`.
8. If you want to stop the environment, type `./service-stop.sh`.
