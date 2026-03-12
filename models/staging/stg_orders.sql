-- stg_orders
--
-- Light staging transform on the Silver orders source.
-- Work done here:
--   - Select the columns we need (no SELECT *)
--   - Pass through partition columns (order_year, order_month) so downstream
--     Athena queries can benefit from partition pruning.
--
-- Order status validation happens in _staging.yml tests, not here.

select
    order_id,
    customer_id,
    order_date,
    order_status,
    order_year,
    order_month
from {{ source('silver', 'orders') }}
