{{ config(materialized='incremental', incremental_strategy='append') }}

with source_transactions as (
    select * from {{ source('staging', 'stg_transactions') }}
),

source_stores as (
    select * from {{ source('staging', 'stg_stores') }}
),

link_luy_txn_store as (
    select distinct
        {{ hash_key(['tr.loyalty_transaction_id', 'st.store_id']) }} as hk_loyalty_store_id,
        {{ hash_key(['tr.loyalty_transaction_id']) }} as hk_loyalty_transaction_id,
        {{ hash_key(['st.store_id']) }} as hk_store_id,
        toFixedString('staging.stg_transactions, staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source_transactions as tr
    any inner join source_stores as st
    on tr.store_id = st.store_id
)

select * from link_luy_txn_store
{% if is_incremental() %} where hk_loyalty_store_id not in (select hk_loyalty_store_id from {{ this }}) {% endif %}
