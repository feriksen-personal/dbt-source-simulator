{#
  Applies delta changes to demo source databases.

  Simulates business activity by applying incremental changes for a specific day.
  Use this to progress through demo scenarios showing how data evolves over time.

  Args:
    day (int): Day number (1, 2, or 3) - which delta to apply

  Usage:
    dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source
    dbt run-operation demo_apply_delta --args '{day: 2}' --profile demo_source
    dbt run-operation demo_apply_delta --args '{day: 3}' --profile demo_source

  Example output:
    Applying Day 01 delta changes...
    → Applying jaffle_shop delta...
      ✓ Applied jaffle_shop delta
    → Applying jaffle_crm delta...
      ✓ Applied jaffle_crm delta

    ═══ Demo Source Status ═══
    jaffle_shop:
      customers: 30 | products: 10 | orders: 65
      order_items: 120

    jaffle_crm:
      campaigns: 5 | email_activity: 45
      web_sessions: 35
    ══════════════════════════
#}

{% macro demo_apply_delta(day) %}
  {% set cfg = demo_source_ops._get_config() %}

  {# Validate day parameter #}
  {% if day is none %}
    {{ exceptions.raise_compiler_error("Parameter 'day' is required. Usage: dbt run-operation demo_apply_delta --args '{day: 1}'") }}
  {% endif %}

  {% if day not in [1, 2, 3] %}
    {{ exceptions.raise_compiler_error("Parameter 'day' must be 1, 2, or 3. Got: " ~ day) }}
  {% endif %}

  {# Format day as zero-padded string (01, 02, 03) #}
  {% set day_str = '0' ~ day|string %}

  {{ demo_source_ops._log("") }}
  {{ demo_source_ops._log("Applying Day " ~ day_str ~ " delta changes...") }}

  {# Apply shop delta #}
  {{ demo_source_ops._log("→ Applying jaffle_shop delta...") }}
  {% set shop_delta_sql = demo_source_ops._get_sql('deltas/day_' ~ day_str ~ '_shop') %}
  {% do run_query(shop_delta_sql) %}
  {{ demo_source_ops._log("  ✓ Applied jaffle_shop delta") }}

  {# Apply CRM delta #}
  {{ demo_source_ops._log("→ Applying jaffle_crm delta...") }}
  {% set crm_delta_sql = demo_source_ops._get_sql('deltas/day_' ~ day_str ~ '_crm') %}
  {% do run_query(crm_delta_sql) %}
  {{ demo_source_ops._log("  ✓ Applied jaffle_crm delta") }}

  {{ demo_source_ops._log("") }}

  {# Show updated status #}
  {{ demo_source_ops.demo_status() }}
{% endmacro %}
