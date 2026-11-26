{{ config(materialized='incremental', incremental_strategy='append') }}
with source as (
    select * from {{ source('staging', 'stg_clients') }}
),

hab_client as (
    select distinct
        {{ hash_key(['client_id']) }} as hk_client_id,
        client_id,
        toFixedString('staging.stg_clients', 50) as source,
        toDateTime(now()) as load_dts
    from source where client_id is not null
)

select * from hab_client
{% if is_incremental() %} where hk_client_id not in (select hk_client_id from {{ this }}) {% endif %}
