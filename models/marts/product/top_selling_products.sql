select
    product_id,
    product_name,
    category,
    brand,
    count(distinct order_id) as total_orders,
    sum(quantity) as total_units_sold,
    round(sum(line_total), 2) as total_revenue,
    round(
        sum(line_total) / nullif(sum(quantity), 0),
        2
    ) as avg_revenue_per_unit,
    rank() over (order by sum(line_total) desc) as revenue_rank
from {{ ref('int_product_sales') }}
group by product_id, product_name, category, brand
order by revenue_rank
