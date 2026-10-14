#!/usr/bin/env bash
# Carrega um CSV da ANP na camada raw e roda a transformação para o dw.
# Uso: ./scripts/load_raw.sh data/raw/ca-2025-03.csv
#
# Variáveis de conexão padrão do PostgreSQL (PGHOST, PGPORT, PGUSER, PGDATABASE,
# PGPASSWORD) são respeitadas; os padrões batem com o docker-compose.yml.
set -euo pipefail

ARQUIVO="${1:?informe o caminho do CSV}"
ENCODING="${ANP_ENCODING:-UTF8}"   # arquivos antigos da ANP vêm em LATIN1
NOME_ARQUIVO="$(basename "${ARQUIVO}")"

export PGHOST="${PGHOST:-localhost}" PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}" PGDATABASE="${PGDATABASE:-fuel_dw}"
export PGPASSWORD="${PGPASSWORD:-postgres}"

# Recarregar o mesmo arquivo substitui a versão anterior em vez de duplicar.
psql -v ON_ERROR_STOP=1 -q <<SQL
BEGIN;
DELETE FROM raw.precos_combustiveis WHERE arquivo_origem = '${NOME_ARQUIVO}';
CREATE TEMP TABLE carga (LIKE raw.precos_combustiveis) ON COMMIT DROP;
ALTER TABLE carga DROP COLUMN arquivo_origem, DROP COLUMN carregado_em;
\copy carga FROM '${ARQUIVO}' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING '${ENCODING}')
INSERT INTO raw.precos_combustiveis
SELECT *, '${NOME_ARQUIVO}', now() FROM carga;
COMMIT;
SQL

psql -v ON_ERROR_STOP=1 -q -f sql/transform/load_dw.sql
echo "Carga de ${NOME_ARQUIVO} concluída."
