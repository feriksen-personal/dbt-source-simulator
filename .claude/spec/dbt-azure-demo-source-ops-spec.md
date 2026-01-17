# dbt-azure-demo-source-ops

## Overview

A dbt package for managing demo source data in Azure SQL databases provisioned by [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data).

Provides simple dbt operations to load baseline data, apply deltas, and reset - all via standard `dbt run-operation` commands.

## Relationship to Infrastructure

```
┌─────────────────────────────────────────┐
│  dbt-azure-demo-source-data (Terraform) │
│  - Provisions Azure SQL Server          │
│  - Creates ecommerce_db, marketing_db   │
│  - Configures users, change tracking    │
│  - One-time infrastructure setup        │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│  dbt-azure-demo-source-ops (dbt package)│
│  - Loads/resets demo data               │
│  - Applies daily deltas                 │
│  - Used during demos and development    │
│  - Repeatable data operations           │
└─────────────────────────────────────────┘
```

---

## User Experience

### Installation

```yaml
# packages.yml
packages:
  - git: "https://github.com/feriksen-personal/dbt-azure-demo-source-ops"
    revision: v1.0.0
```

```bash
dbt deps
```

### Configuration

```yaml
# profiles.yml - Add demo source connection
demo_source:
  target: default
  outputs:
    default:
      type: sqlserver
      server: "{{ env_var('DEMO_SQL_SERVER') }}.database.windows.net"
      database: master
      user: "{{ env_var('DEMO_SQL_USER') }}"
      password: "{{ env_var('DEMO_SQL_PASSWORD') }}"
      encrypt: true
      trust_cert: false
```

```bash
# .env or shell
export DEMO_SQL_SERVER=myserver        # Without .database.windows.net
export DEMO_SQL_USER=sqladmin
export DEMO_SQL_PASSWORD=xxxxx
```

### Optional: Override Database Names

```yaml
# dbt_project.yml (only if you renamed the databases)
vars:
  demo_source_ops:
    ecommerce_db: 'my_ecommerce_db'
    marketing_db: 'my_marketing_db'
```

### Usage

```bash
# Initialize with baseline data
dbt run-operation demo_load_baseline --profile demo_source

# Check status
dbt run-operation demo_status --profile demo_source

# Apply deltas (day 1, 2, or 3)
dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source
dbt run-operation demo_apply_delta --args '{day: 2}' --profile demo_source
dbt run-operation demo_apply_delta --args '{day: 3}' --profile demo_source

# Reset to baseline
dbt run-operation demo_reset --profile demo_source
```

---

## Package Structure

```
dbt-azure-demo-source-ops/
├── dbt_project.yml
├── README.md
├── macros/
│   ├── demo_load_baseline.sql
│   ├── demo_apply_delta.sql
│   ├── demo_reset.sql
│   ├── demo_status.sql
│   └── _internal/
│       ├── _get_sql.sql
│       ├── _get_config.sql
│       └── _log.sql
├── data/
│   ├── baseline/
│   │   ├── ecommerce_schema.sql
│   │   ├── ecommerce_seed.sql
│   │   ├── marketing_schema.sql
│   │   └── marketing_seed.sql
│   ├── deltas/
│   │   ├── day_01_ecommerce.sql
│   │   ├── day_01_marketing.sql
│   │   ├── day_02_ecommerce.sql
│   │   ├── day_02_marketing.sql
│   │   ├── day_03_ecommerce.sql
│   │   └── day_03_marketing.sql
│   └── utilities/
│       ├── truncate_ecommerce.sql
│       └── truncate_marketing.sql
└── integration_tests/
    ├── dbt_project.yml
    └── profiles.yml.example
```

---

## Configuration

### Package dbt_project.yml

```yaml
name: 'demo_source_ops'
version: '1.0.0'
config-version: 2

require-dbt-version: [">=1.6.0", "<2.0.0"]

vars:
  demo_source_ops:
    ecommerce_db: 'ecommerce_db'
    marketing_db: 'marketing_db'
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DEMO_SQL_SERVER` | Yes | Azure SQL Server name (without .database.windows.net) |
| `DEMO_SQL_USER` | Yes | SQL admin username |
| `DEMO_SQL_PASSWORD` | Yes | SQL admin password |

### Project Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `demo_source_ops.ecommerce_db` | `ecommerce_db` | E-commerce database name |
| `demo_source_ops.marketing_db` | `marketing_db` | Marketing database name |

---

## Macro Specifications

### demo_load_baseline

Loads schema and seed data into both databases. Safe to run multiple times (idempotent schemas, truncate-then-load seeds).

```sql
{% macro demo_load_baseline() %}
  {% set cfg = _get_config() %}
  
  {{ _log("Loading baseline data...") }}
  
  {# E-commerce #}
  {{ _log("  → " ~ cfg.ecommerce_db ~ " schema") }}
  {% call statement('ecom_schema', fetch_result=False) %}
    USE {{ cfg.ecommerce_db }};
    {{ _get_sql('baseline/ecommerce_schema') }}
  {% endcall %}
  
  {{ _log("  → " ~ cfg.ecommerce_db ~ " seed") }}
  {% call statement('ecom_seed', fetch_result=False) %}
    USE {{ cfg.ecommerce_db }};
    {{ _get_sql('baseline/ecommerce_seed') }}
  {% endcall %}
  
  {# Marketing #}
  {{ _log("  → " ~ cfg.marketing_db ~ " schema") }}
  {% call statement('mktg_schema', fetch_result=False) %}
    USE {{ cfg.marketing_db }};
    {{ _get_sql('baseline/marketing_schema') }}
  {% endcall %}
  
  {{ _log("  → " ~ cfg.marketing_db ~ " seed") }}
  {% call statement('mktg_seed', fetch_result=False) %}
    USE {{ cfg.marketing_db }};
    {{ _get_sql('baseline/marketing_seed') }}
  {% endcall %}
  
  {{ _log("✓ Baseline loaded") }}
  {{ demo_status() }}
{% endmacro %}
```

### demo_apply_delta

Applies a specific day's changes (1, 2, or 3).

```sql
{% macro demo_apply_delta(day) %}
  {% set cfg = _get_config() %}
  
  {% if day not in [1, 2, 3] %}
    {{ exceptions.raise_compiler_error("day must be 1, 2, or 3") }}
  {% endif %}
  
  {{ _log("Applying Day " ~ day ~ " delta...") }}
  
  {{ _log("  → " ~ cfg.ecommerce_db) }}
  {% call statement('ecom_delta', fetch_result=False) %}
    USE {{ cfg.ecommerce_db }};
    {{ _get_sql('deltas/day_0' ~ day ~ '_ecommerce') }}
  {% endcall %}
  
  {{ _log("  → " ~ cfg.marketing_db) }}
  {% call statement('mktg_delta', fetch_result=False) %}
    USE {{ cfg.marketing_db }};
    {{ _get_sql('deltas/day_0' ~ day ~ '_marketing') }}
  {% endcall %}
  
  {{ _log("✓ Day " ~ day ~ " complete") }}
  {{ demo_status() }}
{% endmacro %}
```

### demo_reset

Truncates all tables and reloads baseline data.

```sql
{% macro demo_reset() %}
  {% set cfg = _get_config() %}
  
  {{ _log("Resetting to baseline...") }}
  
  {# Truncate #}
  {{ _log("  → Truncating " ~ cfg.ecommerce_db) }}
  {% call statement('trunc_ecom', fetch_result=False) %}
    USE {{ cfg.ecommerce_db }};
    {{ _get_sql('utilities/truncate_ecommerce') }}
  {% endcall %}
  
  {{ _log("  → Truncating " ~ cfg.marketing_db) }}
  {% call statement('trunc_mktg', fetch_result=False) %}
    USE {{ cfg.marketing_db }};
    {{ _get_sql('utilities/truncate_marketing') }}
  {% endcall %}
  
  {# Reload #}
  {{ demo_load_baseline() }}
{% endmacro %}
```

### demo_status

Shows row counts and change tracking version.

```sql
{% macro demo_status() %}
  {% set cfg = _get_config() %}
  
  {{ _log("") }}
  {{ _log("═══ Demo Source Status ═══") }}
  
  {# E-commerce counts #}
  {% call statement('ecom_counts', fetch_result=True) %}
    USE {{ cfg.ecommerce_db }};
    SELECT 
      (SELECT COUNT(*) FROM dbo.customers) as customers,
      (SELECT COUNT(*) FROM dbo.products) as products,
      (SELECT COUNT(*) FROM dbo.orders) as orders,
      (SELECT COUNT(*) FROM dbo.order_items) as order_items,
      (SELECT COUNT(*) FROM dbo.payments) as payments,
      CHANGE_TRACKING_CURRENT_VERSION() as ct_version
  {% endcall %}
  {% set ecom = load_result('ecom_counts')['data'][0] %}
  
  {{ _log(cfg.ecommerce_db ~ ":") }}
  {{ _log("  customers: " ~ ecom[0] ~ " | products: " ~ ecom[1] ~ " | orders: " ~ ecom[2]) }}
  {{ _log("  order_items: " ~ ecom[3] ~ " | payments: " ~ ecom[4]) }}
  {{ _log("  CT version: " ~ ecom[5]) }}
  
  {# Marketing counts #}
  {% call statement('mktg_counts', fetch_result=True) %}
    USE {{ cfg.marketing_db }};
    SELECT 
      (SELECT COUNT(*) FROM dbo.contacts) as contacts,
      (SELECT COUNT(*) FROM dbo.campaigns) as campaigns,
      (SELECT COUNT(*) FROM dbo.campaign_members) as members,
      (SELECT COUNT(*) FROM dbo.email_events) as events,
      (SELECT COUNT(*) FROM dbo.lead_scores) as scores,
      CHANGE_TRACKING_CURRENT_VERSION() as ct_version
  {% endcall %}
  {% set mktg = load_result('mktg_counts')['data'][0] %}
  
  {{ _log(cfg.marketing_db ~ ":") }}
  {{ _log("  contacts: " ~ mktg[0] ~ " | campaigns: " ~ mktg[1] ~ " | members: " ~ mktg[2]) }}
  {{ _log("  email_events: " ~ mktg[3] ~ " | lead_scores: " ~ mktg[4]) }}
  {{ _log("  CT version: " ~ mktg[5]) }}
  
  {{ _log("═══════════════════════════") }}
{% endmacro %}
```

---

## Internal Macros

### _get_config

Returns configuration dict from vars.

```sql
{% macro _get_config() %}
  {% set config = var('demo_source_ops', {}) %}
  {% do return({
    'ecommerce_db': config.get('ecommerce_db', 'ecommerce_db'),
    'marketing_db': config.get('marketing_db', 'marketing_db')
  }) %}
{% endmacro %}
```

### _get_sql

Loads SQL from data/ directory.

```sql
{% macro _get_sql(path) %}
  {% set sql = load_file_contents('data/' ~ path ~ '.sql') %}
  {% if sql is none %}
    {{ exceptions.raise_compiler_error("SQL file not found: data/" ~ path ~ ".sql") }}
  {% endif %}
  {{ return(sql) }}
{% endmacro %}
```

### _log

Wrapper for consistent logging.

```sql
{% macro _log(msg) %}
  {{ log(msg, info=True) }}
{% endmacro %}
```

---

## SQL Files

SQL files in `data/` are identical to those in the infrastructure repo, but stored here for package portability.

See infrastructure repo specs for detailed SQL content:
- `specs/03_database_configuration.md` - Schema definitions
- `specs/04_seed_data.md` - Baseline data
- `specs/05_delta_scripts.md` - Delta scripts

---

## GitHub Issues for This Package

### Phase 1: Package Scaffolding

**Issue 1: Initialize package structure**
- dbt_project.yml
- README.md
- Directory structure
- .gitignore

**Issue 2: Create internal helper macros**
- _get_config.sql
- _get_sql.sql
- _log.sql

### Phase 2: Core Operations

**Issue 3: Implement demo_load_baseline**
- Load schema and seed for both databases
- Call demo_status at end

**Issue 4: Implement demo_apply_delta**
- Accept day parameter (1-3)
- Validate input
- Apply both database deltas

**Issue 5: Implement demo_reset**
- Truncate all tables
- Reload baseline

**Issue 6: Implement demo_status**
- Row counts per table
- CT version display

### Phase 3: SQL Content

**Issue 7: Add baseline SQL files**
- ecommerce_schema.sql
- ecommerce_seed.sql
- marketing_schema.sql
- marketing_seed.sql

**Issue 8: Add delta SQL files**
- day_01_ecommerce.sql, day_01_marketing.sql
- day_02_ecommerce.sql, day_02_marketing.sql
- day_03_ecommerce.sql, day_03_marketing.sql

**Issue 9: Add utility SQL files**
- truncate_ecommerce.sql
- truncate_marketing.sql

### Phase 4: Documentation & Testing

**Issue 10: Write comprehensive README**
- Installation
- Configuration
- Usage examples
- Troubleshooting

**Issue 11: Add integration tests**
- Test project structure
- profiles.yml.example
- CI workflow

---

## Testing

### Local Testing

```bash
# Set up test environment
export DEMO_SQL_SERVER=your-server
export DEMO_SQL_USER=sqladmin
export DEMO_SQL_PASSWORD=yourpassword

# Run operations
cd integration_tests
dbt deps
dbt run-operation demo_load_baseline --profile demo_source
dbt run-operation demo_status --profile demo_source
dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source
dbt run-operation demo_reset --profile demo_source
```

### CI Testing

GitHub Actions workflow that:
1. Provisions test Azure SQL (or uses existing)
2. Runs all operations in sequence
3. Verifies row counts match expected

---

## Definition of Done

- [ ] Package installs via `dbt deps`
- [ ] All four operations work correctly
- [ ] README provides clear setup instructions
- [ ] Integration tests pass
- [ ] Works with dbt 1.6+
- [ ] Works with dbt-sqlserver adapter
