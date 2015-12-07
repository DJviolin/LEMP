# LEMP stack built on Docker

Work in progress!

## Usage

1. Clone this repo to your computer.
2. Place your personal SSH public key in `debian/root/.ssh/authorized_keys` file (you have to create this folder structure here in your locally cloned repo).
3. Navigate to this folder on your Linux Host OS with Docker installed (preferably CoreOS).
4. Run the `$ chmod +x service-start.sh service-stop.sh && ./service-start.sh` commands.
5. If everything works, now you have a working Nginx + PHP-FPM 7 webserver through FastCGI!
6. Visit the index page on your IP at port `:8080`. You will have to see a basic `phpinfo();`.
