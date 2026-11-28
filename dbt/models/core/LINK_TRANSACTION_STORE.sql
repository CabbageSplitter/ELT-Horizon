{{ config(materialized='incremental', incremental_strategy='append') }}

with source_sales as (
    select * from {{ source('staging', 'stg_sales') }}
),

source_stores as (
    select * from {{ source('staging', 'stg_stores') }}
),

link_txn_store as (
    select distinct
        {{ hash_key(['sa.transaction_id', 'st.store_id']) }} as hk_txn_store_id,
        {{ hash_key(['sa.transaction_id']) }} as hk_transaction_id,
        {{ hash_key(['st.store_id']) }} as hk_store_id,
        toFixedString('staging.stg_sales, staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source_sales as sa
    any inner join source_stores as st
    on sa.store_id = st.store_id
)

select * from link_txn_store
{% if is_incremental() %} where hk_txn_store_id not in (select hk_txn_store_id from {{ this }}) {% endif %}
