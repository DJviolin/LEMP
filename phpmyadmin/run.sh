#!/bin/bash
set -x

# use arbitrary server
if [ "$PMA_ARBITRARY" ]
  then
    cp /var/www/config.inc.arbitrary.php /var/www/config.inc.php
  else
    cp /var/www/config.inc.linked.php /var/www/config.inc.php
fi

if [ ! -f /var/www/config.secret.inc.php ] ; then
    cat > /var/www/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`';
EOT
fi

php -S 0.0.0.0:8080 -t /var/www/
