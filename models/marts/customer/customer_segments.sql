with customer_metrics as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.country,
        c.signup_date,
        count(distinct o.order_id)      as total_orders,
        round(sum(p.amount), 2)         as lifetime_value,
        min(o.order_date)               as first_order_date,
        max(o.order_date)               as last_order_date
    from {{ ref('stg_customers') }}   c
    left join {{ ref('stg_orders') }}   o on c.customer_id = o.customer_id
    left join {{ ref('stg_payments') }} p on o.order_id    = p.order_id
    group by 1, 2, 3, 4, 5, 6
)
select
    customer_id,
    first_name,
    last_name,
    email,
    country,
    signup_date,
    total_orders,
    lifetime_value,
    first_order_date,
    last_order_date,
    case
        when lifetime_value >= 500  then 'VIP'
        when lifetime_value >= 200  then 'Regular'
        when lifetime_value >  0    then 'Low Value'
        else                             'Never Ordered'
    end as segment,
    case
        when total_orders = 0 then 'No Orders'
        when total_orders = 1 then 'One-Time'
        when total_orders <= 3 then 'Occasional'
        else                        'Loyal'
    end as order_frequency_band
from customer_metrics
order by lifetime_value desc nulls last
