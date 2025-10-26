# Guide de Configuration - WebApp Docker Image

## 📋 Vue d'ensemble

Ce fichier explique comment utiliser le système de configuration pour personnaliser votre image Docker PHP-Apache.

---

## 🔧 Fichier `config.json`

Le fichier `config.json` est le cœur de la configuration. Voici ce que chaque section contrôle :

### `php_version`
La version de PHP à utiliser pour l'image de base.
- **Exemple** : `"8.3"` utilisera l'image `php:8.3-apache-bookworm`
- **Versions disponibles** : Consultez [Docker Hub - PHP](https://hub.docker.com/_/php) pour les versions disponibles

### `system_dependencies`
Liste des paquets système à installer avec `apt-get`.
- Ces bibliothèques sont nécessaires pour compiler certaines extensions PHP
- **Exemple** : `libpng-dev` est nécessaire pour l'extension GD (traitement d'images)

### `php_extensions`
Extensions PHP natives à installer avec `docker-php-ext-install`.
- **Exemples courants** :
  - `pdo_mysql`, `mysqli` : pour MySQL/MariaDB
  - `gd` : traitement d'images
  - `zip` : gestion des archives
  - `intl` : internationalisation

### `pecl_extensions`
Extensions PHP disponibles via PECL (PHP Extension Community Library).
- **Exemples** :
  - `imagick` : traitement d'images avancé (ImageMagick)
  - `apcu` : cache en mémoire
  - `redis` : client Redis

### `php_ini_settings`
Paramètres de configuration PHP (équivalent du fichier `php.ini`).
- **Paramètres courants** :
  - `memory_limit` : mémoire maximale allouée à un script PHP
  - `upload_max_filesize` : taille maximale d'un fichier uploadé
  - `post_max_size` : taille maximale des données POST
  - `max_execution_time` : durée maximale d'exécution d'un script (en secondes)

---

## 🚀 Workflow de Build

### Automatique (Recommandé)

1. Modifiez `config.json` selon vos besoins
2. Commitez et poussez sur la branche `main`
3. GitHub Actions va automatiquement :
   - Générer le `dockerfile` à partir du template
   - Construire l'image pour `linux/amd64` et `linux/arm64`
   - Publier l'image sur `ghcr.io/mouette03/webapp` avec les tags :
     - `:latest` (dernière version)
     - `:X` (numéro de build auto-incrémenté)
     - `:sha-xxxxxx` (hash du commit)

### Local (Test)

Si vous avez Python installé localement :

```bash
# Générer le dockerfile
python generate_dockerfile.py

# Construire l'image
docker build -t mon-image-test .

# Tester l'image
docker run -p 8080:80 mon-image-test
```

---

## ⚠️ Notes Importantes

- **Format JSON** : Le fichier `config.json` ne supporte PAS les commentaires. Utilisez uniquement la syntaxe JSON valide.
- **Encodage** : Les fichiers sont en UTF-8.
- **Dépendances** : Si vous ajoutez une extension PHP, vérifiez qu'elle ne nécessite pas de dépendances système supplémentaires.

---

## 🐛 Dépannage

### Erreur "unknown instruction" lors du build
- **Cause** : Le script `generate_dockerfile.py` n'a pas été exécuté ou a produit un dockerfile invalide
- **Solution** : Vérifiez que GitHub Actions exécute bien le script avant la construction

### Extension PHP ne s'installe pas
- **Cause** : Dépendance système manquante
- **Solution** : Ajoutez la bibliothèque nécessaire dans `system_dependencies`

### Erreur de parsing JSON
- **Cause** : Syntaxe JSON invalide (virgule manquante, guillemets, etc.)
- **Solution** : Validez votre JSON avec un validateur en ligne

---

## 📚 Ressources

- [Documentation PHP officielle](https://www.php.net/manual/fr/)
- [Extensions PHP disponibles](https://www.php.net/manual/fr/extensions.php)
- [PECL - Extensions](https://pecl.php.net/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
