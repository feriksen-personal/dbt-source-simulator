# Scripts

Automation scripts for the dbt-source-simulator package.

---

## ERD Generation Pipeline

Automated Entity-Relationship Diagram (ERD) generation from SQL DDL files.

### Overview

The ERD generation pipeline automatically creates visual schema diagrams from SQL source files and keeps them synchronized in the GitHub wiki.

```
SQL DDL Files → DBML Format → ERD Images → GitHub Wiki
```

### Components

#### 1. SQL-to-DBML Parser (`sql_to_dbml.py`)

Parses SQL DDL files and converts them to DBML (Database Markup Language) format.

**Features:**
- Extracts table definitions, columns, data types
- Identifies primary keys and foreign key relationships
- Preserves inline comments as notes
- Handles DuckDB/Postgres SQL syntax
- Outputs clean DBML for diagram generation

**Usage:**

```bash
# Generate DBML for jaffle_shop schema
python scripts/sql_to_dbml.py data/duckdb/baseline/shop_schema.sql > docs/generated/jaffle-shop.dbml

# Generate DBML for jaffle_crm schema
python scripts/sql_to_dbml.py data/duckdb/baseline/crm_schema.sql > docs/generated/jaffle-crm.dbml
```

**Example Output:**

```dbml
Table jaffle_shop.customers [note: 'Customers table'] {
  customer_id INTEGER [pk]
  first_name VARCHAR(50)
  last_name VARCHAR(50)
  email VARCHAR(100)
  created_at TIMESTAMP [not null] [default: CURRENT_TIMESTAMP]
  deleted_at TIMESTAMP [note: 'NULL = active, non-NULL = soft deleted']
}

Ref: jaffle_shop.orders.customer_id > jaffle_shop.customers.customer_id
```

#### 2. GitHub Actions Workflow (`.github/workflows/generate-schema-diagrams.yml`)

Automates the complete ERD generation and wiki update process.

**Triggers:**

- Push to `main` branch when SQL schema files change
- Manual workflow dispatch

**Steps:**

1. Parse SQL DDL files → DBML format (temporary)
2. Generate SVG diagrams using `@dbml/cli`
3. Clone wiki repository
4. Copy ERD images to wiki
5. Commit and push wiki changes

**Outputs:**

- `docs/generated/*.dbml` - Temporary files (not committed, in .gitignore)
- `wiki/images/jaffle-shop-erd.svg` - Pushed to wiki repo
- `wiki/images/jaffle-crm-erd.svg` - Pushed to wiki repo

### Viewing ERDs

ERDs are automatically embedded in the [Data Schemas wiki page](https://github.com/feriksen-personal/dbt-source-simulator/wiki/Data-Schemas).

**Direct image URLs:**
- [jaffle_shop ERD](https://github.com/feriksen-personal/dbt-source-simulator/wiki/images/jaffle-shop-erd.svg)
- [jaffle_crm ERD](https://github.com/feriksen-personal/dbt-source-simulator/wiki/images/jaffle-crm-erd.svg)

### Local Development

**Prerequisites:**
```bash
# Install Node.js and npm
# Then install DBML CLI
npm install -g @dbml/cli
```

**Generate diagrams locally:**

```bash
# 1. Generate DBML from SQL
python scripts/sql_to_dbml.py data/duckdb/baseline/shop_schema.sql > docs/generated/jaffle-shop.dbml
python scripts/sql_to_dbml.py data/duckdb/baseline/crm_schema.sql > docs/generated/jaffle-crm.dbml

# 2. Generate SVG from DBML
mkdir -p wiki/images
dbml2svg docs/generated/jaffle-shop.dbml -o wiki/images/jaffle-shop-erd.svg
dbml2svg docs/generated/jaffle-crm.dbml -o wiki/images/jaffle-crm-erd.svg

# 3. View SVG files in browser
open wiki/images/jaffle-shop-erd.svg
```

### Adding New Schemas

To add ERD generation for a new schema:

1. **Create SQL DDL file:**
   ```sql
   -- data/duckdb/baseline/new_schema.sql
   CREATE TABLE IF NOT EXISTS new_db.new_table (
       id INTEGER PRIMARY KEY,
       name VARCHAR(100)
   );
   ```

2. **Update GitHub Actions workflow:**
   ```yaml
   - name: Generate DBML from SQL
     run: |
       python3 scripts/sql_to_dbml.py data/duckdb/baseline/new_schema.sql > docs/generated/new-schema.dbml

   - name: Generate ERD images from DBML
     run: |
       dbml2svg docs/generated/new-schema.dbml -o wiki/images/new-schema-erd.svg
   ```

3. **Update wiki page** to reference new ERD image

### Troubleshooting

**Issue: "npm: command not found" in local development**
- Install Node.js from https://nodejs.org/
- Or use `nvm install node` if using nvm

**Issue: Workflow fails with "wiki repository not found"**
- Ensure the GitHub wiki is initialized (create at least one page manually)
- Wiki repos are separate: `https://github.com/user/repo.wiki.git`

**Issue: SQL parsing errors**
- Ensure SQL files follow standard DDL syntax
- Check for unsupported syntax (stored procedures, triggers, etc.)
- Parser supports: CREATE TABLE, PRIMARY KEY, FOREIGN KEY, column constraints

**Issue: Diagram not updating in wiki**
- Check GitHub Actions workflow run for errors
- Ensure SQL files are in `data/duckdb/baseline/` or `data/azure/baseline/`
- Workflow only triggers on `main` branch by default

### Schema Evolution

When schema changes are made:

1. Update SQL DDL file in `data/duckdb/baseline/` or `data/azure/baseline/`
2. Commit and push to `main` branch
3. GitHub Actions automatically:
   - Regenerates DBML
   - Regenerates ERD images
   - Updates wiki with new diagrams
4. Changes are visible in wiki immediately

### Design Philosophy

**Why DBML?**
- Text-based, version-controllable schema representation
- Widely supported format (dbdiagram.io, dbdocs.io)
- Clean separation: SQL → DBML → Visual

**Why commit DBML but not images to main repo?**
- DBML is source-controlled documentation
- Images are generated artifacts (belong in wiki)
- Keeps main repo clean and focused on code

**Why GitHub Actions?**
- Ensures diagrams always match SQL source
- No manual diagram maintenance
- Automatic wiki updates on schema changes

---

## Future Enhancements

### dbt Model Constraints ERD (Planned)

Generate ERDs from dbt model `schema.yml` files using the `constraints:` property:

```yaml
models:
  - name: dim_customer
    columns:
      - name: customer_sk
        constraints:
          - type: primary_key
      - name: source_customer_id
        constraints:
          - type: foreign_key
            to: ref('stg_customers')
            to_columns: [customer_id]
```

This would generate a "dbt Models ERD" showing relationships in the transformed data layer.

---

**Related:** [Issue #45](https://github.com/feriksen-personal/dbt-source-simulator/issues/45) - ERD Automation
