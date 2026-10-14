-- Pergunta: qual a tendência do preço da gasolina por estado, sem o "ruído" mensal?
-- Técnica: média móvel de 3 meses com window frame (ROWS BETWEEN).
WITH mensal AS (
    SELECT
        l.uf_sigla,
        t.ano_mes,
        AVG(f.valor_venda) AS preco_medio
    FROM dw.fato_preco_combustivel f
    JOIN dw.dim_produto    p USING (produto_sk)
    JOIN dw.dim_localidade l USING (localidade_sk)
    JOIN dw.dim_tempo      t USING (data_sk)
    WHERE p.nome_produto = 'GASOLINA'
    GROUP BY l.uf_sigla, t.ano_mes
)
SELECT
    uf_sigla,
    ano_mes,
    ROUND(preco_medio, 3) AS preco_medio,
    ROUND(AVG(preco_medio) OVER (
        PARTITION BY uf_sigla
        ORDER BY ano_mes
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 3) AS media_movel_3m
FROM mensal
ORDER BY uf_sigla, ano_mes;
