#!/bin/bash

while true; do
  #date >> /var/log/cron-test.log 2>&1
  #/usr/local/php7/bin/php /var/www/pussybnb.com/wp-cron.php >> /var/log/wp-cron.log 2>&1
  #/usr/local/php7/bin/php /var/www/pussybnb.com/wp-cron.php > /dev/null 2>&1
  #/usr/bin/curl -m 299 -o /dev/null http://10.0.2.2/pussybnb.com/wp-cron.php?doing_wp_cron >> /var/log/wp-cron.log 2>&1
  #/usr/bin/curl --silent -m 299 -o /dev/null http://10.0.2.2/pussybnb.com/wp-cron.php >> /var/log/wp-cron.log 2>&1
  #/usr/bin/curl --silent -m 299 http://10.0.2.2/pussybnb.com/wp-cron.php?doing_cron > /dev/null 2>&1
  /usr/bin/curl -m 299 http://10.0.2.2/pussybnb.com/wp-cron.php?doing_wp_cron=$(date +\%s.\%N) >> /var/log/wp-cron.log 2>&1
  sleep 5m
done
