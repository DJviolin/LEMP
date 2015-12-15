# Lanti/DebianMariaDB
#
# VERSION               1.0.0

FROM lemp_ssh:latest
MAINTAINER Istvan Lantos <info@lantosistvan.com>
LABEL Description="MariaDB" Vendor="Istvan Lantos" Version="1.0"

ENV MARIADB_MAJOR 10.1
ENV MARIADB_VERSION 10.1.9+maria-1~jessie

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN mkdir /docker-entrypoint-initdb.d

RUN echo -e \
"# MariaDB $MARIADB_MAJOR repository list\n\
# http://downloads.mariadb.org/mariadb/repositories\n\
deb [arch=amd64,i386] http://lon1.mirrors.digitalocean.com/mariadb/repo/$MARIADB_MAJOR/debian jessie main\n\
deb-src http://lon1.mirrors.digitalocean.com/mariadb/repo/$MARIADB_MAJOR/debian jessie main" > /etc/apt/sources.list.d/mariadb.list
RUN cat /etc/apt/sources.list.d/mariadb.list
# add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencies
# libmariadbclient18 : Depends: libmysqlclient18 (= 5.5.42+maria-1~wheezy) but 5.5.43-0+deb7u1 is to be installed
RUN echo -e \
"Package: *\n\
Pin: release o=MariaDB\n\
Pin-Priority: 999" > /etc/apt/preferences.d/mariadb
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
# We set debconf keys to make APT a little quieter
RUN { \
    echo mariadb-server-$MARIADB_MAJOR mysql-server/root_password password 'unused'; \
    echo mariadb-server-$MARIADB_MAJOR mysql-server/root_password_again password 'unused'; \
    } | debconf-set-selections \
    && apt-get -y update \
    && time apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        mariadb-server=$MARIADB_VERSION

### Start of MariaDB setup
# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
RUN rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql \
    && chown -R mysql:mysql /var/lib/mysql
# etc/mysql/my.cnf: comment out a few problematic configuration values
# etc/mysql/my.cnf: don't reverse lookup hostnames, they are usually another container
### End of MariaDB setup

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mysqld"]
