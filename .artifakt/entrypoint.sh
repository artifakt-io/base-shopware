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
if [[ ! -f /data/.env ]]; then 
  touch /data/.env
fi 

ln -snf /data/.env /var/www/html/

set -a && . ./.env && set +a

if [[ ! -f /data/var/bunnycdn_config.yml ]]; then touch /data/var/bunnycdn_config.yml; fi && ln -snf /data/var/bunnycdn_config.yml /var/www/html/var/
if [[ ! -f /data/var/plugins.json ]]; then touch /data/var/plugins.json; fi && ln -snf /data/var/plugins.json /var/www/html/var/
if [[ ! -f /data/public/sw-domain-hash.html ]]; then touch /data/public/sw-domain-hash.html; fi && ln -snf /data/public/sw-domain-hash.html /var/www/html/var/public/
if [[ ! -f /data/var/plugins.json ]]; then touch /data/var/plugins.json; fi && ln -snf /data/install.lock /var/www/html/

chown -R www-data:www-data /var/www/html /data

if [ "mysql -h database -u $APP_DATABASE_USER $APP_DATABASE_NAME -p${APP_DATABASE_PASSWORD} -e 'select count(*) from migration;'" != 0 ];
then
  ./bin/build.sh
fi

#
#bin/console cache:clear

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
