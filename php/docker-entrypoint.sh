#!/bin/bash
set -e

echo PID1 > /dev/null

/etc/init.d/rsyslog start

#Stay in foreground mode, don’t daemonize.
/usr/sbin/cron -f &
#/usr/sbin/cron
#/etc/init.d/cron start

/usr/local/php7/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php7/etc/php-fpm.conf
