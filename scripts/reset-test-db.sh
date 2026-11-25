#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

COMPOSE_FILE="compose.test.yml"
CONTAINER="fast-splash-mysql-test"

echo "=== VALIDANDO CONFIGURACAO ==="

docker compose -f "$COMPOSE_FILE" config --quiet

echo "=== GERANDO SCHEMA DE TESTES ==="

python scripts/prepare-test-schema.py

echo "=== RECRIANDO CONTAINER DE TESTES ==="

docker compose -f "$COMPOSE_FILE" up -d --force-recreate --wait mysql-test

echo "=== IMPORTANDO SCHEMA ==="

docker exec -i "$CONTAINER" sh -c \
  'MYSQL_PWD="$MYSQL_PASSWORD" mysql --default-character-set=utf8mb4 -u "$MYSQL_USER" -D fast_splash_test' \
  < tests/database/schema_test.generated.sql

echo "=== IMPORTANDO SEED ==="

docker exec -i "$CONTAINER" sh -c \
  'MYSQL_PWD="$MYSQL_PASSWORD" mysql --default-character-set=utf8mb4 -u "$MYSQL_USER" -D fast_splash_test' \
  < database/seed_test.sql

echo "=== VALIDANDO BANCO ==="

docker exec "$CONTAINER" sh -c \
  'MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D fast_splash_test -e "SELECT DATABASE(); SHOW TABLES; SELECT COUNT(*) AS total_clientes FROM cliente;"'

echo "=== BANCO DE TESTES RESTAURADO COM SUCESSO ==="
