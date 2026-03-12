-- fct_payments
--
-- Gold-layer fact table: one row per payment transaction.
--
-- Kept intentionally narrow. This table is the source of truth for payment method
-- analysis, failure rate monitoring, and refund tracking. Revenue and order-level
-- context live in fct_orders, not here.
--
-- Materialized as a table in the Gold schema.

select
    payment_id,
    order_id,
    payment_method,
    amount,
    payment_status,
    payment_date,
    payment_year,
    payment_month
from {{ ref('stg_payments') }}
