#!/usr/bin/env bash

if [[ -n $ACTIVE_PLUGINS ]]; then
  su -s /bin/sh -c 'php /var/www/html/bin/console plugin:refresh' www-data

  su -s /bin/sh -c 'php /var/www/html/bin/console plugin:install --activate $ACTIVE_PLUGINS -n' www-data
  su -s /bin/sh -c 'php /var/www/html/bin/console plugin:update $ACTIVE_PLUGINS -n' www-data
  su -s /bin/sh -c 'php /var/www/html/bin/console cache:clear' www-data
fi
