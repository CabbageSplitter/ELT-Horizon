with source as (
    select * from {{ source('raw', 'raw_sales') }}
),

cleaned as (
    select 
        toUUID(transaction_id) as transaction_id,
        toString(product_id) as product_id,
        cast(amount, decimal(10,2)) as amount,
        cast(oquantity, decimal(10,3)) as oquantity,
        toString(store_id) as store_id,
        toDateTime(datetime) as datetime
    from source
    where transaction_id is not null
)

select * from cleaned