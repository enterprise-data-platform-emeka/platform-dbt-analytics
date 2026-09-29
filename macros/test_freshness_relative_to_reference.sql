{% macro test_freshness_relative_to_reference(model, column_name, reference_date, warn_after_hours=24) %}

{# Historical coverage gate, not a live-ingestion SLA. The versioned seed
   ends on 2026-09-01 (exclusive). Sparse smoke fixtures allow a 30-day gap.
   All partitions participate in integrity tests. Override seed_reference_date
   explicitly when introducing a new versioned dataset. #}

select
    max({{ column_name }}) as latest_value,
    timestamp '{{ reference_date }}' as reference_date,
    timestamp '{{ reference_date }}' - interval '{{ warn_after_hours }}' hour as freshness_cutoff
from {{ model }}
having max({{ column_name }}) < timestamp '{{ reference_date }}' - interval '{{ warn_after_hours }}' hour
    or max({{ column_name }}) is null

{% endmacro %}
