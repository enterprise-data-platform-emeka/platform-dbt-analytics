select
    carrier,
    count(*)                                                                as total_shipments,
    sum(case when delivery_status = 'delivered' then 1 else 0 end)         as delivered,
    sum(case when delivery_status = 'failed'    then 1 else 0 end)         as failed,
    round(
        sum(case when delivery_status = 'delivered' then 1 else 0 end) * 100.0
        / nullif(count(*), 0)
    , 2)                                                                    as delivery_success_rate_pct,
    round(avg(case when delivery_status = 'delivered' then delivery_days end), 2) as avg_delivery_days,
    min(case when delivery_status = 'delivered' then delivery_days end)    as fastest_delivery_days,
    max(case when delivery_status = 'delivered' then delivery_days end)    as slowest_delivery_days
from {{ ref('stg_shipments') }}
group by 1
order by delivery_success_rate_pct desc
