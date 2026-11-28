{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_transactions') }}
),

hub_loy_trx as (
    select distinct
         {{ hash_key(['loyalty_transaction_id']) }} as hk_loyalty_transaction_id,
        loyalty_transaction_id,
        toFixedString('staging.stg_transactions', 50) as source,
        toDateTime(now()) as load_dts
    from source where loyalty_transaction_id is not null
)

select * from hub_loy_trx
{% if is_incremental() %} where hk_loyalty_transaction_id not in (select hk_loyalty_transaction_id from {{ this }}) {% endif %}
