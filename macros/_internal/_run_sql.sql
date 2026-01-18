{#
  Internal helper to execute SQL with adapter-specific handling.

  Databricks SQL Warehouse doesn't support multiple statements in a single
  query, so this macro splits SQL on semicolons and executes each statement.

  Args:
    sql (str): SQL to execute (may contain multiple statements)

  Returns:
    None (executes SQL)
#}

{% macro _run_sql(sql) %}
  {% if target.type == 'databricks' %}
    {# Replace hardcoded catalog name with actual target catalog #}
    {% set sql = sql.replace('origin_simulator_jaffle_corp', target.catalog) %}

    {# Split on semicolon and execute each statement separately #}
    {% set statements = sql.split(';') %}
    {% for stmt in statements %}
      {# Remove comments and whitespace #}
      {% set lines = [] %}
      {% for line in stmt.split('\n') %}
        {% if not line.strip().startswith('--') %}
          {% do lines.append(line) %}
        {% endif %}
      {% endfor %}
      {% set trimmed = '\n'.join(lines).strip() %}
      {% if trimmed %}
        {% do run_query(trimmed) %}
      {% endif %}
    {% endfor %}
  {% else %}
    {# For other adapters, execute as-is #}
    {% do run_query(sql) %}
  {% endif %}
{% endmacro %}
