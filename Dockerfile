FROM php:7.3-fpm-alpine

RUN apk add --no-cache bash zip curl nginx supervisor g++ icu-dev openssl && \
    docker-php-ext-install mysqli pdo_mysql intl

# Configure PHP-FPM
COPY ./fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY ./php.ini /etc/php7/conf.d/custom.ini

# Configure crontab
COPY ./tasks.cron /tasks.cron

# Configure supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Setup crontab
RUN crontab /tasks.cron

COPY ./entry-point.sh /entry-point.sh

WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 80

ENTRYPOINT ["/entry-point.sh"]
