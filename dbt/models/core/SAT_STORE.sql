{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_stores') }}
),

sat_store as (
    select distinct
        {{ hash_key(['store_id']) }} as hk_store_id,
        toFixedString('staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['address', 'region', 'phone']) }} as hash_diff,
        toFixedString(address, 100) as address,
        toFixedString(region, 50) as region,
        toFixedString(phone, 20) as phone,
        toFixedString(type, 30) as type
    from source
    where store_id is not null
)

select * from sat_store
{% if is_incremental() %} where (hk_store_id, hash_diff) not in (select hk_store_id, hash_diff from {{ this }}) {% endif %}
