#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"
echo "Starting composer install"
composer update && composer install
echo "End of composer install"


echo "Creating all symbolic links"
PERSISTENT_FOLDER_LIST=("config/jwt" "var/log" "var/queue" "var/public" "public/media" "public/sitemap" "public/thumbnail" "files" "config/packages" "custom/plugins") 
for persistent_folder in ${PERSISTENT_FOLDER_LIST[@]}; do
  echo Mount $persistent_folder directory
  rm -rf /var/www/html/$persistent_folder && \
    mkdir -p /data/$persistent_folder && \
    ln -sfn /data/$persistent_folder /var/www/html/$persistent_folder && \
    chown -h www-data:www-data /var/www/html/$persistent_folder /data/$persistent_folder
done
echo "End of symbolic links creation"

is_installed=0
#check_if_installed=$(echo "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'shopware';" | mysql -h database -u $APP_DATABASE_USER $APP_DATABASE_NAME -p${APP_DATABASE_PASSWORD})
#if [[ $check_if_installed != 0 && $check_if_installed != "" ]]; then
#  echo "App already installed"
#  is_installed=1
#fi
echo "Is installed value: $is_installed"
if [ $is_installed -eq 0 ]; then 
  echo "Checking if .env file exists"
  if [[ ! -f /data/.env ]]; then 
    touch /data/.env
  fi 
else
  if [[ ! -f /data/install.lock ]]; then 
    touch /data/install.lock
  fi
  ln -snf /data/install.lock /var/www/html/ 
fi

echo "Creating the link for .env file"
ln -snf /data/.env /var/www/html/

echo "Getting all environment variables"
set -a && . ./.env && set +a

echo "New ENV variables"
echo "------------------------------------------------------------"
env
echo "------------------------------------------------------------"

echo "Adding bunnycdn_config plugins sw-domain-hash plugins json links"

if [[ ! -f /data/var/bunnycdn_config.yml ]]; then touch /data/var/bunnycdn_config.yml; fi && ln -snf /data/var/bunnycdn_config.yml /var/www/html/var/
if [[ ! -f /data/var/plugins.json ]]; then touch /data/var/plugins.json; fi && ln -snf /data/var/plugins.json /var/www/html/var/
if [[ ! -f /data/public/sw-domain-hash.html ]]; then touch /data/public/sw-domain-hash.html; fi && ln -snf /data/public/sw-domain-hash.html /var/www/html/var/public/
if [[ ! -f /data/var/config_administration_plugins.json ]]; then touch /data/var/config_administration_plugins.json; fi && ln -snf /data/var/config_administration_plugins.json /var/www/html/var/

echo "Changing owner of html"
chown -R www-data:www-data /var/www/html /data

#echo "Checking if DB exists - If yes, running build script"
#if [ $is_installed -eq 0 ]; then 
#  echo "Starting build.sh script"
#  ./bin/build.sh
#fi

#
#bin/console cache:clear

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
