-- stg_customers
--
-- Light staging transform on the Silver customers source.
-- Work done here:
--   - Select the columns we need (no SELECT *)
--   - Lowercase country for consistent downstream filtering
--   - Cast signup_date to date type (works in both DuckDB and Athena)
--
-- No business logic lives in staging. Joins, aggregations, and derived metrics
-- belong in intermediate or mart models.

select
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    lower(country) as country,
    cast(signup_date as date) as signup_date
from {{ source('silver', 'customers') }}
