#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COMPOSE="compose.test.yml"
PROJETO="fast-splash-tests"

JAVA=false
API=false
WEB=false
MOBILE_LOCAL=false
MOBILE_REAL=false

DOCKER_NECESSARIO=false
LIMPEZA_NECESSARIA=false
LOCK_ADQUIRIDO=false

TOTAL_APROVADO=0
INICIO_GERAL=$SECONDS

declare -a RESULTADOS=()

ajuda() {
    cat <<'AJUDA'
FAST SPLASH - EXECUTOR CENTRAL DE TESTES

Uso:
  bash scripts/test-all.sh [opcoes]

Opcoes:
  --all           Todas as suites (padrao)
  --java          Java unitarios e integracao MySQL
  --api           API HTTP Java
  --web           Playwright Web
  --mobile        Flutter local e HTTP real
  --mobile-local  Flutter unitarios e widgets
  --mobile-real   Flutter HTTP real
  --list          Lista de suites
  --help          Exibe esta ajuda

As opcoes podem ser combinadas.

Exemplos:
  bash scripts/test-all.sh
  bash scripts/test-all.sh --java
  bash scripts/test-all.sh --mobile
  bash scripts/test-all.sh --java --mobile

As suites sao executadas sequencialmente.
Uma falha interrompe a execucao.
AJUDA
}

listar() {
    echo "=========================================="
    echo "FAST SPLASH - SUITES DISPONIVEIS"
    echo "=========================================="
    printf "%-22s %8s\n" "Java unitarios/MySQL" "436"
    printf "%-22s %8s\n" "API HTTP Java" "197"
    printf "%-22s %8s\n" "Playwright" "534"
    printf "%-22s %8s\n" "Flutter local" "316"
    printf "%-22s %8s\n" "Flutter HTTP real" "12"
    echo "------------------------------------------"
    printf "%-22s %8s\n" "TOTAL DE REFERENCIA" "1495"
}

selecionar_tudo() {
    JAVA=true
    API=true
    WEB=true
    MOBILE_LOCAL=true
    MOBILE_REAL=true
}

if [[ "$#" -eq 0 ]]; then
    selecionar_tudo
fi

for opcao in "$@"; do
    case "$opcao" in
        --all)
            selecionar_tudo
            ;;
        --java)
            JAVA=true
            ;;
        --api)
            API=true
            ;;
        --web)
            WEB=true
            ;;
        --mobile)
            MOBILE_LOCAL=true
            MOBILE_REAL=true
            ;;
        --mobile-local)
            MOBILE_LOCAL=true
            ;;
        --mobile-real)
            MOBILE_REAL=true
            ;;
        --list)
            listar
            exit 0
            ;;
        --help|-h)
            ajuda
            exit 0
            ;;
        *)
            echo "Opcao desconhecida: $opcao"
            ajuda
            exit 2
            ;;
    esac
done

exigir_comando() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Dependencia ausente: $1"
        exit 1
    fi
}

dc() {
    docker compose \
        -p "$PROJETO" \
        -f "$COMPOSE" \
        --profile api "$@"
}

duracao() {
    local segundos="$1"

    printf "%02d:%02d:%02d" \
        "$((segundos / 3600))" \
        "$((segundos % 3600 / 60))" \
        "$((segundos % 60))"
}

relatorio() {
    echo
    echo "=========================================="
    echo "FAST SPLASH - RELATORIO CONSOLIDADO"
    echo "=========================================="

    for resultado in "${RESULTADOS[@]}"; do
        echo "$resultado"
    done

    echo "------------------------------------------"
    echo "Testes aprovados contabilizados: $TOTAL_APROVADO"
    echo "Duracao total: $(duracao "$((SECONDS - INICIO_GERAL))")"
    echo "Relatorios: $LOG_DIR"
    echo "=========================================="
}

finalizar() {
    local codigo=$?

    trap - EXIT INT TERM

    if [[ "$LIMPEZA_NECESSARIA" == "true" ]]; then
        echo
        echo "=== ENCERRANDO AMBIENTE DOCKER DE TESTES ==="

        if ! dc down; then
            echo "Falha ao encerrar ambiente isolado."

            if [[ "$codigo" -eq 0 ]]; then
                codigo=1
            fi
        fi
    fi

    if [[ "$LOCK_ADQUIRIDO" == "true" ]]; then
        rmdir "$LOCK_DIR" || true
    fi

    relatorio

    if [[ "$codigo" -eq 0 ]]; then
        echo "RESULTADO FINAL: SUCESSO"
    else
        echo "RESULTADO FINAL: FALHA (codigo $codigo)"
    fi

    exit "$codigo"
}

echo "=== VALIDANDO DEPENDENCIAS ==="

exigir_comando bash
exigir_comando python
exigir_comando tee

if [[ "$JAVA" == "true" || "$API" == "true" ]]; then
    exigir_comando java
fi

if [[ "$WEB" == "true" ]]; then
    exigir_comando node
    exigir_comando npm
fi

if [[ "$MOBILE_LOCAL" == "true" ||
      "$MOBILE_REAL" == "true" ]]; then
    exigir_comando flutter
fi

if [[ "$JAVA" == "true" ||
      "$API" == "true" ||
      "$WEB" == "true" ||
      "$MOBILE_REAL" == "true" ]]; then

    DOCKER_NECESSARIO=true

    exigir_comando docker

    docker info >/dev/null
    docker compose version >/dev/null

    dc config --quiet
fi

if [[ "$API" == "true" ||
      "$WEB" == "true" ||
      "$MOBILE_REAL" == "true" ]]; then

    exigir_comando curl
fi

if [[ "$WEB" == "true" ]]; then
    if [[ ! -d tests-e2e/node_modules/@playwright/test ]]; then
        echo "Playwright nao instalado."
        echo "Execute npm ci dentro de tests-e2e."
        exit 1
    fi
fi

LOG_ROOT="$ROOT/test-reports"
LOCK_DIR="$LOG_ROOT/.execution-lock"

mkdir -p "$LOG_ROOT"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Ja existe uma execucao central em andamento."
    echo "Verifique o processo antes de remover o lock."
    exit 1
fi

LOCK_ADQUIRIDO=true

LOG_DIR="$LOG_ROOT/$(date +%Y%m%d-%H%M%S)-$$"

trap finalizar EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

mkdir -p "$LOG_DIR"

echo "=== FAST SPLASH - EXECUCAO CENTRAL ==="
echo "Relatorios: $LOG_DIR"

if [[ "$DOCKER_NECESSARIO" == "true" ]]; then

    echo "=== VERIFICANDO IDENTIDADE DOS CONTAINERS ==="

    for container in \
        fast-splash-web-test \
        fast-splash-mysql-test; do

        if docker inspect \
            --type container \
            "$container" >/dev/null 2>&1; then

            identidade="$(docker inspect \
                --format '{{index .Config.Labels "com.docker.compose.project"}}' \
                "$container")"

            if [[ "$identidade" != "$PROJETO" ]]; then
                echo "Container nao autorizado: $container"
                exit 1
            fi
        fi
    done

    LIMPEZA_NECESSARIA=true

    echo "=== PREPARANDO AMBIENTE DOCKER ==="

    dc down
fi

contar_testes() {
    local suite="$1"
    local log="$2"

    python - "$suite" "$log" <<'PY'
import re
import sys
from pathlib import Path

suite = sys.argv[1]
arquivo = Path(sys.argv[2])

texto = arquivo.read_text(
    encoding="utf-8",
    errors="replace",
)

texto = re.sub(
    r"\x1b\[[0-?]*[ -/]*[@-~]",
    "",
    texto,
)

if suite in ("java", "api"):
    resumos = re.findall(
        r"(?m)^\[INFO\]\s+Tests run:\s*(\d+),"
        r"\s*Failures:\s*(\d+),"
        r"\s*Errors:\s*(\d+),"
        r"\s*Skipped:\s*(\d+)\s*$",
        texto,
    )

    if len(resumos) != 2:
        raise SystemExit(
            "Nao foi possivel identificar os dois "
            "resumos Maven."
        )

    valores = [
        tuple(map(int, resumo))
        for resumo in resumos
    ]

    for total, falhas, erros, ignorados in valores:
        if total <= 0 or falhas or erros or ignorados:
            raise SystemExit(
                "Resumo Maven com falhas, erros "
                "ou testes ignorados."
            )

    unitarios = valores[0][0]
    integracao = valores[1][0]

    if suite == "java":
        print(unitarios + integracao)
    else:
        # Unitarios executados novamente pelo Maven
        # nao entram duas vezes no total consolidado.
        print(integracao)

elif suite == "web":
    resumos = re.findall(
        r"(?m)^\s*(\d+)\s+passed\b",
        texto,
    )

    if not resumos:
        raise SystemExit(
            "Resumo Playwright nao encontrado."
        )

    if re.search(
        r"(?m)^\s*\d+\s+(?:failed|skipped|flaky|did not run)\b",
        texto,
    ):
        raise SystemExit(
            "Playwright apresentou resultados "
            "diferentes de aprovacao integral."
        )

    print(int(resumos[-1]))

elif suite in ("mobile-local", "mobile-real"):
    resumos = re.findall(
        r"\+(\d+):\s+All tests passed!",
        texto,
    )

    if not resumos:
        raise SystemExit(
            "Resumo Flutter nao encontrado."
        )

    print(int(resumos[-1]))

else:
    raise SystemExit("Suite desconhecida.")
PY
}

executar_suite() {
    local identificador="$1"
    local nome="$2"
    local referencia="$3"

    shift 3

    local inicio=$SECONDS
    local log="$LOG_DIR/$identificador.log"
    local quantidade
    local codigo

    echo
    echo "=========================================="
    echo "EXECUTANDO: $nome"
    echo "Referencia: $referencia testes"
    echo "=========================================="

    if "$@" 2>&1 | tee "$log"; then
        codigo=0
    else
        codigo=$?
    fi

    if [[ "$codigo" -ne 0 ]]; then
        RESULTADOS+=(
            "$nome | FALHA | $(duracao "$((SECONDS - inicio))")"
        )

        echo "Suite interrompida: $nome"
        echo "Consulte: $log"

        exit "$codigo"
    fi

    if ! quantidade="$(contar_testes "$identificador" "$log")"; then
        RESULTADOS+=(
            "$nome | CONTAGEM NAO VALIDADA"
        )

        exit 1
    fi

    if [[ ! "$quantidade" =~ ^[0-9]+$ ]] ||
       [[ "$quantidade" -le 0 ]]; then

        echo "Quantidade de testes invalida."

        RESULTADOS+=(
            "$nome | CONTAGEM INVALIDA"
        )

        exit 1
    fi

    if [[ "$quantidade" -lt "$referencia" ]]; then
        echo "ERRO: quantidade inferior a referencia."
        echo "Esperado: pelo menos $referencia"
        echo "Encontrado: $quantidade"

        RESULTADOS+=(
            "$nome | CONTAGEM INFERIOR A REFERENCIA"
        )

        exit 1
    fi

    TOTAL_APROVADO=$((TOTAL_APROVADO + quantidade))

    RESULTADOS+=(
        "$nome | APROVADO | $quantidade testes | $(duracao "$((SECONDS - inicio))")"
    )

    echo "=== SUITE APROVADA: $nome ==="
    echo "Testes contabilizados: $quantidade"
}

if [[ "$JAVA" == "true" ]]; then
    executar_suite \
        java \
        "Java unitarios e MySQL" \
        436 \
        bash scripts/test-java-integration.sh
fi

if [[ "$API" == "true" ]]; then
    executar_suite \
        api \
        "API HTTP Java" \
        197 \
        bash scripts/test-api.sh
fi

if [[ "$WEB" == "true" ]]; then
    executar_suite \
        web \
        "Playwright Web" \
        534 \
        bash scripts/test-e2e.sh
fi

if [[ "$MOBILE_LOCAL" == "true" ]]; then
    executar_suite \
        mobile-local \
        "Flutter unitarios e widgets" \
        316 \
        flutter test --reporter expanded
fi

if [[ "$MOBILE_REAL" == "true" ]]; then
    executar_suite \
        mobile-real \
        "Flutter HTTP real" \
        12 \
        bash scripts/test-mobile-real.sh
fi

echo
echo "=== TODAS AS SUITES SELECIONADAS CONCLUIDAS ==="
