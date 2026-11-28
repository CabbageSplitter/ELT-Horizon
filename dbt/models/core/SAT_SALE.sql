{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_sales') }}
),

sat_sales as (
    select distinct
        {{ hash_key(['transaction_id', 'product_id']) }} as hk_sale_id,
        toFixedString('staging.stg_sales', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['amount', 'oquantity']) }} as hash_diff,
        amount,
        oquantity as quantity
    from source
    where product_id is not null and transaction_id is not null
)

select * from sat_sales
{% if is_incremental() %} where (hk_sale_id, hash_diff) not in (select hk_sale_id, hash_diff from {{ this }}) {% endif %}
