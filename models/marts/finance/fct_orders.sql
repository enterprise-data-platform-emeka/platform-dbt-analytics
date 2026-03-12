-- fct_orders
--
-- Gold-layer fact table: one row per order with full revenue and fulfilment context.
--
-- All the heavy lifting (joins to customers, payments, shipments) was done in the
-- ephemeral int_orders_enriched model. This mart just selects the columns that
-- finance and operations teams need, in the right shape for BI queries.
--
-- Materialized as a table so Redshift Serverless, Athena, and QuickSight can query
-- it without scanning the Silver Parquet layer on every request.

select
    order_id,
    customer_id,
    first_name,
    last_name,
    email,
    country,
    order_date,
    order_status,
    payment_amount,
    payment_status,
    payment_method,
    delivery_status,
    carrier,
    delivery_days,
    order_year,
    order_month
from {{ ref('int_orders_enriched') }}
