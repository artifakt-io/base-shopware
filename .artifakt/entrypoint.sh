#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"

#composer install

rm -rf /var/www/html/var/uploads && \
  mkdir -p /data/config/jwt /data/var/log /data/var/queue /data/public/media /data/public/sitemap /data/public/thumbnail /data/files /var/www/html/var/public && \
  mkdir -p /var/www/html/config /var/www/html/var /var/www/html/public && \
  rm -rf /var/www/html/config/jwt /var/www/html/var/log /var/www/html/var/queue /var/www/html/public/media /var/www/html/public/sitemap /var/www/html/public/thumbnail /var/www/html/files && \
  ln -snf /data/config/jwt /var/www/html/config/ && \
  ln -snf /data/var/log /var/www/html/var/ && \
  ln -snf /data/var/queue /var/www/html/var/ && \
  ln -snf /data/public/media /var/www/html/public/ && \
  ln -snf /data/public/sitemap /var/www/html/public/ && \
  ln -snf /data/public/thumbnail /var/www/html/public/ && \
  ln -snf /data/files /var/www/html/files && \
  chown -R www-data:www-data /data

# SHARED FILES
if [[ -f /data/.env ]]; then 
    source /data/.env
    ln -snf /data/.env /var/www/html/
fi 

export APP_ENV="prod"
export APP_SECRET="def000004fe29b08b2dd6e946fec5512124951a50f8b211b7b0adb73671013a8daf35b70f67e94a52bdce17fe4ffcc1d4be7dcdc78ed46d5db9811329a52410de030e473"
export APP_URL="http://localhost"
export TRUSTED_PROXIES=0.0.0.0
export TRUSTED_HOSTS=0.0.0.0
###< symfony/framework-bundle ###

###> symfony/swiftmailer-bundle ###
# For Gmail as a transport, use: "gmail://username:password@localhost"
# For a generic SMTP server, use: "smtp://localhost:25?encryption=&auth_mode="
# Delivery is disabled by default via "null://localhost"
export MAILER_URL=null://localhost
###< symfony/swiftmailer-bundle ###

export DATABASE_URL="mysql://shopwareuser:shopwarepassword@database:3306/shopware"
export COMPOSER_HOME="/var/www/html/var/cache/composer"
export INSTANCE_ID="c5pV4o3q8oxSfCEjioC5EEhVbAte4xGB"
export BLUE_GREEN_DEPLOYMENT="0"
export SHOPWARE_HTTP_CACHE_ENABLED="1"
export SHOPWARE_HTTP_DEFAULT_TTL="7200"
export SHOPWARE_ES_HOSTS=""
export SHOPWARE_ES_ENABLED="0"
export SHOPWARE_ES_INDEXING_ENABLED="0"
export SHOPWARE_ES_INDEX_PREFIX="sw"
export SHOPWARE_CDN_STRATEGY_DEFAULT="id"

if [[ ! -f /data/var/bunnycdn_config.yml ]]; then touch /data/var/bunnycdn_config.yml; fi && ln -snf /data/var/bunnycdn_config.yml /var/www/html/var/bunnycdn_config.yml
if [[ ! -f /data/var/plugins.json ]]; then touch /data/var/plugins.json; fi && ln -snf /data/var/plugins.json /var/www/html/var/plugins.json
if [[ ! -f /data/public/sw-domain-hash.html ]]; then touch /data/public/sw-domain-hash.html; fi && ln -snf /data/public/sw-domain-hash.html /var/www/html/var/public/sw-domain-hash.html
if [[ ! -f /data/var/plugins.json ]]; then touch /data/var/plugins.json; fi && ln -snf /data/install.lock /var/www/html/install.lock


chown -R www-data:www-data /var/www/html

./bin/build-js.sh
bin/console cache:clear

#if [[ -f /var/www/html/.env ]]; then source .env; fi

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
