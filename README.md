<div align="center">
  <img src="Logo.png" alt="WebApp Logo" width="200"/>
</div>

# Image PHP-Apache Personnalisable et Multi-Architecture

[![Docker Build & Push](https://github.com/Mouette03/WebApp/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Mouette03/WebApp/actions/workflows/docker-publish.yml)

Ce projet fournit une base pour construire des images Docker `php-apache` personnalisées. Grâce à un système de configuration simple et à l'intégration de GitHub Actions, vous pouvez facilement générer des images multi-architectures (`linux/amd64`, `linux/arm64`) adaptées à vos besoins.

**Cas d'usage** : Idéale pour héberger des sites web et CMS tels que WordPress, Nextcloud, Joomla, PrestaShop, ou toute application PHP nécessitant Apache et des extensions personnalisées.

Les images sont automatiquement construites et publiées sur le [GitHub Container Registry (ghcr.io)](https://github.com/users/Mouette03/packages/container/package/webapp).

## 🔒 Sécurité

Cette image intègre des mesures de sécurité proactives :

- **Mises à jour automatiques** : `apt-get upgrade -y` applique les correctifs de sécurité du système
- **Installation fiable** : [mlocati/php-extension-installer](https://github.com/mlocati/docker-php-extension-installer) compile les extensions avec les bibliothèques système à jour
- **Protection CVE** : Mitigation CVE-2025-23048 (Apache) via recommandations de configuration
- **Images optimisées** : Nettoyage automatique (`apt-get clean`) pour réduire la surface d'attaque
- **Build sans cache** : `no-cache: true` garantit que chaque build récupère les derniers correctifs de sécurité
- **Multi-architecture robuste** : Compatible AMD64 et ARM64 sans erreurs de compilation

## ⚙️ Configuration

La configuration de l'image se fait entièrement via le fichier `config.json`. Vous pouvez y modifier :

-   **`php_version`** : Version de PHP (ex: `8.3`)
-   **`system_tools`** : Outils système à installer (git, curl, zip...)
-   **`php_extensions`** : Extensions PHP (Core + PECL) - gérées automatiquement par [mlocati/php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)
-   **`php_ini_settings`** : Paramètres du `php.ini`

**Avantage** : Le système utilise `mlocati/php-extension-installer` qui gère automatiquement les dépendances système et fonctionne de manière fiable sur AMD64 et ARM64.

Modifiez simplement ce fichier, et GitHub Actions s'occupera de générer un nouveau `dockerfile` et de construire l'image correspondante.

## 🚀 Utilisation

### Build Automatisé

Le moyen le plus simple d'utiliser ce projet est de laisser GitHub Actions faire le travail.

**Modifications simples (config, ajustements) :**
1.  Modifiez `config.json` selon vos besoins
2.  Poussez sur `main`
3.  La version PATCH s'incrémente automatiquement (ex: `1.0.5` → `1.0.6`)

**Nouvelles fonctionnalités ou changements majeurs :**
1.  Modifiez `VERSION` manuellement (ex: `1.0.8` → `1.1.0` ou `2.0.0`)
2.  Modifiez `config.json` si nécessaire
3.  Poussez sur `main`

GitHub Actions va automatiquement :
- Vérifier le flag `[skip ci]` pour éviter les builds inutiles
- Incrémenter la version (PATCH uniquement, sauf si vous changez MAJOR/MINOR)
- Commiter la nouvelle version dans `VERSION`
- Générer le `dockerfile` à partir du template avec les améliorations de sécurité
- Construire l'image pour `linux/amd64` et `linux/arm64` (via QEMU)
- **Build sans cache** pour garantir les dernières mises à jour de sécurité
- Publier l'image sur `ghcr.io/mouette03/webapp` avec les tags :
  - `:latest` (dernière version)
  - `:v1.0.6` (version avec préfixe v)
- Nettoyer automatiquement les images non-taggées orphelinesVous pouvez ensuite utiliser l'image dans vos projets, par exemple avec `docker-compose` :

```yaml
version: '3.8'
services:
  my-app:
    image: ghcr.io/mouette03/webapp:latest  # ou :v1.0.0 pour une version spécifique
    ports:
      - "8080:80"
    volumes:
      - ./src:/var/www/html
```

> 💡 Vous pouvez épingler une version spécifique en remplaçant `latest` par une version (ex: `v1.0.0`, `v1.2.3`).

### Utilisation en local

Si vous souhaitez construire et tester l'image localement :

1.  **Générer le Dockerfile** :
    
    **Avec Python** :
    ```bash
    python generate_dockerfile.py
    ```
    
    **Avec PowerShell (Windows)** :
    ```powershell
    .\generate_dockerfile.ps1
    ```

2.  **Construire l'image** :
    ```bash
    docker build -t mon-image-perso .
    ```

3.  **Lancer avec `docker-compose`** :
    Le fichier `docker-compose.yml` inclus peut être utilisé pour un test rapide.
    ```bash
    docker-compose up -d
    ```
    Votre site sera disponible sur [http://localhost:8080](http://localhost:8080).
