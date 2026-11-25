with source as (
    select * from {{ source('staging', 'stg_products') }}
),

hub_product as (
    select 
        toString(md5(product_id)) as hk_product_id,
        product_id,
        toFixedString('staging.stg_products', 50) as source,
        toDateTime(now()) as load_dts
    from source
    where product_id is not null
)

select * from hub_product