with source as (
    select * from {{ source('staging', 'stg_transactions') }}
),

hub_loy_trx as (
    select 
        toString(md5(loyalty_transaction_id)) as loyalty_transaction_id,
        loyalty_transaction_id,
        toFixedString('staging.stg_transactions', 50) as source,
        toDateTime(now()) as load_dts
    from source
    where loyalty_transaction_id is not null
)

select * from hub_loy_trx