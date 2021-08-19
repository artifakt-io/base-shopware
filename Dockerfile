FROM registry.artifakt.io/php:7.4-apache

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt -y install nodejs default-mysql-client

ARG CODE_ROOT=.

COPY /.artifakt/000-default.conf /etc/apache2/sites-enabled/000-default.conf

COPY --chown=www-data:www-data $CODE_ROOT /var/www/html/

WORKDIR /var/www/html/

RUN rm .env

# RUN [ -f composer.lock ] && composer install
# RUN [ -f composer.lock ] && composer install --no-cache --optimize-autoloader --no-interaction --no-ansi --no-dev || true

# copy the artifakt folder on root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN  if [ -d .artifakt ]; then cp -rp /var/www/html/.artifakt /.artifakt/; fi

ENV APP_DEBUG=0
ENV APP_ENV=prod
RUN composer install

#RUN [ -f composer.lock ] && composer install --no-cache --optimize-autoloader --no-interaction --no-ansi --no-dev || true

# FAILSAFE LOG FOLDER
RUN mkdir -p /var/log/artifakt && chown www-data:www-data /var/log/artifakt

# run custom scripts build.sh
# hadolint ignore=SC1091
#RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
#  if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
RUN  if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi

# fix perms/owner
RUN chown -R www-data:www-data /var/www/html/
