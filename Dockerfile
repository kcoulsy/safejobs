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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN ln -s /usr/local/bin/composer /usr/local/sbin/composer

# Create symbolic link for PHP
RUN ln -s /usr/local/bin/php /usr/local/sbin/php

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 1000 -d /home/dev dev
RUN mkdir -p /home/dev/.composer && \
    chown -R dev:dev /home/dev

# Set working directory
WORKDIR /var/www

# Copy existing application directory
COPY . /var/www

# Set permissions
RUN chown -R dev:www-data /var/www && \
    chmod -R 775 /var/www && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache && \
    mkdir -p /var/www/vendor && \
    chown -R dev:www-data /var/www/vendor

# Add PHP and Composer to PATH
ENV PATH="/usr/local/bin:/usr/local/sbin:${PATH}"

USER dev