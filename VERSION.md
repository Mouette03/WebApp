# Gestion des Versions

Ce fichier contient la version actuelle de l'image Docker.

## ⚙️ Auto-incrémentation

Le numéro de version est **automatiquement incrémenté** à chaque build :
- À chaque push sur `main`, le numéro **PATCH** (dernier chiffre) est incrémenté automatiquement
- Exemple : `1.0.5` devient `1.0.6` au prochain build
- GitHub Actions commite automatiquement la nouvelle version

## 🎯 Changement manuel de version

Si vous voulez changer **MAJOR** ou **MINOR**, modifiez manuellement le fichier `VERSION` :

**Pour une nouvelle fonctionnalité (MINOR) :**
- Changez `1.0.5` en `1.1.0` 
- Le prochain build créera `1.1.0`, puis `1.1.1`, `1.1.2`, etc.

**Pour un changement majeur (MAJOR) :**
- Changez `1.5.3` en `2.0.0`
- Le prochain build créera `2.0.0`, puis `2.0.1`, `2.0.2`, etc.

## Format

Le format utilisé est le **versionnage sémantique** (semver) : `MAJOR.MINOR.PATCH`

- **MAJOR** (1.x.x) : Changements incompatibles (breaking changes) - PHP 8 → PHP 9
- **MINOR** (x.1.x) : Nouvelles fonctionnalités (ajout d'extensions PHP, etc.)
- **PATCH** (x.x.1) : Corrections de bugs, ajustements mineurs de configuration *(auto-incrémenté)*

## 📦 Tags créés automatiquement

À chaque build, GitHub Actions créera 4 tags :
- `ghcr.io/mouette03/webapp:latest` (toujours la dernière version)
- `ghcr.io/mouette03/webapp:v1.0.6` (avec préfixe v)
- `ghcr.io/mouette03/webapp:1.0.6` (sans préfixe)
- `ghcr.io/mouette03/webapp:sha-abc1234` (hash du commit)

## 📝 Exemples

**Scénario 1 - Ajustements de config :**
- Vous modifiez `config.json` et poussez
- `1.0.5` → `1.0.6` (automatique)
- Tags : `latest`, `v1.0.6`, `1.0.6`

**Scénario 2 - Nouvelle extension PHP :**
- Vous modifiez `VERSION` : `1.0.8` → `1.1.0`
- Vous modifiez `config.json` (ajout extension)
- Vous poussez
- `1.1.0` → `1.1.0` (premier build de cette MINOR)
- Au prochain push : `1.1.0` → `1.1.1`

**Scénario 3 - Nouvelle version PHP majeure :**
- Vous modifiez `VERSION` : `1.5.12` → `2.0.0`
- Vous modifiez `config.json` (php_version: "9.0")
- Vous poussez
- `2.0.0` → `2.0.0`
- Au prochain push : `2.0.0` → `2.0.1`
