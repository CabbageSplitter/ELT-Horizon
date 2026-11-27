{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(product_id, valid_from)'
) }}

with sat as (
    select
        hk_product_id, name, category, brand, load_dts,
        row_number() over (
            partition by hk_product_id, toDate(load_dts)
            order by load_dts desc
        ) as rn
    from {{ ref('SAT_PRODUCT_STATIC') }}
),

versions as (
    select
        hk_product_id, name, category, brand,
        toDate(load_dts) as valid_from,
        leadInFrame(toNullable(toDate(load_dts)), 1) over (
            partition by hk_product_id order by load_dts
            rows between unbounded preceding and unbounded following
        ) as next_from
    from sat
    where rn = 1
),

hub as (
    select hk_product_id, product_id
    from {{ ref('HUB_PRODUCT') }}
)

select
    row_number() over (order by h.product_id, v.valid_from) as product_key,
    h.product_id,
    v.name as product_name,
    v.category,
    v.brand,
    v.valid_from,
    coalesce(v.next_from, toDate('2100-12-31')) as valid_to,
    v.next_from is null as is_current
from versions v
inner join hub h on v.hk_product_id = h.hk_product_id