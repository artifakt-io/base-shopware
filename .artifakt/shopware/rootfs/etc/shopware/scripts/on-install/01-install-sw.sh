#!/usr/bin/env bash

#chown -R 1000 /var/www/html/custom/plugins /var/www/html/files /var/www/html/var/log /var/www/html/public/theme /var/www/html/public/media /var/www/html/public/bundles /var/www/html/public/sitemap /var/www/html/public/thumbnail /var/www/html/config/jwt
su -s /bin/sh -c 'php /var/www/html/bin/console system:install --create-database --force' www-data
if [ ! -f /var/www/html/config/jwt/private.pem ]; then
    su -s /bin/sh -c 'php /var/www/html/bin/console system:generate-jwt-secret' www-data
fi
su -s /bin/sh -c 'php /tmp/rootfs/fix-install.php' www-data
su -s /bin/sh -c 'php /var/www/html/bin/console user:create "$INSTALL_ADMIN_USERNAME" --admin --password="$INSTALL_ADMIN_PASSWORD" -n' www-data
su -s /bin/sh -c 'php /var/www/html/bin/console sales-channel:create:storefront --name=$INSTALL_STOREFRONT_NAME --url="$APP_URL"' www-data
su -s /bin/sh -c 'php /var/www/html/bin/console theme:change --all $INSTALL_STOREFRONT_NAME' www-data
cp /shopware_version /state/installed_version