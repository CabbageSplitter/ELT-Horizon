{{ config(materialized='incremental', incremental_strategy='append') }}

with source_sales as (
    select * from {{ source('staging', 'stg_sales') }}
),

source_products as (
    select * from {{ source('staging', 'stg_products') }}
),

link_sale as (
    select distinct
        {{ hash_key(['sa.transaction_id', 'pr.product_id']) }} as hk_sale_id,
        {{ hash_key(['sa.transaction_id']) }} as hk_transaction_id,
        {{ hash_key(['pr.product_id']) }} as hk_product_id,
        toFixedString('staging.stg_sales, staging.stg_products', 50) as source,
        toDateTime(now()) as load_dts
    from source_sales as sa
    any inner join source_products as pr
    on sa.product_id = pr.product_id
)

select * from link_sale
{% if is_incremental() %} where hk_sale_id not in (select hk_sale_id from {{ this }}) {% endif %}
