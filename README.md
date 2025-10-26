# Image PHP-Apache Personnalisable et Multi-Architecture

[![Docker Build & Push](https://github.com/Mouette03/WebApp/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Mouette03/WebApp/actions/workflows/docker-publish.yml)

Ce projet fournit une base pour construire des images Docker `php-apache` personnalisées. Grâce à un système de configuration simple et à l'intégration de GitHub Actions, vous pouvez facilement générer des images multi-architectures (`linux/amd64`, `linux/arm64`) adaptées à vos besoins.

Les images sont automatiquement construites et publiées sur le [GitHub Container Registry (ghcr.io)](https://github.com/users/Mouette03/packages/container/package/webapp).

## ⚙️ Configuration

La configuration de l'image se fait entièrement via le fichier `config.json`. Vous pouvez y modifier :

-   La version de PHP (`php_version`)
-   Les dépendances système à installer avec `apt-get` (`system_dependencies`)
-   Les extensions PHP à installer (`php_extensions`)
-   Les extensions PECL à installer (`pecl_extensions`)
-   Les paramètres du `php.ini` (`php_ini_settings`)

Modifiez simplement ce fichier, et GitHub Actions s'occupera de générer un nouveau `dockerfile` et de construire l'image correspondante.

## 🚀 Utilisation

### Build Automatisé

Le moyen le plus simple d'utiliser ce projet est de laisser GitHub Actions faire le travail.
1.  Modifiez le fichier `config.json` selon vos besoins.
2.  Poussez vos modifications sur la branche `main`.
3.  GitHub Actions va automatiquement construire l'image et la publier sur `ghcr.io/mouette03/webapp`.

Vous pouvez ensuite utiliser l'image dans vos projets, par exemple avec `docker-compose` :

```yaml
version: '3.8'
services:
  my-app:
    image: ghcr.io/mouette03/webapp:latest
    ports:
      - "8080:80"
    volumes:
      - ./src:/var/www/html
```

### Utilisation en local

Si vous souhaitez construire et tester l'image localement :

1.  **Générer le Dockerfile** :
    Assurez-vous d'avoir Python installé, puis exécutez le script pour générer le `dockerfile` à partir de votre `config.json`.
    ```bash
    python generate_dockerfile.py
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
