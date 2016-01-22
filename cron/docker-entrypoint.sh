#!/bin/bash
set -e

echo PID1 > /dev/null

/etc/init.d/rsyslog start

#Stay in foreground mode, don’t daemonize.
/usr/sbin/cron -f
