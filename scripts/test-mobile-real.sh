#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COMPOSE="compose.test.yml"
WEB="fast-splash-web-test"
MYSQL="fast-splash-mysql-test"
URL="http://127.0.0.1:8081"

dc() {
    docker compose -f "$COMPOSE" --profile api "$@"
}

for comando in docker flutter curl; do
    command -v "$comando" >/dev/null || {
        echo "Dependencia ausente: $comando"
        exit 1
    }
done

echo "=== PREPARANDO BACKEND ISOLADO ==="

dc config --quiet
dc stop web-test

limpar() {
    local resultado=$?

    trap - EXIT

    echo "=== ENCERRANDO AMBIENTE MOBILE REAL ==="

    if ! dc down; then
        echo "Falha ao encerrar ambiente."
        exit 1
    fi

    exit "$resultado"
}

trap limpar EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

dc build web-test

bash scripts/reset-test-db.sh

dc up -d --force-recreate web-test

echo "=== VALIDANDO ISOLAMENTO ==="

for container in "$WEB" "$MYSQL"; do

    projeto="$(docker inspect \
        --format '{{index .Config.Labels "com.docker.compose.project"}}' \
        "$container")"

    [[ "$projeto" == "fast-splash-tests" ]] || {
        echo "Projeto Docker nao autorizado."
        exit 1
    }

done

url_interna="$(docker exec "$WEB" printenv FASTSPLASH_DB_URL)"

[[ "$url_interna" == "jdbc:mysql://mysql-test:3306/fast_splash_test" ]] || {
    echo "URL interna do banco nao autorizada."
    exit 1
}

echo "URL interna do banco validada com sucesso."

banco="$(docker exec "$MYSQL" sh -c \
    'MYSQL_PWD="$MYSQL_PASSWORD" mysql \
    -u "$MYSQL_USER" -D fast_splash_test \
    -N -B -e "SELECT DATABASE();"')"

[[ "$banco" == "fast_splash_test" ]] || {
    echo "Banco nao autorizado."
    exit 1
}

[[ "$(docker port "$WEB" 10000/tcp)" == "127.0.0.1:8081" ]] || {
    echo "Porta HTTP nao autorizada."
    exit 1
}

echo "=== AGUARDANDO TOMCAT ==="

pronto=0

for tentativa in $(seq 1 60); do

    codigo="$(curl \
        --silent \
        --max-time 5 \
        --output /dev/null \
        --write-out '%{http_code}' \
        "$URL/api/clientes/me" || true)"

    if [[ "$codigo" == "401" ]]; then
        pronto=1
        break
    fi

    sleep 2

done

[[ "$pronto" == "1" ]] || {
    echo "Tomcat de testes indisponivel."
    exit 1
}

echo "=== EXECUTANDO TESTES MOBILE REAIS ==="

flutter test test-real/api_real_test.dart \
    --dart-define=API_BASE_URL="$URL" \
    --concurrency=1 \
    --reporter expanded

echo "=== TESTES MOBILE REAIS CONCLUIDOS COM SUCESSO ==="
