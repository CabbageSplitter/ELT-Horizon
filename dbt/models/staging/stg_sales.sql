with source as (select * from {{ source('raw', 'raw_sales') }}),
cleaned as (
    select
        toString(transaction_id) as transaction_id,
        toString(product_id) as product_id,
        accurateCastOrNull(nullIf(amount, ''), 'Decimal(10,2)') as amount,
        accurateCastOrNull(nullIf(oquantity, ''), 'Decimal(10,3)') as oquantity,
        toString(store_id) as store_id,
        parseDateTimeBestEffortOrNull(nullIf(datetime, '')) as datetime
    from source
    where nullIf(transaction_id, '') is not null
)
select * from cleaned