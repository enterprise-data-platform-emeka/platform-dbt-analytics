-- fct_product_performance
--
-- Gold-layer fact table: one row per product per month with aggregated sales metrics.
--
-- Reads from int_product_sales (ephemeral), which joins order line items with
-- product catalogue details. Aggregates to the (product, year, month) grain.
--
-- avg_unit_revenue uses the {{ safe_divide() }} macro to return null instead of
-- raising a division-by-zero error if a product somehow has zero units_sold.
--
-- Materialized as a table in the Gold schema.

select
    product_id,
    product_name,
    category,
    brand,
    order_year,
    order_month,
    count(distinct order_id)                                          as total_orders,
    sum(quantity)                                                     as total_units_sold,
    sum(line_total)                                                   as total_revenue,
    {{ safe_divide('sum(line_total)', 'sum(quantity)') }}             as avg_unit_revenue
from {{ ref('int_product_sales') }}
group by 1, 2, 3, 4, 5, 6
