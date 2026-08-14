# Gestion des Versions

Ce fichier contient la version actuelle de l'image Docker.

> ⚠️ **Ce fichier est desormais purement informatif.** Depuis la simplification
> du workflow (commit `6d1d9b1e`), la valeur de `VERSION` n'est **plus lue par
> le pipeline CI** et ne determine plus aucun tag publie. C'est desormais le
> **tag Git de la Release GitHub** qui fait foi pour la version publiee.

## 📦 Contrat de publication actuel

Le tag publie depend exclusivement de l'evenement qui declenche le workflow :

| Evenement declencheur | Tag `BUILD_TAG` | Tag `IMAGE_VERSION` | Publie `latest` ? |
|---|---|---|---|
| `push` sur `main` | `beta` | `beta-<sha court>` | ❌ Non |
| `workflow_dispatch` (manuel) | `beta` | `beta-<sha court>` | ❌ Non |
| `release` publiee (`published`) | `latest` | `<tag Git de la release>` (ex: `v2.5.0`) | ✅ Oui |

Concretement :
- `ghcr.io/mouette03/webapp:latest` n'est publie **que** lors d'une Release GitHub
- `ghcr.io/mouette03/webapp:beta` et `ghcr.io/mouette03/webapp:beta-<sha>` sont publies a chaque push sur `main` ou build manuel — jamais `latest`
- La version exacte (`v1.2.3`, etc.) vient du **tag Git associe a la Release**, pas du contenu de ce fichier `VERSION`

## 🎯 Comment publier une nouvelle version stable

1. Creer une Release GitHub avec un tag semantique, ex. `v1.2.3`
2. Publier la Release (bouton **Publish release**)
3. Le workflow se declenche automatiquement sur l'evenement `release.published`
4. Les tags `ghcr.io/mouette03/webapp:latest` et `ghcr.io/mouette03/webapp:v1.2.3` sont publies

Le contenu du fichier `VERSION` n'a pas besoin d'etre modifie au prealable : il n'influence plus le tag genere.

## 🧪 Comment tester une image beta

Un simple push sur `main`, ou un declenchement manuel via **Run workflow** (`workflow_dispatch`) dans l'onglet Actions, publie automatiquement :
- `ghcr.io/mouette03/webapp:beta` (toujours la derniere beta)
- `ghcr.io/mouette03/webapp:beta-<sha court du commit>` (traçable, jamais ecrase)

## Format de version recommande pour les Releases

Bien que non applique automatiquement, il est recommande de conserver le
**versionnage semantique** (semver) `MAJOR.MINOR.PATCH` pour le tag de Release :

- **MAJOR** (X.0.0) : Changements incompatibles (breaking changes) — ex. PHP 8 → PHP 9
- **MINOR** (0.X.0) : Nouvelles fonctionnalites — ex. ajout d'une extension PHP
- **PATCH** (0.0.X) : Corrections de bugs, ajustements mineurs de configuration

## 📝 Exemples

**Scenario 1 — Test rapide d'un changement (beta) :**
- Vous modifiez `dockerfile.template` ou `config.json` et poussez sur `main`
- Tags publies : `beta`, `beta-<sha>`
- `latest` n'est **pas** touche

**Scenario 2 — Publication d'une version stable :**
- Vous creez une Release GitHub avec le tag `v1.1.0`
- Vous la publiez
- Tags publies : `latest`, `v1.1.0`

**Scenario 3 — Nouvelle version majeure (ex. PHP 9) :**
- Vous mettez a jour `config.json` (`php_version: "9.0"`) sur `main` au prealable (build beta pour tester)
- Une fois valide, vous creez et publiez une Release taguee `v2.0.0`
- Tags publies : `latest`, `v2.0.0`
