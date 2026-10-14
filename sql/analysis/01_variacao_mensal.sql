-- Pergunta: quanto o preço médio de cada combustível variou mês a mês?
-- Técnica: agregação + LAG() para comparar com o mês anterior.
WITH mensal AS (
    SELECT
        p.nome_produto,
        t.ano_mes,
        ROUND(AVG(f.valor_venda), 3) AS preco_medio,
        COUNT(*)                     AS qtd_coletas
    FROM dw.fato_preco_combustivel f
    JOIN dw.dim_produto p USING (produto_sk)
    JOIN dw.dim_tempo   t USING (data_sk)
    GROUP BY p.nome_produto, t.ano_mes
)
SELECT
    nome_produto,
    ano_mes,
    preco_medio,
    LAG(preco_medio) OVER w AS preco_mes_anterior,
    ROUND(100.0 * (preco_medio / LAG(preco_medio) OVER w - 1), 2) AS variacao_pct,
    qtd_coletas
FROM mensal
WINDOW w AS (PARTITION BY nome_produto ORDER BY ano_mes)
ORDER BY nome_produto, ano_mes;
