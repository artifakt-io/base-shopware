#!/bin/sh
cd /var/www/html
echo "Getting all environment variables"
set -a && . ./.env && set +a