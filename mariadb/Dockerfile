# Lanti/DebianWeb
#
# VERSION               1.0.0

FROM lemp_lanti-debian-base:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="MariaDB" Vendor="Istvan Lantos" Version="1.0"

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

#RUN apt-get -y --purge remove mysql* mariadb*

RUN echo -e \
"# MariaDB 10.1 repository list - created 2015-12-10 16:34 UTC\n\
# http://mariadb.org/mariadb/repositories/\n\
deb [arch=amd64,i386] http://lon1.mirrors.digitalocean.com/mariadb/repo/10.1/debian jessie main\n\
deb-src http://lon1.mirrors.digitalocean.com/mariadb/repo/10.1/debian jessie main" > /etc/apt/sources.list.d/mariadb.list
# add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencies
# libmariadbclient18 : Depends: libmysqlclient18 (= 5.5.42+maria-1~wheezy) but 5.5.43-0+deb7u1 is to be installed
RUN echo -e \
"Package: *\n\
Pin: release o=MariaDB\n\
Pin-Priority: 999" > /etc/apt/preferences.d/mariadb
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
RUN apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing \
        mariadb-server

### Start of MariaDB setup
# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
RUN rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql
# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
  && echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
  && mv /tmp/my.cnf /etc/mysql/my.cnf
### End of MariaDB setup

#COPY etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 3306 22

CMD ["/bin/bash"]
