#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

COMPOSE_FILE="compose.test.yml"
CONTAINER="fast-splash-web-test"
CONTAINER_DB="fast-splash-mysql-test"

URL_AUTORIZADA="http://127.0.0.1:8081"

URL_INTERNA_ESPERADA="jdbc:mysql://mysql-test:3306/fast_splash_test"

USUARIO_ESPERADO="fastsplash_test"

export FASTSPLASH_E2E_BASE_URL="${FASTSPLASH_E2E_BASE_URL:-$URL_AUTORIZADA}"

echo "=== VALIDANDO AMBIENTE E2E ==="

if [[ "$FASTSPLASH_E2E_BASE_URL" != "$URL_AUTORIZADA" ]]; then

    echo "ERRO: URL nao autorizada para testes E2E."

    exit 1
fi

for ferramenta in docker node npm python curl; do

    if ! command -v "$ferramenta" >/dev/null 2>&1; then

        echo "ERRO: ferramenta nao encontrada: $ferramenta"

        exit 1
    fi

done

if [[ ! -f tests-e2e/package-lock.json ]]; then

    echo "ERRO: package-lock.json nao encontrado."

    exit 1
fi

if [[ ! -d tests-e2e/node_modules/@playwright/test ]]; then

    echo "ERRO: Playwright nao instalado."

    echo "Execute npm ci dentro da pasta tests-e2e."

    exit 1
fi

echo "=== VALIDANDO CONFIGURACAO DOCKER ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api config --quiet

echo "=== CONSTRUINDO IMAGEM WEB DE TESTES ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api build web-test

echo "=== ENCERRANDO SERVIDOR DE TESTES ANTERIOR ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api stop web-test

echo "=== PREPARANDO BANCO ISOLADO ==="

bash scripts/reset-test-db.sh

encerrar_servidor() {

    local status=$?

    echo "=== ENCERRANDO TOMCAT DE TESTES ==="

    docker compose -f "$COMPOSE_FILE" \
        --profile api stop web-test || {

        echo "ERRO: nao foi possivel encerrar o Tomcat."

        if [[ "$status" -eq 0 ]]; then
            status=1
        fi
    }

    exit "$status"
}

trap encerrar_servidor EXIT

trap 'exit 130' INT
trap 'exit 143' TERM

echo "=== INICIANDO TOMCAT ISOLADO ==="

docker compose -f "$COMPOSE_FILE" \
    --profile api up -d --force-recreate web-test

echo "=== VALIDANDO IDENTIDADE DOS CONTAINERS ==="

PROJETO_WEB="$(
    docker inspect \
        --format '{{index .Config.Labels "com.docker.compose.project"}}' \
        "$CONTAINER"
)"

PROJETO_DB="$(
    docker inspect \
        --format '{{index .Config.Labels "com.docker.compose.project"}}' \
        "$CONTAINER_DB"
)"

if [[ "$PROJETO_WEB" != "fast-splash-tests" ]] || \
   [[ "$PROJETO_DB" != "fast-splash-tests" ]]; then

    echo "ERRO: containers nao pertencem ao projeto de testes."

    exit 1
fi

echo "=== VALIDANDO CONFIGURACAO DO SERVIDOR ==="

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

PORTA_DB="$(
    docker port "$CONTAINER_DB" 3306/tcp
)"

if [[ "$URL_CONTAINER" != "$URL_INTERNA_ESPERADA" ]]; then

    echo "ERRO: URL do banco nao autorizada."

    exit 1
fi

if [[ "$USUARIO_CONTAINER" != "$USUARIO_ESPERADO" ]]; then

    echo "ERRO: usuario do banco nao autorizado."

    exit 1
fi

if [[ "$PORTA_CONTAINER" != "127.0.0.1:8081" ]]; then

    echo "ERRO: porta HTTP inesperada."

    exit 1
fi

if [[ "$PORTA_DB" != "127.0.0.1:3308" ]]; then

    echo "ERRO: porta MySQL inesperada."

    exit 1
fi

echo "=== VALIDANDO BANCO DE TESTES ==="

BANCO_ATUAL="$(
    docker exec "$CONTAINER_DB" sh -c \
        'MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D fast_splash_test -N -B -e "SELECT DATABASE();"'
)"

if [[ "$BANCO_ATUAL" != "fast_splash_test" ]]; then

    echo "ERRO: banco de dados nao autorizado."

    exit 1
fi

echo "Banco isolado confirmado: $BANCO_ATUAL"

echo "=== AGUARDANDO DISPONIBILIDADE DO SERVIDOR ==="

API_PRONTA=false

for tentativa in {1..60}; do

    HTTP_STATUS="$(
        curl --noproxy '*' -s \
            --connect-timeout 2 \
            --max-time 5 \
            -o /dev/null \
            -w '%{http_code}' \
            "$FASTSPLASH_E2E_BASE_URL/api/clientes/me" \
            || true
    )"

    if [[ "$HTTP_STATUS" == "401" ]]; then

        API_PRONTA=true

        echo "Servidor disponivel e respondendo HTTP 401."

        break
    fi

    echo "Aguardando servidor: tentativa $tentativa de 60"

    sleep 2

done

if [[ "$API_PRONTA" != "true" ]]; then

    echo "ERRO: servidor de testes nao ficou disponivel."

    docker logs --tail 100 "$CONTAINER"

    exit 1
fi

echo "=== EXECUTANDO TESTES PLAYWRIGHT ==="

(
    cd tests-e2e

    npm test -- "$@"
)

echo "=== TESTES E2E CONCLUIDOS COM SUCESSO ==="
