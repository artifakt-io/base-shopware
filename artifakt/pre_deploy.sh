#!/bin/sh

 if [[ $CLEAR_DATABASE -eq 1 ]]; then
    echo "Removing all tables"
    ( mysqldump --add-drop-table --no-data -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME -h 127.0.0.1 | grep 'DROP TABLE' ) > ./drop_all_tables.sql
    mysql -u $MYSQL_USER -h 127.0.0.1 -p$MYSQL_PASSWORD $MYSQL_DATABASE_NAME < ./drop_all_tables.sql
    rm ./drop_all_tables.sql
 fi

composer install