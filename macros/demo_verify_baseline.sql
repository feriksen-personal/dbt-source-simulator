{#
  Verifies baseline data was loaded correctly.

  Checks that all tables exist and contain the expected number of rows.
  Outputs a formatted test results table with pass/fail status.

  This is primarily used in CI/CD testing to validate operations.

  Usage:
    dbt run-operation demo_verify_baseline --profile demo_source

  Example output:
    ╔════════════════════════════════════════════════════════╗
    ║ Test Results                                           ║
    ╠════════════════════════════════════════════════════════╣
    ║ Database.Table          │ Expected │ Actual │ Status   ║
    ╟────────────────────────────────────────────────────────╢
    ║ jaffle_shop.customers   │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_shop.products    │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_shop.orders      │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_shop.order_items │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_crm.campaigns    │       3  │     3  │ ✓ PASS   ║
    ║ jaffle_crm.email_activ… │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_crm.web_sessions │       5  │     5  │ ✓ PASS   ║
    ╚════════════════════════════════════════════════════════╝
    ✓ All tests passed
#}

{% macro demo_verify_baseline() %}
  {# Expected baseline counts #}
  {% set expected_counts = {
    'jaffle_shop.customers': 5,
    'jaffle_shop.products': 5,
    'jaffle_shop.orders': 5,
    'jaffle_shop.order_items': 5,
    'jaffle_crm.campaigns': 3,
    'jaffle_crm.email_activity': 5,
    'jaffle_crm.web_sessions': 5
  } %}

  {{ demo_source_ops._verify_test_results(expected_counts) }}
{% endmacro %}
