{{ config(materialized='incremental', incremental_strategy='append') }}

with source_transactions as (
    select * from {{ source('staging', 'stg_transactions') }}
),

source_sales as (
    select * from {{ source('staging', 'stg_sales') }}
),

link_luy_txn_sales as (
    select distinct
        {{ hash_key(['tr.loyalty_transaction_id', 'sa.transaction_id']) }} as hk_loyalty_source_id,
        {{ hash_key(['tr.loyalty_transaction_id']) }} as hk_loyalty_transaction_id,
        {{ hash_key(['sa.transaction_id']) }} as hk_transaction_id,
        toFixedString('staging.stg_transactions, staging.stg_sales', 50) as source,
        toDateTime(now()) as load_dts
    from source_transactions as tr
    any inner join source_sales as sa
    on tr.source_transaction_id = sa.transaction_id
)

select * from link_luy_txn_sales
{% if is_incremental() %} where hk_loyalty_source_id not in (select hk_loyalty_source_id from {{ this }}) {% endif %}
