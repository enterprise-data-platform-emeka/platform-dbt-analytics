-- int_product_sales
--
-- Joins order line items with product catalogue details so that every line item
-- row carries the full product context needed by the product performance mart.
-- Materialized as ephemeral — dbt inlines this as a CTE, no physical table created.
--
-- JOIN strategy:
--   - LEFT JOIN on products: guards against orphaned line items if a product was
--     deleted from the catalogue after purchase. The line item is still counted.

select
    oi.order_item_id,
    oi.order_id,
    oi.order_year,
    oi.order_month,
    oi.quantity,
    oi.unit_price,
    oi.line_total,

    -- Product context
    p.product_id,
    p.product_name,
    p.category,
    p.brand

from {{ ref('stg_order_items') }}  oi
left join {{ ref('stg_products') }} p  using (product_id)
