select
    order_year,
    order_month,
    count(distinct order_id)                    as total_orders,
    count(distinct customer_id)                 as unique_customers,
    round(sum(payment_amount), 2)                                       as total_revenue,
    sum(case when order_status = 'cancelled' then 1 else 0 end) as cancelled_orders
from {{ ref('int_orders_enriched') }}
group by 1, 2
order by 1, 2
