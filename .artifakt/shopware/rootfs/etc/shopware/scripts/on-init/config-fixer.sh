#!/usr/bin/env bash

if [ -f /var/www/html/config/services/defaults_test.xml ]; then
    rm /var/www/html/config/services/defaults_test.xml
fi

cp /tmp/rootfs/etc/shopware/configs/services/jwt.xml /var/www/html/config/services/
cp /tmp/rootfs/etc/shopware/configs/services/services.xml /var/www/html/config/