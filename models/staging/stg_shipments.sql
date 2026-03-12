-- stg_shipments
--
-- Light staging transform on the Silver shipments source.
-- Work done here:
--   - Select the columns we need (no SELECT *)
--   - Pass through partition columns for Athena partition pruning.
--
-- `delivery_days` is pre-computed by the Glue Silver job (delivered_date - shipped_date).
-- It is null for shipments that have not yet been delivered.

select
    shipment_id,
    order_id,
    carrier,
    delivery_status,
    shipped_date,
    delivered_date,
    delivery_days,
    shipped_year,
    shipped_month
from {{ source('silver', 'shipments') }}
