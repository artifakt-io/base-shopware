#!/bin/sh
currentDir=$(pwd)

#sudo sed -i "s/opcache.enable=1/opcache.enable=0/g" /srv/www/php74fpm/php.ini
#cd /srv/www/php74fpm/
#sudo docker-compose up -d --build
#cd $currentDir

tail="${currentDir#/*/*/*/}"
head="${currentDir%/$tail}"

if [[ $CLEAR_DATABASE -eq 1 ]]; then 
    IS_INSTALLED="false"
fi

if [[ $ARTIFAKT_IS_MAIN_INSTANCE -eq 1 ]]; then
   if [[ $CLEAR_DATABASE -eq 1 ]]; then
      echo "Removing all tables"
      echo "set foreign_key_checks=0;" > ./drop_all_tables.sql
      ( mysqldump --add-drop-table --no-data -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME -h 127.0.0.1 | grep 'DROP TABLE' ) >> ./drop_all_tables.sql
      mysql -u $MYSQL_USER -h 127.0.0.1 -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME < ./drop_all_tables.sql
      rm ./drop_all_tables.sql
      
      echo "Deleting certificates private and public in shared directory"
      sudo rm mnt/shared/config/jwt/*
   fi
fi

echo "Is installed value: $IS_INSTALLED"
if [[ $ARTIFAKT_IS_MAIN_INSTANCE -eq 1 ]]; then
    if [[ "$IS_INSTALLED" == "true" ]]; then
        if [[ -f "$head/current/config/jwt/public.pem" ]] && [[ ! -f "/mnt/shared/config/jwt/public.pem" ]]; then
            echo "Pem file found in current but not in shared, copying from $head/current/config/jwt/public.pem to /mnt/shared/config/jwt"
            sudo cp $head/current/config/jwt/public.pem /mnt/shared/config/jwt/
            sudo cp $head/current/config/jwt/private.pem /mnt/shared/config/jwt/
            sudo chown -R apache:opsworks /mnt/shared/config/jwt
            sudo chmod 600 -R /mnt/shared/config/jwt/public.pem
            sudo chmod 600 -R /mnt/shared/config/jwt/private.pem
        fi

        if [[ -f "$head/current/.env" ]] && [[ ! -f "/mnt/shared/.env" ]]; then
            echo "Put aside the .env file for all servers"
            sudo cp $head/current/.env /mnt/shared/
        fi

        if [[ ! -f "install.lock" ]]; then
            echo "Create install.lock"
            touch install.lock
        fi
    fi
else
    echo "Waiting 30 seconds if the env copy script is running plus the certificate copy"
    sleep 30
    maxWait=60
    continue=1
    counter=0
    while [ $continue -eq 1 ] || [ $counter -ge $maxWait ]
    do
        if [[ ! -f "/mnt/shared/.env" ]]; then
            echo "/mnt/shared/.env doesn't exists, waiting for main_instance to finish"
            counter=$(($counter+5))
            sleep 5
        else
            echo "File .env exists, continue"
            sudo cp /mnt/shared/.env .
            sudo chown apache:opsworks .env
            sudo chmod 755 .env
            continue=0
        fi
    done
    if [ $counter -ge $maxWait ]; then
        echo "Waited more than $maxWait, exit script."
        exit 1
    fi
fi

composer install

if [[ "$IS_INSTALLED" == "true" ]]; then
   bin/console cache:clear
   rm -rf var/cache/*
   bin/console theme:compile --env=prod
fi