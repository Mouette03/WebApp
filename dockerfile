FROM php:8.3-apache-bookworm

# =========================================================================
# ÉTAPE 1: Mises à jour de sécurité et Dépendances système
# =========================================================================
# AJOUT CRITIQUE : 'apt-get upgrade' force la mise à jour des libs vulnérables (Apache, Libxml2...)
# déjà présentes dans l'image de base.
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
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
    # Nettoyage pour réduire la taille
    && apt-get clean \
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
# Note : La recompilation d'Imagick utilisera maintenant les libs système à jour
RUN pecl install imagick apcu \
    && docker-php-ext-enable imagick apcu

# =========================================================================
# ÉTAPE 4: Config Apache + PHP
# =========================================================================
# Activation de SSLStrictSNIVHostCheck recommandée pour mitiger CVE-2025-23048 si SSL est utilisé
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
    echo 'date.timezone = "UTC"' >> /usr/local/etc/php/conf.d/zz-custom-settings.ini

WORKDIR /var/www/html
EXPOSE 80
