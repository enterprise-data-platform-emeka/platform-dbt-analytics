select
    category,
    brand,
    count(distinct order_id)                    as total_orders,
    count(distinct product_id)                  as products_in_category,
    sum(quantity)                               as total_units_sold,
    round(sum(line_total), 2)                                       as total_revenue,
    round(sum(line_total) / nullif(sum(quantity), 0), 2)            as avg_revenue_per_unit
from {{ ref('int_product_sales') }}
group by 1, 2
order by total_revenue desc
