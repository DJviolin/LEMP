#!/bin/bash
set -e

echo PID1 > /dev/null

#Stay in foreground mode, don’t daemonize.
#/usr/sbin/cron -f
/usr/sbin/cron

#/usr/local/php7/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php7/etc/php-fpm.conf
/usr/local/php7/sbin/php-fpm --fpm-config /usr/local/php7/etc/php-fpm.conf
