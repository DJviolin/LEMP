# Lanti/DebianMariaDB
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
# We set debconf keys to make APT a little quieter
RUN { \
    echo mariadb-server-10.1 mysql-server/root_password password 'unused'; \
    echo mariadb-server-10.1 mysql-server/root_password_again password 'unused'; \
    } | debconf-set-selections \
    && apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing \
        mariadb-server

### Start of MariaDB setup
# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
RUN rm -rf /var/lib/apt/lists/*
    #&& rm -rf /var/lib/mysql \
    #&& mkdir -p /var/lib/mysql \
    #&& chown mysql:mysql /var/lib/mysql
# comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
COPY etc/mysql/my.cnf /etc/mysql/
COPY etc/mysql/my.cnf_orig /etc/mysql/
### End of MariaDB setup

VOLUME /var/lib/mysql

EXPOSE 3306 22

CMD ["mysqld"]
