{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_products') }}
),

hub_product as (
    select distinct
        {{ hash_key(['product_id']) }} as hk_product_id,
        product_id,
        toFixedString('staging.stg_products', 50) as source,
        toDateTime(now()) as load_dts
    from source where product_id is not null
)

select * from hub_product
{% if is_incremental() %} where hk_product_id not in (select hk_product_id from {{ this }}) {% endif %}
