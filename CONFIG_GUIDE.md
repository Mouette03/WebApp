# Guide de Configuration - WebApp Docker Image

## 📋 Vue d'ensemble

Ce fichier explique comment utiliser le système de configuration pour personnaliser votre image Docker PHP-Apache avec **mlocati/php-extension-installer**.

---

## 🔧 Fichier `config.json`

Le fichier `config.json` est le cœur de la configuration. Voici ce que chaque section contrôle :

### `php_version`
La version de PHP à utiliser pour l'image de base.
- **Exemple** : `"8.3"` utilisera l'image `php:8.3-apache-bookworm`
- **Versions disponibles** : Consultez [Docker Hub - PHP](https://hub.docker.com/_/php) pour les versions disponibles

### `system_tools`
Liste des outils système à installer avec `apt-get`.
- **Outils recommandés** :
  - `git` : gestion de version
  - `curl` : téléchargements HTTP
  - `unzip`, `zip` : gestion des archives

**Note** : Les bibliothèques de développement (`-dev`) ne sont **plus nécessaires**. Le système `mlocati/php-extension-installer` les gère automatiquement.

### `php_extensions`
**Toutes** les extensions PHP (Core + PECL) à installer.

**Avantage** : [mlocati/php-extension-installer](https://github.com/mlocati/docker-php-extension-installer) gère automatiquement :
- Les dépendances système nécessaires
- La compilation pour AMD64 et ARM64
- L'activation des extensions

**Extensions courantes** :
- **Base de données** : `pdo_mysql`, `mysqli`, `pdo_pgsql`
- **Images** : `gd`, `imagick`
- **Archives** : `zip`
- **Internationalisation** : `intl`, `gettext`
- **Performance** : `opcache`, `apcu`
- **Autres** : `soap`, `ldap`, `bcmath`, `sockets`

**Liste complète** : [Extensions disponibles](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

### `php_ini_settings`
Paramètres de configuration PHP (équivalent du fichier `php.ini`).
- **Paramètres courants** :
  - `memory_limit` : mémoire maximale allouée à un script PHP
  - `upload_max_filesize` : taille maximale d'un fichier uploadé
  - `post_max_size` : taille maximale des données POST
  - `max_execution_time` : durée maximale d'exécution d'un script (en secondes)
  - `date.timezone` : fuseau horaire par défaut

---

## 🚀 Workflow de Build

### Automatique (Recommandé)

1. Modifiez `config.json` selon vos besoins
2. Commitez et poussez sur la branche `main`
3. GitHub Actions va automatiquement :
   - Vérifier le flag `[skip ci]` dans le message de commit
   - Incrémenter automatiquement la version PATCH
   - Générer le `dockerfile` à partir du template (avec mises à jour de sécurité)
   - Configurer QEMU pour l'émulation ARM64
   - Construire l'image pour `linux/amd64` et `linux/arm64` **sans cache** (garantit les derniers correctifs)
   - Publier l'image sur `ghcr.io/mouette03/webapp` avec les tags :
     - `:latest` (dernière version)
     - `:vX.Y.Z` (version sémantique)
   - Nettoyer les anciennes images non-taggées

### Local (Test)

**Avec Python** :
```bash
# Générer le dockerfile
python generate_dockerfile.py

# Construire l'image
docker build -t mon-image-test .

# Tester l'image
docker run -p 8080:80 mon-image-test
```

**Avec PowerShell (Windows)** :
```powershell
# Générer le dockerfile
.\generate_dockerfile.ps1

# Construire l'image
docker build -t mon-image-test .

# Tester l'image
docker run -p 8080:80 mon-image-test
```

---

## 🔒 Améliorations de Sécurité Intégrées

Le template `dockerfile.template` inclut automatiquement :

### Mises à jour de sécurité système
```dockerfile
apt-get update && apt-get upgrade -y
```
Applique tous les correctifs de sécurité disponibles pour Apache, libxml2, et autres composants système.

**Important** : Les builds sont effectués **sans cache** (`no-cache: true`) pour garantir que `apt-get upgrade` récupère toujours les dernières versions. Cela évite d'utiliser des paquets mis en cache qui pourraient être vulnérables.

### Installation sécurisée avec mlocati
```dockerfile
COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/
```
Utilise l'installateur officiel qui :
- Installe les bibliothèques système à jour
- Compile les extensions avec les versions patchées
- Fonctionne de manière fiable sur AMD64 et ARM64

### Nettoyage optimisé
```dockerfile
apt-get clean && rm -rf /var/lib/apt/lists/*
```
Réduit la taille de l'image et la surface d'attaque potentielle.

### Protection Apache CVE-2025-23048
Commentaires de configuration pour mitiger les vulnérabilités connues si SSL est activé.

### Configuration sécurisée via HEREDOC
Utilisation de la syntaxe HEREDOC pour une configuration plus lisible et moins sujette aux erreurs.

---

## 📝 Exemple de `config.json`

```json
{
  "php_version": "8.3",
  "system_tools": [
    "git",
    "curl",
    "unzip",
    "zip"
  ],
  "php_extensions": [
    "gd",
    "zip",
    "pdo_mysql",
    "mysqli",
    "intl",
    "imagick",
    "apcu"
  ],
  "php_ini_settings": {
    "memory_limit": "256M",
    "upload_max_filesize": "64M",
    "post_max_size": "80M",
    "max_execution_time": "300",
    "date.timezone": "UTC"
  }
}
```

---

## ⚠️ Notes Importantes

- **Format JSON** : Le fichier `config.json` ne supporte PAS les commentaires. Utilisez uniquement la syntaxe JSON valide.
- **Encodage** : Les fichiers sont en UTF-8.
- **Extensions** : Toutes les extensions (Core et PECL) vont dans `php_extensions`. Pas besoin de distinguer !
- **Dépendances automatiques** : mlocati installe automatiquement les bibliothèques système nécessaires.

---

## 🐛 Dépannage

### Erreur "unknown instruction" lors du build
- **Cause** : Le script `generate_dockerfile.py` n'a pas été exécuté ou a produit un dockerfile invalide
- **Solution** : Vérifiez que GitHub Actions exécute bien le script avant la construction

### Extension PHP ne s'installe pas
- **Cause** : Extension non supportée par mlocati ou nom incorrect
- **Solution** : Vérifiez la [liste des extensions supportées](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)

### Build lent sur ARM64
- **Cause** : Émulation QEMU plus lente que natif
- **Solution** : Normal, le cache GitHub Actions accélère les builds suivants

### Erreur de parsing JSON
- **Cause** : Syntaxe JSON invalide (virgule manquante, guillemets, etc.)
- **Solution** : Validez votre JSON avec un validateur en ligne

---

## 📚 Ressources

- [Documentation PHP officielle](https://www.php.net/manual/fr/)
- [Extensions PHP disponibles](https://www.php.net/manual/fr/extensions.php)
- [PECL - Extensions](https://pecl.php.net/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
