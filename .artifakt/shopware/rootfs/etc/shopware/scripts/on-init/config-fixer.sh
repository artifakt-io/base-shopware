#!/usr/bin/env bash

rm /var/www/html/config/services/defaults_test.xml
cp /tmp/rootfs/etc/shopware/configs/services/jwt.xml /var/www/html/config/services/
cp /tmp/rootfs/etc/shopware/configs/services/services.xml /var/www/html/config/