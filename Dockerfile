FROM php:7.4-fpm-alpine

ARG PHP_INI=php.ini-development

RUN apk add --no-cache autoconf openssl-dev g++ make pcre-dev icu-dev zlib-dev libzip-dev && \
    docker-php-ext-install bcmath intl opcache zip sockets && \
    apk del --purge autoconf g++ make && \
    mv "$PHP_INI_DIR/$PHP_INI" "$PHP_INI_DIR/php.ini"

WORKDIR /usr/src/app

COPY composer.* ./
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-scripts \
    --no-plugins \
    --prefer-dist \
    --no-progress \
    --no-interaction

COPY . .

ENV APP_ENV=development
ENV PORT=80

COPY --from=wizbii/caddy /caddy /usr/local/bin/caddy
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf
RUN caddy -validate -conf=Caddyfile

EXPOSE ${PORT}

CMD ["caddy", "--conf", "Caddyfile", "--log", "stdout"]