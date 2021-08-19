#!/bin/sh

docker-compose stop && docker-compose rm -f && docker volume rm base-shopware_data base-shopware_datadir && docker-compose up -d --build
docker system prune -f