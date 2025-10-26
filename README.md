# PHP-Apache Full Multi-Architecture

Cette image contient :
- Apache avec mod_rewrite et support .htaccess
- PHP 8.2 avec toutes les extensions natives et PECL populaires (redis, apcu, imagick, xdebug, memcached, mongodb)
- Build multi-architecture (x86_64 + ARM64)

## 🚀 Utilisation

### 1. Builder en local
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t monuser/php-apache-full:latest .
```

### 2. Lancer avec docker-compose
```bash
docker compose up -d
```

Votre site sera disponible sur http://localhost:8080

### 3. Pousser sur Docker Hub (optionnel)
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t monuser/php-apache-full:latest --push .
```
