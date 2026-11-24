with source as (
    select * from {{ source('staging', 'stg_stores') }}
),

hub_store as (
    select 
        toString(md5(store_id)) as hk_store_id,
        store_id,
        toFixedString('staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source
    where store_id is not null
)

select * from hub_store