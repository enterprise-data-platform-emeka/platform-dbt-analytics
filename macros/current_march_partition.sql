{% macro current_march_partition(year_col, month_col) %}
{#
  Limits dbt data tests to the March partition of the current year.
  Month is hardcoded to 3 — the last month in the Bronze dataset (ends 2026-03-02).
  Year uses extract(year from current_date) so the macro stays valid as years advance.
  extract() returns an integer, matching the integer partition columns written by Glue.

  Note: dbt does not make custom project macros available when rendering the
  `where` config value in YAML properties files. The config is resolved during
  property parsing before the macro index is fully loaded. For this reason the
  WHERE expressions in _staging.yml and _finance.yml are written as inline SQL
  rather than calling this macro. This macro is kept as a single source of
  truth for the expression logic and for use in model SQL files if needed.
#}
    {{ year_col }} = extract(year from current_date)
    and {{ month_col }} = 3
{% endmacro %}
