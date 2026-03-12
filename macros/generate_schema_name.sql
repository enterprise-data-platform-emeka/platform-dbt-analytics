-- generate_schema_name
--
-- Override dbt's default schema naming behaviour.
--
-- dbt's default appends the target schema and custom schema together:
--   e.g. target.schema=main, custom_schema_name=gold -> main_gold
--
-- That works fine for some setups, but for this platform we want exact schema
-- names that match the Glue Catalog database names:
--   - staging models  -> schema: silver  (reads from Silver, writes views there)
--   - mart models     -> schema: gold    (writes Gold tables)
--   - no custom_schema (intermediate, ephemeral) -> uses target.schema as-is
--
-- With this override, `custom_schema_name` is used as the literal schema name
-- with no prefix appended. If no custom schema is set, the target default schema
-- is used unchanged.

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
