from pathlib import Path
import re

raiz = Path(__file__).resolve().parent.parent

origem = raiz / "database/schema.sql"
destino = raiz / "tests/database/schema_test.generated.sql"

conteudo = origem.read_text(encoding="utf-8-sig")

# Remove a criacao do banco original
conteudo = re.sub(
    r"(?im)^\s*CREATE\s+DATABASE\b[^;]*;",
    "",
    conteudo
)

# Remove a selecao do banco original
conteudo = re.sub(
    r"(?im)^\s*USE\s+[^;]*;",
    "",
    conteudo
)

# Impede referencias ao banco de desenvolvimento
if re.search(r"\bfast_splash\b", conteudo, re.IGNORECASE):
    raise SystemExit(
        "ERRO: referencia ao banco de desenvolvimento encontrada."
    )

# Impede comandos de criacao ou exclusao de bancos
if re.search(
    r"\b(?:CREATE|DROP|ALTER)\s+DATABASE\b",
    conteudo,
    re.IGNORECASE
):
    raise SystemExit("ERRO: comando de banco nao permitido.")

destino.parent.mkdir(parents=True, exist_ok=True)

destino.write_text(
    "-- Schema gerado automaticamente para testes\n"
    "USE `fast_splash_test`;\n\n"
    + conteudo,
    encoding="utf-8"
)

print("Schema de testes gerado com sucesso!")
print("Origem:", origem)
print("Destino:", destino)
