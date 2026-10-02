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

Le [workflow de publication](.github/workflows/docker-publish.yml) construit et publie les images sur le [GitHub Container Registry (ghcr.io)](https://github.com/users/Mouette03/packages/container/package/webapp) lors d'une Release GitHub publiée ou d'un lancement manuel. Un simple push ne déclenche pas ce workflow dans sa configuration actuelle.

## Sécurité

Le [Dockerfile](dockerfile.template) et les workflows appliquent les mesures suivantes. Elles ne constituent pas une garantie d'absence de vulnérabilités et ne remplacent pas les tests de l'application.

- **Mises à jour lors du build** : `apt-get update && apt-get upgrade -y` installe les mises à jour disponibles pour les paquets Debian, dont les correctifs de sécurité publiés dans les dépôts configurés. Aucun mécanisme ne met automatiquement à jour un conteneur déjà lancé : il faut reconstruire ou récupérer une nouvelle image, puis recréer le conteneur.
- **Installation des extensions** : [mlocati/php-extension-installer](https://github.com/mlocati/docker-php-extension-installer), épinglé en version `2.12.0`, gère l'installation des extensions et de leurs dépendances système. Cet épinglage fixe la version de l'installateur, pas celle de tous les composants de l'image.
- **Retrait des outils de compilation** : après l'installation des extensions, le Dockerfile protège les paquets des bibliothèques runtime détectées avec `ldd`, puis purge notamment les compilateurs, `make`, `libc6-dev` et `linux-libc-dev`. Le build échoue si les contrôles détectent une dépendance manquante dans les bibliothèques `.so` sous `/usr/local`, une modification de la liste `php -m` ou la présence des outils ciblés après la purge.
- **Validation Apache** : `apache2ctl -t` vérifie la syntaxe de la configuration pendant le build. Ce contrôle ne teste pas les fonctionnalités de l'application.
- **Nettoyage des caches** : `apt-get clean` et la suppression des listes APT retirent des données inutiles. Ce nettoyage ne corrige pas les vulnérabilités ; la purge des outils de compilation est une mesure distincte. Les fichiers supprimés dans une couche ultérieure restent stockés dans les couches précédentes, donc la purge ne garantit pas une image plus petite ([documentation Docker](https://docs.docker.com/engine/storage/drivers/)).
- **Build sans cache** : les workflows utilisent `no-cache: true` pour réexécuter les étapes de construction, notamment les commandes APT. Cette option ne force pas, à elle seule, le renouvellement de l'image de base ; le workflow actuel ne définit pas `pull: true`. Docker distingue `--no-cache` et `--pull` ([documentation Docker](https://docs.docker.com/build/building/best-practices/)). PHP dépend de la version fournie par l'image de base : `apt-get upgrade` n'est pas un mécanisme de mise à jour du PHP fourni sous `/usr/local`.
- **Construction multi-architecture** : le workflow de publication cible `linux/amd64` et `linux/arm64` via Buildx et QEMU. La réussite doit être vérifiée pour chaque build ; elle n'est pas garantie pour toute combinaison de versions et d'extensions.
- **Traçabilité** : le workflow de publication demande la génération d'attestations de provenance et d'un SBOM. Ces informations documentent la construction et ses composants, sans garantir leur sécurité.

### Scan de vulnérabilités

Le [workflow Trivy](.github/workflows/security-scan.yml) se déclenche sur les push vers `security/**`, les pull requests ou un lancement manuel. Il construit une image de test AMD64 uniquement, sans la publier.

- **Rapport** : les vulnérabilités disposant d'un correctif sont affichées, toutes sévérités confondues, dans les logs et le résumé du job.
- **Seuil bloquant** : le job échoue si une vulnérabilité `CRITICAL` disposant d'un correctif est détectée. Les autres sévérités ne sont pas bloquantes et les vulnérabilités sans correctif sont exclues par `ignore-unfixed: true`.
- **Limites** : ce scan ne couvre pas l'image ARM64 et n'est pas une étape du workflow de publication. Un scan réussi ne signifie donc ni « zéro vulnérabilité » ni validation de toutes les images publiées.

### Apache et CVE-2025-23048

Le Dockerfile contient une recommandation en commentaire, mais n'applique pas `SSLStrictSNIVHostCheck on` et n'active pas `mod_ssl`. Le VirtualHost fourni écoute en HTTP sur le port 80 : aucune mitigation TLS spécifique n'est configurée par ce projet.

Selon l'[avis Apache](https://httpd.apache.org/security/vulnerabilities_24.html), CVE-2025-23048 concerne certaines configurations `mod_ssl` avec plusieurs VirtualHosts, des restrictions par certificats clients et la reprise de session TLS 1.3 ; le correctif amont est fourni dans Apache 2.4.64. Si vous ajoutez TLS et l'authentification par certificat client, vérifiez la version et les correctifs du paquet Apache ainsi que votre configuration effective.

### Extensions dans une image dérivée

Les outils de compilation étant retirés, `pecl install` et `docker-php-ext-install` ne sont plus utilisables tels quels dans une image dérivée. Ajoutez les extensions à `config.json` avant de reconstruire cette image, ou réinstallez explicitement les dépendances de compilation nécessaires dans votre propre build.

## ⚙️ Configuration

La configuration de l'image se fait entièrement via le fichier `config.json`. Vous pouvez y modifier :

-   **`php_version`** : Version de PHP (ex: `8.3`)
-   **`debian_variant`** : Variante Debian de l'image de base (`trixie` dans cette branche)
-   **`system_tools`** : Outils système à installer (git, curl, zip...)
-   **`php_extensions`** : Extensions PHP (Core + PECL) - gérées automatiquement par [mlocati/php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)
-   **`php_ini_settings`** : Paramètres du `php.ini`

L'installateur gère les dépendances système des extensions demandées. Leur compatibilité avec la version de PHP, la variante Debian et chaque architecture doit être vérifiée lors du build.

Après modification, le workflow de publication régénère le `dockerfile` lorsqu'il est lancé manuellement ou à la publication d'une Release. Un push sur une branche `security/**` déclenche uniquement le workflow de scan pour la construction de test.

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
- Vérifiez que les politiques de votre dépôt autorisent la publication de packages ; le workflow déclare `contents: read` et `packages: write`
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
Lancez manuellement le workflow pour publier `ghcr.io/VOTRE_USERNAME/webapp:beta` et `:beta-<sha court>`. Publiez une Release GitHub pour produire `:latest` et le tag de cette Release.

---

### Construction et publication (pour les mainteneurs du projet)

Le workflow de publication est déclenché par une Release GitHub publiée ou un lancement manuel. Son déclencheur sur les push est actuellement désactivé ; il n'incrémente pas automatiquement `VERSION` et ne crée pas de commit de version.

- **Build de test publié** : poussez vos changements, puis lancez le workflow manuellement en sélectionnant la branche à tester. Il publie les tags `:beta` et `:beta-<sha court>`, sans modifier `:latest`.
- **Release** : après les tests, créez le tag de version voulu et publiez une Release GitHub, par exemple `v1.0.2`. Le workflow publie `:latest` et le tag exact de la Release, par exemple `:v1.0.2`.

Dans les deux cas, le workflow régénère le Dockerfile, construit pour AMD64 et ARM64 sans cache de build, puis publie les images avec leurs labels OCI et les attestations demandées. Le nettoyage automatique des anciennes images est désactivé ; il n'est pas exécuté après la publication.

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
  Image de base : `php:8.3-apache-trixie`

- **GitHub Actions utilisées** :
  - [actions/checkout](https://github.com/actions/checkout) (MIT)
  - [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action) (Apache 2.0)
  - [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action) (Apache 2.0)
  - [docker/login-action](https://github.com/docker/login-action) (Apache 2.0)
  - [docker/metadata-action](https://github.com/docker/metadata-action) (Apache 2.0)
  - [docker/build-push-action](https://github.com/docker/build-push-action) (Apache 2.0)

### Licence de ce Projet

Ce projet est sous licence **GNU General Public License v3.0 (GPL-3.0)**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
