FROM registry.artifakt.io/php:7.4-apache

ARG SHOPWARE_VERSION=6.4.3.1

ENV TZ=Europe/Paris \
    APP_ENV=prod \
    MAILER_URL=null://localhost \
    SHOPWARE_ES_HOSTS= \
    SHOPWARE_ES_ENABLED=0 \
    SHOPWARE_ES_INDEXING_ENABLED=0 \
    SHOPWARE_ES_INDEX_PREFIX= \
    COMPOSER_HOME=/tmp/composer \
    SHOPWARE_HTTP_CACHE_ENABLED=1 \
    SHOPWARE_HTTP_DEFAULT_TTL=7200 \
    BLUE_GREEN_DEPLOYMENT=1 \
    INSTALL_LOCALE=en-US \
    INSTALL_CURRENCY=EUR \
    INSTALL_ADMIN_USERNAME=admin \
    INSTALL_ADMIN_PASSWORD=shopware \
    CACHE_ADAPTER=default \
    REDIS_CACHE_HOST=redis \
    REDIS_CACHE_PORT=6379 \
    REDIS_CACHE_DATABASE=0 \
    SESSION_ADAPTER=default \
    REDIS_SESSION_HOST=redis \
    REDIS_SESSION_PORT=6379 \
    REDIS_SESSION_DATABASE=1 \
    FPM_PM=dynamic \
    FPM_PM_MAX_CHILDREN=5 \
    FPM_PM_START_SERVERS=2 \
    FPM_PM_MIN_SPARE_SERVERS=1 \
    FPM_PM_MAX_SPARE_SERVERS=3 \
    PHP_MAX_UPLOAD_SIZE=128m \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_MEMORY_LIMIT=512m 

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt -y install nodejs default-mysql-client cron netcat

ARG CODE_ROOT=.

COPY /.artifakt/000-default.conf /etc/apache2/sites-enabled/000-default.conf

COPY --chown=www-data:www-data $CODE_ROOT /var/www/html/

WORKDIR /var/www/html/

RUN rm .env

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN  if [ -d .artifakt ]; then cp -rp /var/www/html/.artifakt /.artifakt/; fi

ENV APP_DEBUG=0
ENV APP_ENV=prod
RUN composer install

RUN mkdir -p /var/log/artifakt && chown www-data:www-data /var/log/artifakt
RUN mkdir /state && \
    touch /var/www/html/install.lock && \
    echo $SHOPWARE_VERSION > /shopware_version

# run custom scripts build.sh
# hadolint ignore=SC1091
#RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
#  if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
RUN  if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi

RUN mkdir -p /tmp/rootfs
COPY /.artifakt/shopware/rootfs /tmp/rootfs/
RUN chown -R www-data:www-data /tmp/rootfs

# fix perms/owner
RUN chown -R www-data:www-data /var/www/html/
