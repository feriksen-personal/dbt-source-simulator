{#
  Internal helper to verify test results and output formatted table.

  Queries actual row counts and compares against expected values.
  Outputs a formatted table with pass/fail indicators.

  Args:
    expected_counts (dict): Expected row counts by table
      Example: {
        'jaffle_shop.customers': 5,
        'jaffle_shop.products': 5,
        'jaffle_crm.campaigns': 3
      }

  Returns:
    Boolean: True if all counts match, False otherwise

  Example output:
    ╔════════════════════════════════════════════════════════╗
    ║ Test Results                                           ║
    ╠════════════════════════════════════════════════════════╣
    ║ Database.Table          │ Expected │ Actual │ Status   ║
    ╟────────────────────────────────────────────────────────╢
    ║ jaffle_shop.customers   │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_shop.products    │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_crm.campaigns    │       3  │     3  │ ✓ PASS   ║
    ╚════════════════════════════════════════════════════════╝
#}

{% macro _verify_test_results(expected_counts) %}
  {% set cfg = demo_source_ops._get_config() %}
  {% set all_passed = true %}
  {% set results = [] %}

  {# Query actual counts #}
  {% for table_name, expected_count in expected_counts.items() %}
    {% set parts = table_name.split('.') %}
    {% set db = parts[0] %}
    {% set table = parts[1] %}

    {% set query %}
      SELECT COUNT(*) as count FROM {{ db }}.{{ table }}
    {% endset %}

    {% set result = run_query(query) %}
    {% if execute %}
      {% set actual_count = result.rows[0][0] %}
      {% set passed = (actual_count == expected_count) %}
      {% if not passed %}
        {% set all_passed = false %}
      {% endif %}

      {% do results.append({
        'table': table_name,
        'expected': expected_count,
        'actual': actual_count,
        'passed': passed
      }) %}
    {% endif %}
  {% endfor %}

  {# Output formatted table #}
  {{ demo_source_ops._log("") }}
  {{ demo_source_ops._log("╔════════════════════════════════════════════════════════╗") }}
  {{ demo_source_ops._log("║ Test Results                                           ║") }}
  {{ demo_source_ops._log("╠════════════════════════════════════════════════════════╣") }}
  {{ demo_source_ops._log("║ Database.Table          │ Expected │ Actual │ Status   ║") }}
  {{ demo_source_ops._log("╟────────────────────────────────────────────────────────╢") }}

  {% for result in results %}
    {% set status = "✓ PASS" if result.passed else "✗ FAIL" %}
    {% set table_padded = (result.table ~ "                       ")[:23] %}
    {% set expected_padded = ("%8d" % result.expected) %}
    {% set actual_padded = ("%6d" % result.actual) %}
    {{ demo_source_ops._log("║ " ~ table_padded ~ " │ " ~ expected_padded ~ " │ " ~ actual_padded ~ " │ " ~ status ~ "   ║") }}
  {% endfor %}

  {{ demo_source_ops._log("╚════════════════════════════════════════════════════════╝") }}
  {{ demo_source_ops._log("") }}

  {% if all_passed %}
    {{ demo_source_ops._log("✓ All tests passed") }}
  {% else %}
    {{ demo_source_ops._log("✗ Some tests failed") }}
    {{ exceptions.raise_compiler_error("Test verification failed - row counts do not match expected values") }}
  {% endif %}

  {{ return(all_passed) }}
{% endmacro %}
