-- safe_divide
--
-- Divides numerator by denominator, returning null instead of raising a
-- division-by-zero error when the denominator is zero.
--
-- Usage:
--   {{ safe_divide('sum(line_total)', 'sum(quantity)') }}
--
-- Both DuckDB and Athena (Presto/Trino) support standard CASE WHEN syntax,
-- so this macro works on both targets without modification.

{% macro safe_divide(numerator, denominator) -%}
    {{ numerator }} / nullif({{ denominator }}, 0)
{%- endmacro %}
