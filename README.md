# Data Pipeline

> **For local development and demo purposes only.**
> All data sources are public APIs. Credentials are intentionally simple defaults (`sa` / `Pipeline123!`).
> Do not use this setup with real data or expose it beyond your local machine.

End-to-end data pipeline: DLT ingestion → dbt transformations → Power BI PBIR report.

```
JSONPlaceholder API  ──┐
DummyJSON API          ├─► extract/ ──► SQL Server ──► transform/ ──► reports/
                       │     (DLT)       raw/dummyjson     (dbt)      marts/
```

**Data sources**
- [JSONPlaceholder](https://jsonplaceholder.typicode.com) — users, posts, comments, todos
- [DummyJSON](https://dummyjson.com) — products, users, carts, posts, todos, recipes

**Report pages**
- **Todos** — user engagement and todo completion rate
- **Products** — product ratings, pricing, brand and category breakdown
- **Cross Analysis** — spend vs completion, posts/likes per gender, department breakdown
- **Recept** — recipe cuisine, difficulty, time vs calories

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| [uv](https://docs.astral.sh/uv/getting-started/installation/) | latest | `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 \| iex"` |
| [ODBC Driver 18 for SQL Server](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server) | 18 | `winget install Microsoft.msodbcsql.18` |
| SQL Server | 2022 | Running locally on port 1433 (Docker or native) |
| [Power BI Desktop](https://powerbi.microsoft.com/desktop/) | May 2026+ | PBIR format required |

---

## Setup (PowerShell)

### 1. Clone

```powershell
git clone https://github.com/your-username/data-pipeline.git
cd data-pipeline
```

### 2. Configure environment

```powershell
Copy-Item .env.example .env
```

Edit `.env` with your SQL Server credentials:

```env
MSSQL_HOST=127.0.0.1
MSSQL_PORT=1433
MSSQL_USER=sa
MSSQL_SA_PASSWORD=Pipeline123!
MSSQL_DB=analytics
```

> **Windows note:** Use `127.0.0.1`, not `localhost`. Windows may resolve `localhost` to IPv6 (`::1`), causing connection timeouts even when SQL Server is running.

### 3. Start SQL Server (if using Docker)

```powershell
docker compose up -d
docker compose ps   # wait until STATUS is "healthy" (~15 s)
```

### 4. Install dependencies

```powershell
uv sync
```

### 5. Run the pipeline

```powershell
# Load raw data
uv run python -m extract.run

# Load .env into the shell (dbt needs env vars, it doesn't read .env automatically)
Get-Content .env | Where-Object { $_ -match "^[^#].*=.*" } | ForEach-Object {
    $k, $v = $_ -split "=", 2; Set-Item "Env:$k" $v
}

# Transform to marts
uv run dbt run --project-dir transform --profiles-dir .
```

Or use Make (if available):

```powershell
make pipeline   # runs load + transform in sequence
```

### 6. Open the report

Open `reports/todo-report.pbip` in Power BI Desktop.

On first open, Desktop prompts for SQL Server credentials — use the values from `.env`, server `localhost`.

After re-running the pipeline, refresh data in Desktop:
```
Home → Refresh
```

---

## Project structure

```
data-pipeline/
├── extract/                        # DLT ingestion layer
│   ├── __init__.py
│   ├── run.py                      # Pipeline entrypoint
│   ├── jsonplaceholder.py          # JSONPlaceholder source
│   └── dummyjson.py                # DummyJSON source (products/users/recipes…)
│
├── transform/                      # dbt transformation layer
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/                # Raw → cleaned views
│   │   └── marts/                  # Business-ready tables (fct_*, dim_*)
│   └── macros/
│
├── reports/                        # Power BI report (version-controlled PBIR)
│   ├── todo-report.pbip            # ← open this in Power BI Desktop
│   ├── todo-report.Report/         # Report layer (pages, visuals, theme)
│   ├── todo-report.SemanticModel/  # Semantic model (TMDL tables, measures)
│   └── Tema.json                   # Custom Bloom theme source
│
├── docker-compose.yml              # SQL Server container
├── profiles.yml                    # dbt connection profile
├── pyproject.toml                  # Python dependencies
├── Makefile                        # Common commands
├── .env.example                    # Environment variable template
└── CLAUDE.md                       # AI assistant instructions
```

---

## Common commands

```powershell
make setup      # First-time: copy .env, uv sync, start DB, create database
make up         # Start SQL Server
make load       # Run DLT pipeline (extract/)
make transform  # Run dbt models (transform/)
make pipeline   # load + transform in sequence
make down       # Stop SQL Server
```

Manual equivalents (dbt requires env vars loaded first — see step 5):

```powershell
uv run python -m extract.run
uv run dbt run --project-dir transform --profiles-dir .
uv run dbt run --project-dir transform --profiles-dir . --select fct_products
pbi report --path reports/todo-report.Report validate
```

---

## Known issues

See `CLAUDE.md` for full details. Short version:

- **`pbi report set-background`** writes broken JSON — write `page.json` directly instead
- **`pbi report set-theme`** writes wrong resource path — fix `report.json` after each use
- **Rounded corners / background colors** must be set in `visualContainerObjects` in each `visual.json`, not just in the theme JSON
- **Scatter chart bindings** (`--x`/`--y`) not supported in pbi-cli — write directly in `visual.json`
- **Measure names** must be globally unique across all tables in the model — prefix with table context (e.g. `Avg Product Rating`, not `Avg Rating`)
