FROM serversideup/php:8.3-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    libicu-dev \
    libzip-dev

RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd intl zip
RUN docker-php-ext-enable redis

# Create storage directory structure before copying files
RUN mkdir -p /var/www/html/storage/framework/{sessions,views,cache} \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/bootstrap/cache

# Set permissions before copying files
RUN chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html

COPY --chown=www-data:www-data . /var/www/html

# Set permissions again after copying files to ensure all new files have correct permissions
RUN chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/bootstrap/cache

USER www-data

RUN composer install --no-interaction --optimize-autoloader --no-dev