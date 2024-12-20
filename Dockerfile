FROM php:8.2-fpm

# Install system dependencies
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

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd intl zip

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer
RUN ln -s /usr/bin/composer /usr/local/bin/composer

# Create symbolic link for PHP
RUN ln -s /usr/local/bin/php /usr/local/sbin/php

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 1000 -d /home/dev dev
RUN mkdir -p /home/dev/.composer && \
    chown -R dev:dev /home/dev

# Set working directory and create necessary directories
WORKDIR /var/www
RUN mkdir -p /var/www/vendor && \
    mkdir -p /var/www/storage/logs && \
    mkdir -p /var/www/storage/framework/sessions && \
    mkdir -p /var/www/storage/framework/views && \
    mkdir -p /var/www/storage/framework/cache && \
    mkdir -p /var/www/bootstrap/cache

# Set permissions before copying files
RUN chown -R dev:www-data /var/www && \
    chmod -R 775 /var/www

# Copy existing application directory
COPY --chown=dev:www-data . /var/www

# Ensure proper permissions after copy
RUN chmod -R 775 /var/www/storage && \
    chmod -R 775 /var/www/bootstrap/cache && \
    chmod -R 775 /var/www/vendor

# Add PHP and Composer to PATH
ENV PATH="/usr/bin:/usr/local/bin:/usr/local/sbin:${PATH}"

USER dev