{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_products') }}
),

sat_product_static as (
    select distinct
        {{ hash_key(['product_id']) }} as hk_product_id,
        toFixedString('staging.stg_products', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['name', 'category', 'brand']) }} as hash_diff,
        toFixedString(name, 100) as name,
        toFixedString(category, 50) as category,
        toFixedString(brand, 50) as brand
    from source
    where product_id is not null
)

select * from sat_product_static
{% if is_incremental() %} where (hk_product_id, hash_diff) not in (select hk_product_id, hash_diff from {{ this }}) {% endif %}
