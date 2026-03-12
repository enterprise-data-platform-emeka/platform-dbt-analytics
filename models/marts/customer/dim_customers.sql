-- dim_customers
--
-- Gold-layer customer dimension. One row per customer, enriched with lifetime
-- purchase metrics aggregated from int_orders_enriched (ephemeral).
--
-- LEFT JOIN strategy: customers who have never placed an order still appear here
-- with total_orders = 0 and lifetime_value / date columns as null. This matters
-- for churn analysis and new customer cohort reporting.
--
-- Materialized as a table in the Gold schema.

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country,
    c.signup_date,
    count(distinct o.order_id)      as total_orders,
    sum(o.payment_amount)           as lifetime_value,
    min(o.order_date)               as first_order_date,
    max(o.order_date)               as last_order_date
from {{ ref('stg_customers') }} c
left join {{ ref('int_orders_enriched') }} o  using (customer_id)
group by 1, 2, 3, 4, 5, 6
