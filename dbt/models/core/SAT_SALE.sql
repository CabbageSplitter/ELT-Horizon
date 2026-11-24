with source as (
    select * from {{ source('staging', 'stg_sales') }}
),

sat_sales as (
    select 
        toString(md5(concat(transaction_id, '|',product_id)) as hk_sale_id,
        toFixedString('staging.stg_sales', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        toFixedString(md5(concat(amount, '|',oquantity)), 32) as hash_diff,
        amount,
        oquantity as quantity
    from source
    where product_id is not null and transaction_id is not null
)

select * from sat_sales