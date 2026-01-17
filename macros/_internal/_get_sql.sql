{#
  Internal helper macro to load SQL files with adapter detection.

  Automatically routes to the correct SQL directory based on the current
  target adapter type (duckdb vs sqlserver).

  Args:
    path (str): Relative path to SQL file within the adapter directory,
                without .sql extension. Examples:
                - 'baseline/shop_schema'
                - 'deltas/day_01_shop'
                - 'utilities/truncate_crm'

  Returns:
    str: Contents of the SQL file

  Raises:
    Compilation error if file not found

  Example usage:
    {% set sql = demo_source_ops._get_sql('baseline/shop_schema') %}
    {% do run_query(sql) %}

  File structure:
    data/
      ├── duckdb/
      │   ├── baseline/shop_schema.sql
      │   └── deltas/day_01_shop.sql
      └── azure/
          ├── baseline/shop_schema.sql
          └── deltas/day_01_shop.sql
#}

{% macro _get_sql(path) %}
  {# Route to adapter-specific SQL macros #}
  {% if target.type == 'duckdb' %}
    {% if path == 'baseline/shop_schema' %}
      {{ return(demo_source_ops._get_duckdb_baseline_shop_schema()) }}
    {% elif path == 'baseline/shop_seed' %}
      {{ return(demo_source_ops._get_duckdb_baseline_shop_seed()) }}
    {% elif path == 'baseline/crm_schema' %}
      {{ return(demo_source_ops._get_duckdb_baseline_crm_schema()) }}
    {% elif path == 'baseline/crm_seed' %}
      {{ return(demo_source_ops._get_duckdb_baseline_crm_seed()) }}
    {% elif path == 'utilities/truncate_shop' %}
      {{ return(demo_source_ops._get_duckdb_utilities_truncate_shop()) }}
    {% elif path == 'utilities/truncate_crm' %}
      {{ return(demo_source_ops._get_duckdb_utilities_truncate_crm()) }}
    {% else %}
      {{ exceptions.raise_compiler_error("Unknown DuckDB SQL path: " ~ path) }}
    {% endif %}
  {% else %}
    {# Azure SQL - to be implemented later #}
    {{ exceptions.raise_compiler_error("Azure SQL adapter not yet implemented") }}
  {% endif %}
{% endmacro %}
