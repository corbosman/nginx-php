ARG PHP_VERSION=7.4
ARG GD="--with-png-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-gd"
FROM composer:2 as composer

ARG PHP_VERSION
ARG GD
FROM php:${PHP_VERSION}-fpm-alpine

ARG S6_OVERLAY_VERSION=2.2.0.3

########################################################################################################################
# COMPOSER                                                                                                             #
########################################################################################################################
ARG GD
COPY --from=composer /usr/bin/composer /usr/bin/composer

########################################################################################################################
# PHP                                                                                                                #
########################################################################################################################
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7 && \
    apk add --update --no-cache --virtual .build-deps icu-dev jpeg-dev libjpeg-turbo-dev libpng-dev libzip-dev \
             postgresql-dev tzdata autoconf alpine-sdk linux-headers && \
    apk --no-cache add postgresql-client libpq libpng libjpeg icu-libs libzip tzdata bash curl && \
    pecl channel-update pecl.php.net && \
    pecl install redis && docker-php-ext-enable redis && \
    docker-php-ext-configure gd ${GD} && \
    docker-php-ext-install bcmath exif gd intl mysqli opcache pcntl pdo pdo_mysql pdo_pgsql pgsql sockets zip && \
    cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime && \
    echo "Europe/Amsterdam" >  /etc/timezone && \
    apk del .build-deps && \
    rm -rf /usr/src && \
    mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

COPY php/limits.ini ${PHP_INI_DIR}/conf.d/

########################################################################################################################
# NGINX                                                                                                                #
########################################################################################################################
RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

########################################################################################################################
# supervisor                                                                                                                #
########################################################################################################################
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm -f /tmp/s6-overlay-amd64.tar.gz
COPY s6/start-nginx.sh /etc/services.d/nginx/run
COPY s6/start-fpm.sh /etc/services.d/php_fpm/run
RUN chmod -R 755 /etc/services.d/

WORKDIR /app

EXPOSE 80
CMD ["/init"]
