select
    country,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as total_customers,
    round(sum(payment_amount), 2) as total_revenue,
    round(
        sum(payment_amount) / nullif(count(distinct order_id), 0),
        2
    ) as avg_order_value
from {{ ref('int_orders_enriched') }}
where payment_status = 'completed'
group by country
order by total_revenue desc
