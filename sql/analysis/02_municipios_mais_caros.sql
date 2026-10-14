-- Pergunta: quais municípios têm o diesel mais caro no mês mais recente?
-- Técnica: RANK() + filtro de amostra mínima (média de 1 posto não é confiável).
WITH ultimo_mes AS (
    SELECT MAX(t.ano_mes) AS ano_mes
    FROM dw.fato_preco_combustivel f
    JOIN dw.dim_tempo t USING (data_sk)
),
por_municipio AS (
    SELECT
        l.uf_sigla,
        l.municipio,
        ROUND(AVG(f.valor_venda), 3)  AS preco_medio,
        COUNT(DISTINCT f.revenda_sk)  AS qtd_postos
    FROM dw.fato_preco_combustivel f
    JOIN dw.dim_produto    p USING (produto_sk)
    JOIN dw.dim_localidade l USING (localidade_sk)
    JOIN dw.dim_tempo      t USING (data_sk)
    WHERE p.nome_produto LIKE 'DIESEL%'
      AND t.ano_mes = (SELECT ano_mes FROM ultimo_mes)
    GROUP BY l.uf_sigla, l.municipio
    HAVING COUNT(DISTINCT f.revenda_sk) >= 3
)
SELECT *
FROM (
    SELECT *, RANK() OVER (ORDER BY preco_medio DESC) AS ranking
    FROM por_municipio
) r
WHERE ranking <= 10
ORDER BY ranking;
