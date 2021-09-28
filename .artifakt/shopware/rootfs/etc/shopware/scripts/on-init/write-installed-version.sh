#!/usr/bin/env bash

if [[ -n "$INSTALLED_SHOPWARE_VERSION" ]]; then
    echo 'Written'
    echo "$INSTALLED_SHOPWARE_VERSION" > /var/www/html/state/installed_version
fi