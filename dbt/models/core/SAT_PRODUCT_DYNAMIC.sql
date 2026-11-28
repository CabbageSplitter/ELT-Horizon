{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_products') }}
),

sat_product_dymanic as (
    select distinct
        {{ hash_key(['product_id']) }} as hk_product_id,
        toFixedString('staging.stg_products', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['purchase_price', 'status']) }} as hash_diff,
        purchase_price,
        status
    from source
    where product_id is not null
)

select * from sat_product_dymanic
{% if is_incremental() %} where (hk_product_id, hash_diff) not in (select hk_product_id, hash_diff from {{ this }}) {% endif %}
