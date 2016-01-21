#!/bin/bash
set -e

echo PID1 > /dev/null

#Stay in foreground mode, don’t daemonize.
/usr/sbin/cron -f & > /var/log/cron-stdout.txt 2> /var/log/cron-stderr.txt
#/usr/sbin/cron > /var/log/cron-stdout.txt 2> /var/log/cron-stderr.txt

/usr/local/php7/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php7/etc/php-fpm.conf
