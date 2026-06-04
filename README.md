# Data Pipeline

End-to-end data pipeline with DLT ingestion, dbt transformations and a Power BI PBIR report.

```
JSONPlaceholder API  ──┐
DummyJSON API          ├─► DLT ──► SQL Server ──► dbt ──► marts ──► Power BI
                       │
                    (raw schema)              (marts schema)
```

**Data sources**
- [JSONPlaceholder](https://jsonplaceholder.typicode.com) — users, posts, comments, todos
- [DummyJSON](https://dummyjson.com) — products, users, carts, posts, todos, recipes

**Report pages**
- **Todos** — user engagement, todo completion rate
- **Products** — product ratings, pricing, brand/category breakdown
- **Cross Analysis** — spend vs completion, posts/likes per gender, dept breakdown
- **Recept** — recipe cuisine, difficulty, time vs calories scatter

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| [Python](https://www.python.org/downloads/) | 3.12+ | |
| [uv](https://docs.astral.sh/uv/getting-started/installation/) | latest | replaces pip/venv |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | latest | runs SQL Server |
| [Power BI Desktop](https://powerbi.microsoft.com/desktop/) | May 2026+ | PBIR format required |
| [ODBC Driver 18](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server) | 18 | for SQL Server connection |

---

## Setup (PowerShell)

### 1. Clone and enter the repo

```powershell
git clone https://github.com/your-username/data-pipeline.git
cd data-pipeline
```

### 2. Configure environment

```powershell
Copy-Item .env.example .env
```

Open `.env` and set your values (defaults work with the included `docker-compose.yml`):

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

Wait ~15 seconds for the container to become healthy:

```powershell
docker compose ps   # STATUS should show "healthy"
```

### 4. Install Python dependencies

```powershell
uv sync
```

This creates a `.venv/` and installs all dependencies from `pyproject.toml`.

### 5. Run the data pipeline

```powershell
uv run python main.py
```

This runs two DLT pipelines:
- `jsonplaceholder` → loads into `raw` schema
- `dummyjson` → loads into `dummyjson` schema

### 6. Run dbt transformations

```powershell
uv run --env-file .env dbt run --profiles-dir . --project-dir dbt
```

This builds all models in the `marts` schema:

| Model | Description |
|-------|-------------|
| `dim_users` | User dimension from JSONPlaceholder |
| `fct_posts` | Posts with comment counts |
| `fct_user_engagement` | Per-user todo + post engagement |
| `fct_products` | DummyJSON products (brand-filtered) |
| `fct_user_activity` | Cross-source: spend + posts + todos per user |
| `fct_recipes` | Recipes with derived total_calories |

### 7. Open the report

Open `report/todo-report.pbip` in Power BI Desktop.

On first open, Desktop will prompt for SQL Server credentials — use the same values as in `.env` with server `localhost`.

To refresh data after re-running the pipeline:

```
Home → Refresh
```

---

## Project structure

```
data-pipeline/
├── pipeline/                  # DLT source definitions
│   ├── jsonplaceholder.py     # JSONPlaceholder API (users/posts/comments/todos)
│   └── dummyjson.py           # DummyJSON API (products/users/carts/posts/todos/recipes)
├── dbt/                       # dbt project
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/           # Raw → cleaned views
│   │   └── marts/             # Business-ready tables
│   ├── macros/
│   └── profiles.yml           # (in repo root, not here)
├── report/                    # Power BI PBIR report (version-controlled JSON)
│   ├── todo-report.pbip       # Open this in Power BI Desktop
│   ├── todo-report.Report/    # Report layer (pages, visuals, theme)
│   ├── todo-report.SemanticModel/  # Semantic model (TMDL tables, measures)
│   └── Tema.json              # Custom Bloom theme source file
├── main.py                    # Pipeline entrypoint
├── docker-compose.yml         # SQL Server + pgAdmin
├── profiles.yml               # dbt connection profile
├── pyproject.toml             # Python dependencies
├── .env.example               # Environment variable template
└── CLAUDE.md                  # AI assistant instructions and lessons learned
```

---

## Common commands

```powershell
# Run everything in sequence
docker compose up -d
uv run python main.py
uv run --env-file .env dbt run --profiles-dir . --project-dir dbt

# Validate the Power BI report structure
uv run --env-file .env pbi report --path report/todo-report.Report validate

# Run only specific dbt models
uv run --env-file .env dbt run --profiles-dir . --project-dir dbt --select fct_products

# Check what's in the database
uv run --env-file .env dbt show --profiles-dir . --project-dir dbt --select fct_user_activity
```

---

## Known issues / quirks

See `CLAUDE.md` for a full list of Power BI + pbi-cli lessons learned during development.

Short version:
- Never use `pbi report set-background` — it writes broken JSON
- `pbi report set-theme` has a path bug — fix `report.json` after each use
- Rounded corners and background colors must be set in `visualContainerObjects` in each `visual.json`, not just in the theme
- Scatter chart bindings (`--x`/`--y`) are not supported in pbi-cli — write them directly in `visual.json`
- Measure names must be unique across all tables in the model — prefix with table context
