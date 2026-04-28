{% macro test_freshness_relative_to_reference(model, column_name, reference_date, warn_after_hours=24) %}

{#
  Custom freshness test for Silver source tables.

  Why not native dbt source freshness:
    Native freshness checks max(loaded_at_field) against datetime.now(). Our
    Bronze dataset ends on 2026-03-02, so every table would immediately show
    ~56+ days of staleness when checked today. This test uses a fixed reference
    date instead, which answers the operationally correct question: "Does the
    Silver table have data up to the expected cutoff?"

  Why reference_date instead of now():
    The reference_date is the last date in the Bronze dataset (2026-03-02). A
    Silver table passes if its max business date is within warn_after_hours of
    that cutoff. This test stays permanently valid for this historical snapshot
    and needs no updating as wall-clock time advances.

  Returns rows when the test fails (dbt standard: 0 rows = pass, >0 rows = fail).

  Args:
    model:            The source relation (e.g. source('silver', 'customers')).
    column_name:      Business date column to check (e.g. order_date, signup_date).
    reference_date:   Expected latest date in the dataset. Format: 'YYYY-MM-DD HH:MM:SS'.
    warn_after_hours: Hours before reference_date at which this test fails.
                      Default 24. A value of 24 means: fail if max(column_name)
                      is more than 24 hours before reference_date.

  Usage in sources.yml:
    columns:
      - name: order_date
        tests:
          - freshness_relative_to_reference:
              reference_date: '2026-03-02 23:59:59'
              warn_after_hours: 24
#}

select
    max({{ column_name }}) as latest_value,
    timestamp '{{ reference_date }}' as reference_date,
    timestamp '{{ reference_date }}' - interval '{{ warn_after_hours }}' hour as freshness_cutoff
from {{ model }}
having max({{ column_name }}) < timestamp '{{ reference_date }}' - interval '{{ warn_after_hours }}' hour
    or max({{ column_name }}) is null

{% endmacro %}
