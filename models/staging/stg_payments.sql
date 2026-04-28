-- stg_payments
--
-- Light staging transform on the Silver payments source.
-- Work done here:
--   - Rename `method` to `payment_method` — avoids collision when this table is
--     joined to others that also have a generic `method` or `status` column.
--   - Rename `status` to `payment_status` for the same reason.
--   - Select the columns we need (no SELECT *)
--   - Pass through partition columns for Athena partition pruning.

select
    payment_id,
    order_id,
    method as payment_method,
    amount,
    status as payment_status,
    payment_date,
    payment_year,
    payment_month
from {{ source('silver', 'payments') }}
