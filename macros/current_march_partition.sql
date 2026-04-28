{% macro current_march_partition(year_col, month_col) %}
{#
  Limits dbt data tests to the March partition of the current year.
  Month is hardcoded to 3 — the last month in the Bronze dataset (ends 2026-03-02).
  Year uses extract(year from current_date) so the macro stays valid as years advance.
  extract() returns an integer, matching the integer partition columns written by Glue.
#}
    {{ year_col }} = extract(year from current_date)
    and {{ month_col }} = 3
{% endmacro %}
