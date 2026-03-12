-- assert_positive_value
--
-- Generic test that fails if any row has a value <= 0 in the specified column.
--
-- Used on numeric columns where zero or negative values indicate bad data:
--   - unit_price (a price of zero or less is invalid)
--   - quantity (ordering zero or negative units is invalid)
--   - line_total (a negative total would indicate a data issue, not a refund)
--   - amount (a payment of zero or less is invalid)
--
-- Usage in schema YAML:
--   data_tests:
--     - assert_positive_value:
--         column_name: unit_price
--
-- dbt runs this as a SELECT: if any rows are returned, the test fails.

{% test assert_positive_value(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} <= 0
{% endtest %}
