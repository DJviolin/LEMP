#!/bin/bash
set -e

echo PID1 > /dev/null

# Run script in the background (this is not daemonized)
/cron-jobs.sh &

/usr/local/php7/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php7/etc/php-fpm.conf
