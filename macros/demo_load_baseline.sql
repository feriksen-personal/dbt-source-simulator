{#
  Loads baseline schema and seed data into demo source databases.

  Initializes both jaffle_shop and jaffle_crm databases with:
  - Table schemas (customers, products, orders, order_items, campaigns, email_activity, web_sessions)
  - Baseline seed data (Day 0 - initial state)

  This operation is idempotent - tables are created with IF NOT EXISTS, and
  seed data can be safely reloaded (uses INSERT or MERGE depending on adapter).

  Usage:
    dbt run-operation demo_load_baseline --profile demo_source

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

{% macro demo_load_baseline() %}
  {% set cfg = demo_source_ops._get_config() %}

  {{ demo_source_ops._log("") }}
  {{ demo_source_ops._log("Loading baseline schema and data...") }}

  {# Load jaffle_shop schema #}
  {{ demo_source_ops._log("→ Creating jaffle_shop tables...") }}
  {% set shop_schema_sql = demo_source_ops._get_sql('baseline/shop_schema') %}
  {% do run_query(shop_schema_sql) %}
  {{ demo_source_ops._log("  ✓ Created jaffle_shop schema") }}

  {# Load jaffle_shop seed data #}
  {{ demo_source_ops._log("→ Loading jaffle_shop seed data...") }}
  {% set shop_seed_sql = demo_source_ops._get_sql('baseline/shop_seed') %}
  {% do run_query(shop_seed_sql) %}
  {{ demo_source_ops._log("  ✓ Loaded jaffle_shop seed data") }}

  {# Load jaffle_crm schema #}
  {{ demo_source_ops._log("→ Creating jaffle_crm tables...") }}
  {% set crm_schema_sql = demo_source_ops._get_sql('baseline/crm_schema') %}
  {% do run_query(crm_schema_sql) %}
  {{ demo_source_ops._log("  ✓ Created jaffle_crm schema") }}

  {# Load jaffle_crm seed data #}
  {{ demo_source_ops._log("→ Loading jaffle_crm seed data...") }}
  {% set crm_seed_sql = demo_source_ops._get_sql('baseline/crm_seed') %}
  {% do run_query(crm_seed_sql) %}
  {{ demo_source_ops._log("  ✓ Loaded jaffle_crm seed data") }}

  {{ demo_source_ops._log("") }}
  {{ demo_source_ops._log("✓ Baseline load complete!") }}

  {# Show final status #}
  {{ demo_source_ops.demo_status() }}
{% endmacro %}
