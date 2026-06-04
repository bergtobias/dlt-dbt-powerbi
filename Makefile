.PHONY: setup up down load transform pipeline

setup:
	@[ -f .env ] || cp .env.example .env
	uv sync
	docker compose up -d
	@echo "Waiting for SQL Server..."
	@until docker exec data_pipeline_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$$(grep MSSQL_SA_PASSWORD .env | cut -d= -f2)" -Q "SELECT 1" -No 2>/dev/null; do sleep 2; done
	@docker exec data_pipeline_db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$$(grep MSSQL_SA_PASSWORD .env | cut -d= -f2)" -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'analytics') CREATE DATABASE [analytics]" -No
	@echo "Ready. DB on localhost:1433"

up:
	docker compose up -d

down:
	docker compose down

load:
	uv run main.py

transform:
	set -a && . ./.env && set +a && uv run dbt run --project-dir dbt --profiles-dir .

pipeline: load transform
