#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

COMPOSE_FILE="compose.test.yml"
CONTAINER="fast-splash-web-test"

export FASTSPLASH_API_TEST_URL="http://127.0.0.1:8081"
export FASTSPLASH_DB_URL="jdbc:mysql://127.0.0.1:3308/fast_splash_test"
export FASTSPLASH_DB_USER="fastsplash_test"
export FASTSPLASH_DB_PASSWORD="FastSplashLocalTest@2026"

URL_INTERNA_ESPERADA="jdbc:mysql://mysql-test:3306/fast_splash_test"

echo "=== VALIDANDO CONFIGURACAO DOCKER ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api config --quiet

echo "=== COMPILANDO CODIGO E TESTES ==="

bash web/FastSplashWeb/mvnw \
    -f web/FastSplashWeb/pom.xml \
    test-compile

echo "=== CONSTRUINDO IMAGEM WEB DE TESTES ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api build web-test

echo "=== ENCERRANDO SERVIDOR DE TESTES ANTERIOR ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api stop web-test

echo "=== PREPARANDO BANCO ISOLADO ==="

bash scripts/reset-test-db.sh

encerrar_servidor() {

    echo "=== ENCERRANDO TOMCAT DE TESTES ==="

    docker compose -f "$COMPOSE_FILE" \
        --profile api stop web-test || true
}

trap encerrar_servidor EXIT

echo "=== INICIANDO TOMCAT ISOLADO ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api up -d --force-recreate web-test

echo "=== VALIDANDO AMBIENTE HTTP ==="

URL_CONTAINER="$(
    docker exec "$CONTAINER" \
        printenv FASTSPLASH_DB_URL
)"

USUARIO_CONTAINER="$(
    docker exec "$CONTAINER" \
        printenv FASTSPLASH_DB_USER
)"

PORTA_CONTAINER="$(
    docker port "$CONTAINER" 10000/tcp
)"

if [[ "$URL_CONTAINER" != "$URL_INTERNA_ESPERADA" ]]; then

    echo "ERRO: servidor conectado a banco nao autorizado."

    exit 1
fi

if [[ "$USUARIO_CONTAINER" != "$FASTSPLASH_DB_USER" ]]; then

    echo "ERRO: usuario do banco nao autorizado."

    exit 1
fi

if [[ "$PORTA_CONTAINER" != "127.0.0.1:8081" ]]; then

    echo "ERRO: porta HTTP inesperada."

    exit 1
fi

echo "=== AGUARDANDO DISPONIBILIDADE DA API ==="

API_PRONTA=false

for tentativa in {1..60}; do

    HTTP_STATUS="$(
        curl -s \
            --connect-timeout 2 \
            --max-time 5 \
            -o /dev/null \
            -w '%{http_code}' \
            "$FASTSPLASH_API_TEST_URL/api/clientes/me" \
            || true
    )"

    if [[ "$HTTP_STATUS" == "401" ]]; then

        API_PRONTA=true

        echo "API disponivel e respondendo HTTP 401."

        break
    fi

    echo "Aguardando API: tentativa $tentativa de 60"

    sleep 2

done

if [[ "$API_PRONTA" != "true" ]]; then

    echo "ERRO: API de testes nao ficou disponivel."

    docker logs --tail 100 "$CONTAINER"

    exit 1
fi

echo "=== EXECUTANDO TESTES HTTP DA API ==="

bash web/FastSplashWeb/mvnw \
    -f web/FastSplashWeb/pom.xml \
    -Papi-tests "$@" verify

echo "=== TESTES HTTP CONCLUIDOS COM SUCESSO ==="
