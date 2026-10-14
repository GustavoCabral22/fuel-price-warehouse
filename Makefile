.PHONY: up down reset sample load analyses

up:            ## Sobe o PostgreSQL (o schema é criado automaticamente)
	docker compose up -d --wait

down:          ## Para o banco (mantém os dados)
	docker compose down

reset:         ## Apaga o banco e recomeça do zero
	docker compose down -v && docker compose up -d --wait

sample:        ## Carrega a amostra sintética (não precisa de internet)
	./scripts/load_raw.sh data/sample/anp_amostra_sintetica.csv

load:          ## Baixa e carrega um mês real da ANP: make load ANO=2025 MES=03
	./scripts/download_anp.sh $(ANO) $(MES)
	./scripts/load_raw.sh data/raw/ca-$(ANO)-$(MES).csv

analyses:      ## Roda todas as consultas analíticas
	@for f in sql/analysis/*.sql; do \
		echo "\n=== $$f"; \
		PGPASSWORD=postgres psql -h localhost -U postgres -d fuel_dw -f $$f; \
	done
