-- stg_products
--
-- Light staging transform on the Silver products source.
-- Work done here:
--   - Rename `name` to `product_name` — "name" is a reserved word in several
--     SQL dialects and the alias makes intent clearer in downstream joins.
--   - Select the columns we need (no SELECT *)
--
-- No business logic here. Pricing history, margin calculations, and category
-- rollups belong in mart models.

select
    product_id,
    name as product_name,
    category,
    brand,
    unit_price,
    stock_qty
from {{ source('silver', 'products') }}
