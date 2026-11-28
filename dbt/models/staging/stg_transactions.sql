with source as (select * from {{ source('raw', 'raw_transactions') }}),
cleaned as (
    select
        toUInt32(loyalty_transaction_id) as loyalty_transaction_id,
        toUInt32(card_id) as card_id,
        toInt32(points) as points,
        toDateTime(transaction_date) as transaction_date,
        toString(store_id) as store_id,
        toString(source_transaction_id) as source_transaction_id
    from source
    where loyalty_transaction_id is not null
)
select * from cleaned