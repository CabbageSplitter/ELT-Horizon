with source as (
    select * from {{ source('raw', 'products') }}
),

cleaned as (
    select 
        toString(product_id) as product_id,
        toString(name) as name,
        toString(category) as category,
        toString(brand) as brand,
        cast(purchase_price, decimal(10,2)) as purchase_price,
        toBool(status) as status
    from source
    where product_id is not null
)

select * from cleaned