#!/bin/bash
# Build manuel multi-architecture (AMD64 + ARM64)
# Note : GitHub Actions s'occupe automatiquement du build et du push

set -e

# Verifier / regenerer le dockerfile depuis config.json avant le build
echo "Generation du dockerfile depuis config.json..."
python3 generate_dockerfile.py

# Build local sans push (test uniquement)
# docker buildx build --platform linux/amd64,linux/arm64 -t webapp:local .

# Build et push vers GitHub Container Registry
# Remplacer 'mouette03' par votre nom d'utilisateur GitHub
# docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/mouette03/webapp:latest --push .
