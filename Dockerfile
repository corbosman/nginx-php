ARG PHP_VERSION=7.3
ARG GD="--with-png-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-gd"
FROM composer:1 as composer

ARG PHP_VERSION
ARG GD
FROM php:${PHP_VERSION}-fpm-alpine

########################################################################################################################
# COMPOSER                                                                                                             #
########################################################################################################################
ARG GD
COPY --from=composer /usr/bin/composer /usr/bin/composer

########################################################################################################################
# PHP                                                                                                                #
########################################################################################################################
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7 /etc/xs4all  && \
    apk add --update --no-cache --virtual .build-deps icu-dev jpeg-dev libjpeg-turbo-dev libpng-dev libzip-dev \
             postgresql-dev tzdata && \
    apk --no-cache add postgresql-client libpq libpng libjpeg icu-libs libzip tzdata bash curl && \
    docker-php-ext-configure gd ${GD} && \
    docker-php-ext-install bcmath exif gd intl mysqli opcache pcntl pdo pdo_mysql pdo_pgsql pgsql sockets zip && \
    cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime && \
    echo "Europe/Amsterdam" >  /etc/timezone && \
    apk del .build-deps && \
    rm -rf /usr/src

########################################################################################################################
# NGINX                                                                                                                #
########################################################################################################################
RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && set -x \
    && KEY_SHA512="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" \
    && apk add --no-cache --virtual .cert-deps openssl \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
        echo "key verification succeeded!"; \
        mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    else \
        echo "key verification failed!"; \
        exit 1; \
    fi \
    && printf "%s%s%s\n" \
        "https://nginx.org/packages/alpine/v" \
        `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
        "/main" \
    | tee -a /etc/apk/repositories \
    && apk del .cert-deps \
    && apk add --no-cache nginx \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
    && sed -i '$ d' /etc/apk/repositories \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

########################################################################################################################
# supervisor                                                                                                                #
########################################################################################################################
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /
COPY s6/start-nginx.sh /etc/services.d/nginx/run
COPY s6/start-fpm.sh /etc/services.d/php_fpm/run
RUN chmod -R 755 /etc/services.d/

WORKDIR /app

EXPOSE 80
CMD ["/init"]
