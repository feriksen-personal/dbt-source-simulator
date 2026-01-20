{#
  Loads baseline schema and seed data into demo source databases.

  Initializes both jaffle_shop and jaffle_crm databases with:
  - Table schemas (customers, products, orders, order_items, campaigns, email_activity, web_sessions)
  - Baseline seed data (Day 0 - initial state)

  This operation is idempotent - tables are created with IF NOT EXISTS, and
  seed data can be safely reloaded (uses INSERT or MERGE depending on adapter).

  Usage:
    dbt run-operation origin_load_baseline --profile ingestion_simulator

  Example output:
    Loading baseline schema and data...
    ✓ Created jaffle_shop schema
    ✓ Loaded jaffle_shop seed data
    ✓ Created jaffle_crm schema
    ✓ Loaded jaffle_crm seed data

    ═══ Demo Source Status ═══
    jaffle_shop:
      customers: 5 | products: 5 | orders: 5
      order_items: 5

    jaffle_crm:
      campaigns: 3 | email_activity: 5
      web_sessions: 5
    ══════════════════════════
#}

{% macro origin_load_baseline() %}
  {% set cfg = dbt_source_simulator._get_config() %}

  {{ dbt_source_simulator._log("") }}
  {{ dbt_source_simulator._log("Loading baseline schema and data...") }}

  {# Load jaffle_shop schema #}
  {{ dbt_source_simulator._log("→ Creating jaffle_shop tables...") }}
  {% set shop_schema_sql = dbt_source_simulator._get_sql('baseline/shop_schema') %}
  {% do dbt_source_simulator._run_sql(shop_schema_sql) %}
  {{ dbt_source_simulator._log("  ✓ Created jaffle_shop schema") }}

  {# Load jaffle_shop seed data - table by table in FK order #}
  {{ dbt_source_simulator._log("→ Loading jaffle_shop seed data...") }}

  {# Customers (no dependencies) #}
  {% set customers_sql = dbt_source_simulator._get_sql('baseline/shop_customers') %}
  {% do dbt_source_simulator._run_sql(customers_sql) %}
  {{ dbt_source_simulator._log("  ✓ Loaded customers (100 rows)") }}

  {# Products (no dependencies) #}
  {% set products_sql = dbt_source_simulator._get_sql('baseline/shop_products') %}
  {% do dbt_source_simulator._run_sql(products_sql) %}
  {{ dbt_source_simulator._log("  ✓ Loaded products (20 rows)") }}

  {# Orders (depends on customers) #}
  {% set orders_sql = dbt_source_simulator._get_sql('baseline/shop_orders') %}
  {% do dbt_source_simulator._run_sql(orders_sql) %}
  {{ dbt_source_simulator._log("  ✓ Loaded orders (500 rows)") }}

  {# Order items (depends on orders and products) #}
  {% set order_items_sql = dbt_source_simulator._get_sql('baseline/shop_order_items') %}
  {% do dbt_source_simulator._run_sql(order_items_sql) %}
  {{ dbt_source_simulator._log("  ✓ Loaded order_items (1200 rows)") }}

  {# Load jaffle_crm schema #}
  {{ dbt_source_simulator._log("→ Creating jaffle_crm tables...") }}
  {% set crm_schema_sql = dbt_source_simulator._get_sql('baseline/crm_schema') %}
  {% do dbt_source_simulator._run_sql(crm_schema_sql) %}
  {{ dbt_source_simulator._log("  ✓ Created jaffle_crm schema") }}

  {# Load jaffle_crm seed data - table by table in FK order #}
  {{ dbt_source_simulator._log("→ Loading jaffle_crm seed data...") }}

  {# Campaigns (no dependencies) #}
  {% set campaigns_sql = dbt_source_simulator._get_sql('baseline/crm_campaigns') %}
  {% do dbt_source_simulator._run_sql(campaigns_sql) %}
  {{ dbt_source_simulator._log("  ✓ Loaded campaigns (5 rows)") }}

  {# Email activity (depends on campaigns) #}
  {% set email_activity_sql = dbt_source_simulator._get_sql('baseline/crm_email_activity') %}
  {% do dbt_source_simulator._run_sql(email_activity_sql) %}
  {{ dbt_source_simulator._log("  ✓ Loaded email_activity (100 rows)") }}

  {# Web sessions (no FK dependencies) #}
  {% set web_sessions_sql = dbt_source_simulator._get_sql('baseline/crm_web_sessions') %}
  {% do dbt_source_simulator._run_sql(web_sessions_sql) %}
  {{ dbt_source_simulator._log("  ✓ Loaded web_sessions (150 rows)") }}

  {{ dbt_source_simulator._log("") }}
  {{ dbt_source_simulator._log("✓ Baseline load complete!") }}

  {# Show final status #}
  {{ dbt_source_simulator.origin_status() }}
{% endmacro %}
