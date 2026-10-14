# Modelo de dados

```mermaid
erDiagram
    dim_tempo ||--o{ fato_preco_combustivel : data_sk
    dim_produto ||--o{ fato_preco_combustivel : produto_sk
    dim_localidade ||--o{ fato_preco_combustivel : localidade_sk
    dim_revenda ||--o{ fato_preco_combustivel : revenda_sk

    fato_preco_combustivel {
        int data_sk PK
        int produto_sk PK
        int revenda_sk PK
        int localidade_sk FK
        numeric valor_venda
        numeric valor_compra
    }
    dim_tempo {
        int data_sk PK
        date data
        smallint ano
        smallint mes
        char ano_mes
        boolean fim_de_semana
    }
    dim_produto {
        int produto_sk PK
        text nome_produto
        text unidade_medida
    }
    dim_localidade {
        int localidade_sk PK
        text regiao_sigla
        char uf_sigla
        text municipio
    }
    dim_revenda {
        int revenda_sk PK
        text cnpj
        text nome_revenda
        text bandeira
    }
```

## Decisões de modelagem

| Decisão | Motivo |
|---|---|
| **Grão:** 1 linha por produto, posto e dia | É o menor nível que a ANP publica. Agregar depois é fácil; desagregar é impossível. |
| **Camada `raw` toda em texto** | A carga nunca falha por causa de um valor mal formatado. A limpeza fica na transformação, onde dá para tratar. |
| **Chaves substitutas (`_sk`)** | Desacopla o warehouse das chaves da fonte e deixa os joins em inteiros. |
| **`dim_tempo` gerada, não carregada** | Garante todos os dias do calendário, inclusive os sem coleta. |
| **`localidade` separada de `revenda`** | Muitas análises são por município/UF e não precisam passar pela dimensão de postos. |
| **`dim_revenda` como SCD tipo 1** | Simples. Se o posto trocar de bandeira, o histórico se perde: a evolução natural é SCD tipo 2. |
| **`ON CONFLICT` em todas as cargas** | Rodar a mesma carga duas vezes dá o mesmo resultado (idempotência). |
