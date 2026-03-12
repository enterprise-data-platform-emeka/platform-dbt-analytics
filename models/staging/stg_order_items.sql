-- stg_order_items
--
-- Light staging transform on the Silver order_items source.
-- Work done here:
--   - Select the columns we need (no SELECT *)
--   - Pass through partition columns for Athena partition pruning.
--
-- `line_total` is pre-computed by the Glue Silver job (quantity * unit_price).
-- We pass it through rather than recalculate it to keep the Silver layer as
-- the single source of truth for that computation.

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    line_total,
    order_year,
    order_month
from {{ source('silver', 'order_items') }}
