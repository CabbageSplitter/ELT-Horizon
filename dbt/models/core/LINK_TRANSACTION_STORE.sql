with source_sales as (
    select * from {{ source('staging', 'stg_sales') }}
),

source_stores as (
    select * from {{ source('staging', 'stg_stores') }}
),

link_txn_store as (
    select 
        toString(md5(concat(sa.transaction_id, '|',st.store_id)) as hk_txn_store_id,
        toString(md5(sa.transaction_id)) as hk_transaction_id,
        toString(md5(st.store_id)) as hk_store_id,
        toFixedString('staging.stg_sales, staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source_sales as sa
    left any join source_stores as st
    on sa.store_id = st.store_id
)

select * from link_txn_store