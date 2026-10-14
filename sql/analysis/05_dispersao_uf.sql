-- Pergunta: em quais estados o preço do diesel varia mais entre postos?
-- (Útil para uma frota: onde vale a pena escolher o posto com cuidado.)
-- Técnica: percentis com PERCENTILE_CONT e amplitude interquartil.
SELECT
    l.uf_sigla,
    COUNT(*)                                                                AS qtd_coletas,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.valor_venda)::NUMERIC, 3) AS p25,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY f.valor_venda)::NUMERIC, 3) AS mediana,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.valor_venda)::NUMERIC, 3) AS p75,
    ROUND((PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.valor_venda)
         - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.valor_venda))::NUMERIC, 3) AS amplitude_interquartil
FROM dw.fato_preco_combustivel f
JOIN dw.dim_produto    p USING (produto_sk)
JOIN dw.dim_localidade l USING (localidade_sk)
WHERE p.nome_produto LIKE 'DIESEL%'
GROUP BY l.uf_sigla
ORDER BY amplitude_interquartil DESC;
