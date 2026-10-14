#!/usr/bin/env bash
# Baixa o arquivo mensal de preços de combustíveis automotivos da ANP.
# Uso: ./scripts/download_anp.sh 2025 03
#
# Fonte: https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis
# Se a ANP mudar o padrão do link, ajuste ANP_BASE_URL (confira o link na página acima).
set -euo pipefail

ANO="${1:?informe o ano, ex: 2025}"
MES="${2:?informe o mês com dois dígitos, ex: 03}"
ANP_BASE_URL="${ANP_BASE_URL:-https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/arquivos/shpc/dsas/ca}"

DESTINO="data/raw/ca-${ANO}-${MES}.csv"
mkdir -p data/raw
curl -fSL "${ANP_BASE_URL}/ca-${ANO}-${MES}.csv" -o "${DESTINO}"
echo "Arquivo salvo em ${DESTINO}"
