#!/bin/bash
set -e

echo PID1 > /dev/null

/etc/init.d/rsyslog start

#Stay in foreground mode, don’t daemonize.
#/usr/sbin/cron -f &
#/usr/sbin/cron
#/etc/init.d/cron start

while true; do
  date >> /var/log/cron-test.log 2>&1
  sleep 60
done

/usr/local/php7/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php7/etc/php-fpm.conf
#/usr/local/php7/sbin/php-fpm --daemonize --fpm-config /usr/local/php7/etc/php-fpm.conf
