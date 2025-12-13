# syntax=docker/dockerfile:1
FROM php:8.3-apache-bookworm

# =========================================================================
# ÉTAPE 1: Mises à jour de sécurité et Outils système
# =========================================================================
# - 'upgrade': Corrige les failles critiques (Apache, Libxml2...)
# - 'install': Ajoute les outils utilitaires (git, zip...)
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    zip \
    # Nettoyage immédiat pour garder l'image légère
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =========================================================================
# ÉTAPE 2: Installation Robuste des Extensions PHP (Core + PECL)
# =========================================================================
# Utilisation du script officiel mlocati pour gérer la compatibilité ARM64/AMD64
# Cela remplace 'docker-php-ext-install' et 'pecl install' qui plantaient sur ARM
COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    gd \
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
    gettext \
    imagick \
    apcu

# =========================================================================
# ÉTAPE 3: Configuration Apache
# =========================================================================
# Activation des modules requis
RUN a2enmod rewrite headers expires deflate

# Configuration du VirtualHost via Heredoc (Méthode 3 - Plus lisible)
COPY <<EOF /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# =========================================================================
# ÉTAPE 4: Configuration PHP Personnalisée
# =========================================================================
# Création du fichier de configuration prioritaire via Heredoc
COPY <<EOF /usr/local/etc/php/conf.d/zz-custom-settings.ini
file_uploads = On
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 80M
max_execution_time = 300
date.timezone = "UTC"
EOF

# =========================================================================
# ÉTAPE 5: Finition
# =========================================================================
WORKDIR /var/www/html
EXPOSE 80
