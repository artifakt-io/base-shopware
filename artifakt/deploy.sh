#!/bin/sh

sudo chown -R apache:opsworks config/jwt
sudo chmod 600 -R config/jwt/public.pem
sudo chmod 600 -R config/jwt/private.pem
touch install.lock