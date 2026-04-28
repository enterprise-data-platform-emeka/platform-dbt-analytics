{% macro current_march_partition(year_col, month_col) %}
    {{ year_col }} = extract(year from current_date)
    and {{ month_col }} = 3
{% endmacro %}

{#
  Generates a WHERE clause that limits a test to the March partition of the
  current year. Used as the `where` config on data tests for the four
  partitioned Silver-sourced fact tables:
    - stg_orders / fact_orders          (order_year, order_month)
    - stg_order_items / fact_order_items (order_year, order_month)
    - stg_payments / fact_payments      (payment_year, payment_month)
    - stg_shipments / fact_shipments    (shipped_year, shipped_month)

  Why partition-filter tests:
    Athena charges per byte scanned. Without a partition filter, dbt test
    runs a full-table scan regardless of how many partitions exist. On fact
    tables with years of history this becomes expensive and slow. Scoping
    each test to one partition keeps cost and runtime predictable at any scale.

  Why current year + March:
    The dataset ends on 2026-03-02. March of the current year is always where
    the most recent data lives. Using extract(year from current_date) keeps
    the macro dynamic so it does not need updating as calendar years advance.

  Usage in YAML:
    - name: stg_orders
      config:
        where: "{{ current_march_partition('order_year', 'order_month') }}"

  Athena (Presto) syntax note:
    extract(year from current_date) returns an integer, which matches the
    integer type of the partition columns written by the Glue Silver jobs.
#}
