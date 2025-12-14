<div align="center">
  <img src="Logo.png" alt="WebApp Logo" width="200"/>
</div>

# Image PHP-Apache Personnalisable et Multi-Architecture

<div align="center">

[![Docker Build & Push](https://github.com/Mouette03/WebApp/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Mouette03/WebApp/actions/workflows/docker-publish.yml)
![Container](https://ghcr-badge.egpl.dev/mouette03/webapp/latest_tag?trim=major&label=latest)
![PHP Version](https://img.shields.io/badge/PHP-8.3-777BB4?logo=php&logoColor=white)
![Platform](https://img.shields.io/badge/platform-linux%2Famd64%20%7C%20linux%2Farm64-lightgrey)
![License](https://img.shields.io/github/license/Mouette03/WebApp)
![Last Commit](https://img.shields.io/github/last-commit/Mouette03/WebApp)

</div>

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

### 📦 Utiliser l'image prête à l'emploi

Si vous voulez simplement **utiliser cette image** dans vos projets sans la modifier :

**Avec Docker Compose** :
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

**Avec Docker CLI** :
```bash
docker pull ghcr.io/mouette03/webapp:latest
docker run -d -p 8080:80 -v ./src:/var/www/html ghcr.io/mouette03/webapp:latest
```

> 💡 Vous pouvez épingler une version spécifique en remplaçant `latest` par une version (ex: `v1.0.0`, `v1.2.3`).

---

### 🔧 Personnaliser et créer votre propre image

Si vous voulez **forker ce projet** pour créer vos propres images personnalisées :

#### 1. Fork le projet
- Cliquez sur "Fork" en haut à droite de ce dépôt
- Clonez votre fork localement

#### 2. Configurez GitHub Actions
- Allez dans **Settings** → **Actions** → **General**
- Activez "Read and write permissions" pour `GITHUB_TOKEN`
- Dans **Packages**, rendez votre package public (optionnel)

#### 3. Personnalisez la configuration
```bash
# Modifiez config.json selon vos besoins
code config.json

# Commitez et poussez
git add config.json
git commit -m "feat: personnalisation de l'image"
git push
```

#### 4. Utilisez votre image
Vos images seront publiées sur `ghcr.io/VOTRE_USERNAME/webapp:latest`

---

### 🛠️ Build Automatisé (pour les mainteneurs du projet)

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
- Nettoyer automatiquement les images non-taggées orphelines

---

### 💻 Build et test en local

Si vous voulez construire et tester l'image localement avant de pusher :

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

---

## 📜 Licences & Attributions

Ce projet utilise et remercie les outils open source suivants :

### Outils Tiers

- **[mlocati/php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)**  
  Licence : [MIT License](https://github.com/mlocati/docker-php-extension-installer/blob/master/LICENSE)  
  Facilite l'installation des extensions PHP, y compris pour ARM64

- **[PHP Official Docker Images](https://hub.docker.com/_/php)**  
  Licence : Diverses licences open source ([détails](https://github.com/docker-library/php))  
  Image de base : `php:8.3-apache-bookworm`

- **GitHub Actions utilisées** :
  - [actions/checkout](https://github.com/actions/checkout) (MIT)
  - [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action) (Apache 2.0)
  - [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action) (Apache 2.0)
  - [docker/login-action](https://github.com/docker/login-action) (Apache 2.0)
  - [docker/metadata-action](https://github.com/docker/metadata-action) (Apache 2.0)
  - [docker/build-push-action](https://github.com/docker/build-push-action) (Apache 2.0)

### Licence de ce Projet

Ce projet est sous licence **GNU General Public License v3.0 (GPL-3.0)**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
