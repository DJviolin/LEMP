# LEMP stack built on Docker

Work in progress!

## Usage

1. Clone this repo to your computer.
2. Place your personal SSH public key in `debian/root/.ssh/authorized_keys` file (you have to create this folder structure here in your locally cloned repo).
3. Navigate to this folder on your Linux Host OS with Docker installed (preferably CoreOS).
4. On CoreOS, you have to install docker-compose! Use the provided install script here `./docker-compose-1.5.2-installer.sh` or refresh this script with the latest version from the original repo (recommended).
5. Run the `$ chmod +x service-start.sh service-stop.sh && ./service-start.sh` commands.
6. If everything works, now you have a working Nginx + PHP-FPM 7 webserver through FastCGI!
7. Visit the index page on your IP at port `:8080`. You will have to see a basic `phpinfo();`.
