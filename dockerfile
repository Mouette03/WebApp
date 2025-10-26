FROM php:8.3-apache-bookworm

# =========================================================================
# ÉTAPE 1: Dépendances système
# =========================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libxslt-dev \
    libldap2-dev \
    libmagickwand-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    zlib1g-dev \
    gettext \
    git \
    curl \
    unzip \
    zip \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# =========================================================================
# ÉTAPE 2: Extensions PHP
# =========================================================================
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install -j$(nproc) \
    zip \
    pdo_mysql \
    mysqli \
    intl \
    soap \
    opcache \
    exif \
    ldap \
    mbstring \
    xsl \
    bcmath \
    sockets \
    fileinfo \
    xml \
    gettext

# =========================================================================
# ÉTAPE 3: Extensions PECL
# =========================================================================
RUN pecl install imagick apcu \
    && docker-php-ext-enable imagick apcu

# =========================================================================
# ÉTAPE 4: Config Apache + PHP
# =========================================================================
RUN a2enmod rewrite headers expires deflate \
    && { \
        echo '<VirtualHost *:80>'; \
        echo '    ServerAdmin webmaster@localhost'; \
        echo '    DocumentRoot /var/www/html'; \
        echo '    <Directory /var/www/html>'; \
        echo '        Options Indexes FollowSymLinks'; \
        echo '        AllowOverride All'; \
        echo '        Require all granted'; \
        echo '    </Directory>'; \
        echo '    ErrorLog ${APACHE_LOG_DIR}/error.log'; \
        echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
        echo '</VirtualHost>'; \
    } > /etc/apache2/sites-available/000-default.conf

RUN echo 'file_uploads = On' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini && \
    echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini && \
    echo 'upload_max_filesize = 64M' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini && \
    echo 'post_max_size = 80M' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini && \
    echo 'max_execution_time = 300' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini && \
    echo 'date.timezone = UTC' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini

WORKDIR /var/www/html
EXPOSE 80
