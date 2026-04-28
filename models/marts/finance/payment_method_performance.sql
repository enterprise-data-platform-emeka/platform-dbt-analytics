select
    payment_method,
    count(*) as total_transactions,
    sum(case when payment_status = 'completed' then 1 else 0 end) as successful,
    sum(case when payment_status = 'failed' then 1 else 0 end) as failed_count,
    sum(case when payment_status = 'refunded' then 1 else 0 end) as refunded,
    round(
        sum(case when payment_status = 'completed' then 1 else 0 end) * 100.0
        / nullif(count(*), 0),
        2
    ) as success_rate_pct,
    round(sum(amount), 2) as total_processed,
    round(
        sum(case when payment_status = 'completed' then amount else 0 end),
        2
    ) as revenue_captured
from {{ ref('stg_payments') }}
group by payment_method
order by total_processed desc
