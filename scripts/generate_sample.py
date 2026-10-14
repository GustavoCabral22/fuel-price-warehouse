"""Gera um CSV SINTÉTICO no mesmo layout do arquivo da ANP.

Serve para rodar o projeto inteiro sem baixar nada (e para testes).
Os preços são inventados: não use este arquivo para conclusões reais.
"""
import csv
import random
from datetime import date, timedelta
from pathlib import Path

HEADER = [
    "Regiao - Sigla", "Estado - Sigla", "Municipio", "Revenda", "CNPJ da Revenda",
    "Nome da Rua", "Numero Rua", "Complemento", "Bairro", "Cep", "Produto",
    "Data da Coleta", "Valor de Venda", "Valor de Compra", "Unidade de Medida", "Bandeira",
]

CIDADES = [
    ("S", "RS", "PORTO ALEGRE"), ("S", "RS", "CACHOEIRINHA"), ("S", "SC", "FLORIANOPOLIS"),
    ("SE", "SP", "SAO PAULO"), ("SE", "RJ", "RIO DE JANEIRO"), ("NE", "BA", "SALVADOR"),
]
PRODUTOS = {"GASOLINA": 6.10, "ETANOL": 4.20, "DIESEL S10": 6.05, "DIESEL": 5.95}
BANDEIRAS = ["BRANCA", "IPIRANGA", "VIBRA", "RAIZEN"]


def main(saida: Path, seed: int = 42) -> None:
    rng = random.Random(seed)
    postos = [
        (cidade, f"POSTO {i:03d} LTDA", f"{rng.randint(10**13, 10**14 - 1)}", rng.choice(BANDEIRAS))
        for i, cidade in enumerate(CIDADES * 4)
    ]
    inicio = date(2025, 1, 6)
    with saida.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, delimiter=";")
        w.writerow(HEADER)
        for semana in range(26):  # ~6 meses de coletas semanais
            dia = inicio + timedelta(weeks=semana)
            tendencia = 1 + 0.004 * semana
            for (regiao, uf, municipio), nome, cnpj, bandeira in postos:
                for produto, base in PRODUTOS.items():
                    desconto = 0.97 if bandeira == "BRANCA" else 1.0
                    preco = base * tendencia * desconto * rng.uniform(0.95, 1.06)
                    w.writerow([
                        regiao, uf, municipio, nome, cnpj, "RUA EXEMPLO", "100", "",
                        "CENTRO", "90000000", produto, dia.strftime("%d/%m/%Y"),
                        f"{preco:.2f}".replace(".", ","), "", "R$ / litro", bandeira,
                    ])


if __name__ == "__main__":
    destino = Path(__file__).resolve().parents[1] / "data" / "sample" / "anp_amostra_sintetica.csv"
    main(destino)
    print(f"Amostra gerada em {destino}")
