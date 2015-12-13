# Lanti/DebianPHPMyAdmin
#
# VERSION               1.0.0

# https://github.com/phpmyadmin/docker/blob/master/Dockerfile
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-an-ubuntu-14-04-server

FROM lemp_lanti-debian-base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="PHPMyAdmin" Vendor="Istvan Lantos" Version="1.0"

RUN apt-get -y --force-yes install --fix-missing \
    curl

RUN curl --location https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz | tar xzf - \
 && mv phpMyAdmin* /var/www/phpmyadmin \
 && rm -rf /var/www/phpmyadmin/js/jquery/src/ /var/www/phpmyadmin/examples /var/www/phpmyadmin/po/

COPY run.sh /run.sh
RUN chmod u+rwx /run.sh

EXPOSE 8080

ENTRYPOINT [ "/run.sh" ]