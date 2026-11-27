{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(store_id, valid_from)'
) }}

with sat as (
    select
        hk_store_id, address, region, load_dts,
        row_number() over (
            partition by hk_store_id, toDate(load_dts)
            order by load_dts desc
        ) as rn
    from {{ ref('SAT_STORE') }}
),

versions as (
    select
        hk_store_id, address, region,
        toDate(load_dts) as valid_from,
        leadInFrame(toNullable(toDate(load_dts)), 1) over (
            partition by hk_store_id order by load_dts
            rows between unbounded preceding and unbounded following
        ) as next_from
    from sat
    where rn = 1
),

hub as (
    select hk_store_id, store_id
    from {{ ref('HUB_STORE') }}
)

select
    row_number() over (order by h.store_id, v.valid_from) as store_key,
    h.store_id,
    v.address,
    v.region,
    v.valid_from,
    coalesce(v.next_from, toDate('2100-12-31')) as valid_to,
    v.next_from is null as is_current
from versions v
inner join hub h on v.hk_store_id = h.hk_store_id