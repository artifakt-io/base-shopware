#!/bin/sh

 if [[ $CLEAR_DATABASE -eq 1 ]]; then
    echo "Removing all tables"
    mysql -u $ARTIFAKT_MYSQL_USER -h $ARTIFAKT_MYSQL_HOST $ARTIFAKT_MYSQL_DATABASE_NAME -p$MYSQL_PASSWORD < artifakt/clearTables.sql
 fi

composer install