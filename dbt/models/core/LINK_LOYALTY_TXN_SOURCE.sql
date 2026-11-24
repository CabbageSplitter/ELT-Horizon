with source_transactions as (
    select * from {{ source('staging', 'stg_transactions') }}
),

source_sales as (
    select * from {{ source('staging', 'stg_sales') }}
),

link_luy_txn_sales as (
    select 
        toString(md5(concat(tr.loyalty_transaction_id, '|',sa.transaction_id)) as hk_loyalty_source_id,
        toString(md5(tr.loyalty_transaction_id)) as hk_loyalty_transaction_id,
        toString(md5(st.transaction_id)) as hk_transaction_id,
        toFixedString('staging.stg_transactions, staging.stg_sales', 50) as source,
        toDateTime(now()) as load_dts
    from source_transactions as tr
    left any join source_sales as sa
    on tr.source_transaction_id = sa.transaction_id
)

select * from link_luy_txn_sales