# Data Pipeline

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

| Tool | Version | Notes |
|------|---------|-------|
| [Python](https://www.python.org/downloads/) | 3.12+ | |
| [uv](https://docs.astral.sh/uv/getting-started/installation/) | latest | replaces pip/venv |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | latest | runs SQL Server |
| [Power BI Desktop](https://powerbi.microsoft.com/desktop/) | May 2026+ | PBIR format required |
| [ODBC Driver 18](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server) | 18 | SQL Server connection |

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

Edit `.env` — defaults match the included `docker-compose.yml`:

```env
MSSQL_HOST=localhost
MSSQL_PORT=1433
MSSQL_USER=sa
MSSQL_SA_PASSWORD=Pipeline123!
MSSQL_DB=analytics
```

### 3. Start SQL Server

```powershell
docker compose up -d
```

Wait ~15 seconds, then verify:

```powershell
docker compose ps   # STATUS should be "healthy"
```

### 4. Install dependencies

```powershell
uv sync
```

### 5. Run the pipeline

```powershell
# Load raw data
uv run python -m extract.run

# Transform to marts
$env:$(Get-Content .env | ForEach-Object { $_ }) 2>$null
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

Manual equivalents:

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
