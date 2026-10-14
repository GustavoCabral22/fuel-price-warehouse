-- Pergunta: postos sem bandeira ("BRANCA") são mesmo mais baratos?
-- Técnica: agregação condicional com FILTER.
SELECT
    p.nome_produto,
    t.ano_mes,
    ROUND(AVG(f.valor_venda) FILTER (WHERE r.bandeira = 'BRANCA'), 3)  AS preco_bandeira_branca,
    ROUND(AVG(f.valor_venda) FILTER (WHERE r.bandeira <> 'BRANCA'), 3) AS preco_com_bandeira,
    ROUND(
        100.0 * (
            AVG(f.valor_venda) FILTER (WHERE r.bandeira = 'BRANCA')
          / AVG(f.valor_venda) FILTER (WHERE r.bandeira <> 'BRANCA') - 1
        ), 2
    ) AS diferenca_pct
FROM dw.fato_preco_combustivel f
JOIN dw.dim_produto p USING (produto_sk)
JOIN dw.dim_revenda r USING (revenda_sk)
JOIN dw.dim_tempo   t USING (data_sk)
GROUP BY p.nome_produto, t.ano_mes
ORDER BY p.nome_produto, t.ano_mes;
