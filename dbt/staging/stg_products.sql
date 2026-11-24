with source as (
    select * from {{ source('raw', 'products') }}
),

cleaned as (
    select 
        toString(product_id),
        toString(name),
        toString(category),
        toString(brand)
        cast(purchase_price, decimal(10,2))
        toBool(status)
    from source
    where card_id is not null
)

select * from cleaned