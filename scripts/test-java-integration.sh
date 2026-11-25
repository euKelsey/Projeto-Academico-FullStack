#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "=== PREPARANDO BANCO DE TESTES ==="

bash scripts/reset-test-db.sh

export FASTSPLASH_DB_URL="jdbc:mysql://127.0.0.1:3308/fast_splash_test"
export FASTSPLASH_DB_USER="fastsplash_test"
export FASTSPLASH_DB_PASSWORD="FastSplashLocalTest@2026"

echo "=== EXECUTANDO TESTES JAVA ==="

bash web/FastSplashWeb/mvnw \
  -f web/FastSplashWeb/pom.xml \
  -Pintegration-tests verify

echo "=== TESTES JAVA CONCLUIDOS COM SUCESSO ==="
