#!/bin/bash
set -e

echo ">>>>>>>>>>>>>> START CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "

if [[ ! -f "/data/.env" ]]; then

# set runtime env. vars on the fly
cat << EOF > /data/.env
APP_ENV=prod
APP_DATABASE_NAME=${ARTIFAKT_MYSQL_DATABASE_NAME:-changeme}
APP_DATABASE_USER=${ARTIFAKT_MYSQL_USER:-changeme}
APP_DATABASE_PASSWORD=${ARTIFAKT_MYSQL_PASSWORD:-changeme}
APP_DATABASE_HOST=${ARTIFAKT_MYSQL_HOST:-mysql}
APP_DATABASE_PORT=${ARTIFAKT_MYSQL_PORT:-3306}
DATABASE_URL=mysql://$ARTIFAKT_MYSQL_USER:$ARTIFAKT_MYSQL_PASSWORD@$ARTIFAKT_MYSQL_HOST:$ARTIFAKT_MYSQL_PORT/$ARTIFAKT_MYSQL_DATABASE_NAME
EOF

#echo "Creating the link for .env file"
ln -snf /data/.env /var/www/html/

fi

 echo "Creating all symbolic links"
PERSISTENT_FOLDER_LIST=("custom/plugins" "files" "config/jwt" "public/theme" "public/media" "public/thumbnail" "public/bundles" "public/sitemap")
for persistent_folder in ${PERSISTENT_FOLDER_LIST[@]}; do
  echo Mount $persistent_folder directory
  rm -rf /var/www/html/$persistent_folder && \
    mkdir -p /data/$persistent_folder && \
    ln -sfn /data/$persistent_folder /var/www/html/$persistent_folder && \
    chown -h www-data:www-data /var/www/html/$persistent_folder /data/$persistent_folder
done

ln -snf /data/.uniqueid.txt /var/www/html/

echo "End of symbolic links creation"

until nc -z -v -w30 $ARTIFAKT_MYSQL_HOST $ARTIFAKT_MYSQL_PORT
do
  echo "Waiting for database connection on $ARTIFAKT_MYSQL_HOST:$ARTIFAKT_MYSQL_PORT"
  # wait for 5 seconds before check again
  sleep 5
done

is_installed=0
echo "Checking if the app is already installed"
check_if_installed=$(echo "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = \"$ARTIFAKT_MYSQL_DATABASE_NAME\";" | mysql -N -h $ARTIFAKT_MYSQL_HOST -u $ARTIFAKT_MYSQL_USER -p${ARTIFAKT_MYSQL_PASSWORD})
if [[ $check_if_installed -gt 0 && $check_if_installed != "" ]]; then
  echo "App already installed"
  is_installed=1
fi

echo "RUNNING ON-INIT SCRIPTS"
for f in /tmp/rootfs/etc/shopware/scripts/on-init/*; do source $f; done

echo "RUNNING ON-INSTALL SCRIPTS"
if [ $is_installed -eq 0 ]; then
  for f in /tmp/rootfs/etc/shopware/scripts/on-install/*; do source $f; done
fi
echo "RUNNING ON-STARTUP SCRIPTS"
for f in /tmp/rootfs/etc/shopware/scripts/on-startup/*; do source $f; done

if [ $is_installed -eq 1 ]; then
  cp public/.htaccess.dist public/.htaccess
fi

#echo "Changing owner of html"
chown -R www-data:www-data /var/www/html /data

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
