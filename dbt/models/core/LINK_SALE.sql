with source_sales as (
    select * from {{ source('staging', 'stg_sales') }}
),

source_products as (
    select * from {{ source('staging', 'stg_products') }}
),

link_sale as (
    select 
        toString(md5(concat(sa.transaction_id, '|',pr.product_id)) as hk_sale_id,
        toString(md5(sa.transaction_id)) as hk_transaction_id,
        toString(md5(pr.product_id)) as hk_product_id,
        toFixedString('staging.stg_sales, staging.stg_products', 50) as source,
        toDateTime(now()) as load_dts
    from source_sales as sa
    left any join source_products as pr
    on sa.product_id = pr.product_id
)

select * from link_sale