#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "

export APP_ENV=dev
export APP_DEBUG=1

# NO SCRIPTS, it breaks the build
# see https://stackoverflow.com/a/61349991/1093649
composer install --no-cache --optimize-autoloader --no-interaction --no-ansi --no-scripts

#echo "export APP_ENV=$APP_ENV" >> /etc/apache2/envvars
#echo "export APP_DEBUG=$APP_DEBUG" >> /etc/apache2/envvars

mkdir /state && \
	touch /var/www/html/install.lock && \
	echo $SHOPWARE_VERSION > /shopware_version

cp -rp /.artifakt/shopware/rootfs /tmp/

chown -R www-data:www-data ./vendor ./install.lock /tmp

echo ">>>>>>>>>>>>>> END CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "
