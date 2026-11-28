with source as (select * from {{ source('raw', 'raw_products') }}),
cleaned as (
    select
        toString(product_id) as product_id,
        toString(name) as name,
        toString(category) as category,
        toString(brand) as brand,
        accurateCastOrNull(nullIf(purchase_price, ''), 'Decimal(10,2)') as purchase_price,
        toString(status) as status
    from source
    where nullIf(product_id, '') is not null
)
select * from cleaned