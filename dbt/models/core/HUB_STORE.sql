{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_stores') }}
),

hub_store as (
    select distinct
         {{ hash_key(['store_id']) }} as hk_store_id,
        store_id,
        toFixedString('staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source where store_id is not null
    
)

select * from hub_store
{% if is_incremental() %} where hk_store_id not in (select hk_store_id from {{ this }}) {% endif %}
