with source_transactions as (
    select * from {{ source('staging', 'stg_transactions') }}
),

source_stores as (
    select * from {{ source('staging', 'stg_stores') }}
),

link_luy_txn_store as (
    select 
        toString(md5(concat(tr.loyalty_transaction_id, '|',st.store_id)) as hk_loyalty_store_id,
        toString(md5(tr.loyalty_transaction_id)) as hk_loyalty_transaction_id,
        toString(md5(st.store_id)) as hk_store_id,
        toFixedString('staging.stg_transactions, staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source_transactions as tr
    left any join source_stores as st
    on tr.store_id = st.store_id
)

select * from link_luy_txn_store