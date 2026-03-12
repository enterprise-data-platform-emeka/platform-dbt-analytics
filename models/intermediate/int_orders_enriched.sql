-- int_orders_enriched
--
-- Enriches each order with customer details, payment information, and shipment
-- tracking data. This model is materialized as ephemeral, meaning dbt inlines
-- it remains directly queryable for debugging via ref('int_orders_enriched').
-- No physical table is created, which avoids intermediate storage costs.
--
-- Join strategy:
--   - LEFT JOIN on customers: all orders should have a customer, but we use
--     LEFT JOIN defensively in case of late-arriving dimension records.
--   - LEFT JOIN on payments: cancelled or pending orders may have no payment.
--   - LEFT JOIN on shipments: unshipped or cancelled orders have no shipment.

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.order_year,
    o.order_month,

    -- Customer context
    c.first_name,
    c.last_name,
    c.email,
    c.country,

    -- Payment context
    p.payment_id,
    p.payment_method,
    p.amount         as payment_amount,
    p.payment_status,
    p.payment_date,

    -- Shipment context
    s.shipment_id,
    s.carrier,
    s.delivery_status,
    s.shipped_date,
    s.delivered_date,
    s.delivery_days

from {{ ref('stg_orders') }}       o
left join {{ ref('stg_customers') }} c  using (customer_id)
left join {{ ref('stg_payments') }}  p  using (order_id)
left join {{ ref('stg_shipments') }} s  using (order_id)
