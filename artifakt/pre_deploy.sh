#!/bin/sh
currentDir=$(pwd)

#sudo sed -i "s/opcache.enable=1/opcache.enable=0/g" /srv/www/php74fpm/php.ini
#cd /srv/www/php74fpm/
#sudo docker-compose up -d --build
#cd $currentDir

tail="${currentDir#/*/*/*/}"
head="${currentDir%/$tail}"

if [[ $CLEAR_DATABASE -eq 1 ]]; then
   echo "Removing all tables"
   echo "set foreign_key_checks=0;" > ./drop_all_tables.sql
   ( mysqldump --add-drop-table --no-data -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME -h 127.0.0.1 | grep 'DROP TABLE' ) >> ./drop_all_tables.sql
   mysql -u $MYSQL_USER -h 127.0.0.1 -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME < ./drop_all_tables.sql
   rm ./drop_all_tables.sql

   IS_INSTALLED="false"
fi

if [[ "$IS_INSTALLED" == "true" ]]; then
   if [[ -f "$head/current/config/jwt/public.pem" ]] && [[ ! -f "/mnt/shared/config/jwt/public.pem" ]]; then
      sudo cp $head/current/config/jwt/public.pem /mnt/shared/config/jwt/
      sudo cp $head/current/config/jwt/private.pem /mnt/shared/config/jwt/
      sudo chown -R apache:opsworks /mnt/shared/config/jwt
      sudo chmod 600 -R /mnt/shared/config/jwt/public.pem
      sudo chmod 600 -R /mnt/shared/config/jwt/private.pem
   fi

   if [[ -f "$head/current/.env" ]] && [[ ! $CLEAR_DATABASE -eq 1 ]]; then
      echo "Copying old .env to new release"
      rm .env
      sudo cp $head/current/.env .
   fi
fi

composer install

if [[ "$IS_INSTALLED" == "true" ]]; then
   bin/console cache:clear
   rm -rf var/cache/*
   bin/console theme:compile --env=prod
fi