# syntax=docker/dockerfile:1
FROM php:8.3-apache-trixie

# =========================================================================
# ÉTAPE 1: Mises à jour de sécurité et Outils système
# =========================================================================
# - 'upgrade': Corrige les failles critiques (Apache, Libxml2...)
# - 'install': Ajoute les outils utilitaires
# Nettoyage (apt-get clean) pour réduire la taille de l'image.
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =========================================================================
# ÉTAPE 2: Installation Robuste des Extensions PHP (Core + PECL)
# =========================================================================
# Utilisation du script officiel mlocati pour gérer la compatibilité ARM64/AMD64
# Cela remplace 'docker-php-ext-install' et 'pecl install' qui plantaient sur ARM
# Version épinglée (pas de 'latest') pour des builds reproductibles.
COPY --from=mlocati/php-extension-installer:2.12.0 /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
gd zip pdo_mysql mysqli intl soap opcache exif ldap mbstring xsl bcmath sockets fileinfo xml gettext imagick apcu curl bz2 gmp redis

# =========================================================================
# ÉTAPE 2 bis: Retrait des outils de compilation (réduction des CVE)
# =========================================================================
# L'image officielle php:*-apache garde $PHPIZE_DEPS installé en permanence
# (gcc, g++, cpp, make, libc6-dev -> linux-libc-dev, dpkg-dev, autoconf...).
# Ces paquets ne servent qu'à compiler des extensions : une fois celles-ci
# installées, ils sont retirés de l'image finale.
# 1) Les bibliothèques runtime réellement utilisées par PHP, ses extensions
#    et Apache (détectées via ldd) sont marquées 'manual' pour être protégées.
# 2) $PHPIZE_DEPS et la chaîne gcc/cpp versionnée sont purgés (--auto-remove).
# 3) Contrôles : aucune bibliothèque manquante et liste des modules PHP
#    identique avant/après, plus aucun compilateur, sinon le build échoue.
# Conséquence : 'docker-php-ext-install' / 'pecl install' ne sont plus
# utilisables dans une image dérivée. Ajouter les extensions dans config.json.
RUN set -eux; \
    php -m > /tmp/php-modules.before; \
    find /usr/local /usr/lib/apache2 /usr/sbin/apache2 -type f \( -name '*.so*' -o -perm -u+x \) -exec ldd '{}' ';' 2>/dev/null \
      | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
      | sort -u \
      | xargs -r dpkg-query --search 2>/dev/null \
      | cut -d: -f1 | sort -u \
      | xargs -r apt-mark manual; \
    toolchain="$(dpkg -l 'gcc-[0-9]*' 'g++-[0-9]*' 'cpp' 'cpp-[0-9]*' 2>/dev/null | awk '/^ii/ && $2 !~ /-base/ { sub(/:.*/, "", $2); print $2 }')"; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS libc6-dev linux-libc-dev $toolchain; \
    if find /usr/local -type f -name '*.so*' -exec ldd '{}' ';' 2>/dev/null | grep -q 'not found'; then \
      echo 'ERREUR : bibliothèque runtime manquante après purge' >&2; exit 1; \
    fi; \
    php -m > /tmp/php-modules.after; \
    diff /tmp/php-modules.before /tmp/php-modules.after; \
    if dpkg -l gcc g++ 'gcc-[0-9]*' 'g++-[0-9]*' cpp 'cpp-[0-9]*' make libc6-dev linux-libc-dev 2>/dev/null | awk '/^ii/ && $2 !~ /-base/' | grep -q .; then \
      echo 'ERREUR : outils de compilation encore présents' >&2; exit 1; \
    fi; \
    rm -rf /tmp/php-modules.* /var/lib/apt/lists/* /var/cache/apt/*

# =========================================================================
# ÉTAPE 3: Configuration Apache
# =========================================================================
# Activation de SSLStrictSNIVHostCheck recommandée pour mitiger CVE-2025-23048 si SSL est utilisé
RUN a2enmod rewrite headers expires deflate

# ServerName global (hors VirtualHost) : c'est le seul emplacement qui supprime
# effectivement le warning Apache AH00558 au démarrage du serveur.
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configuration du VirtualHost via Heredoc (plus lisible que echo)
COPY <<EOF /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
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
# Vérifie que la configuration Apache reste valide après le nettoyage.
RUN apache2ctl -t

WORKDIR /var/www/html
EXPOSE 80
