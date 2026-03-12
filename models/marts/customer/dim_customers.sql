-- dim_customers
--
-- Gold-layer customer dimension. One row per customer, enriched with lifetime
-- purchase metrics derived directly from staging models.
--
-- Joins stg_customers → stg_orders → stg_payments directly rather than going
-- through int_orders_enriched. This avoids a diamond dependency (both this model
-- and int_orders_enriched reference stg_customers, which dbt's ephemeral cycle
-- detection misreads as a cycle).
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
    sum(p.amount)                   as lifetime_value,
    min(o.order_date)               as first_order_date,
    max(o.order_date)               as last_order_date
from {{ ref('stg_customers') }}   c
left join {{ ref('stg_orders') }}   o  using (customer_id)
left join {{ ref('stg_payments') }} p  using (order_id)
group by 1, 2, 3, 4, 5, 6
