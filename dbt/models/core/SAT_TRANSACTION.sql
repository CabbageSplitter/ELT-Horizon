with source_sales as (
    select * from {{ source('staging', 'stg_sales') }}
),
source_transactions as (
    select * from {{ source('staging', 'stg_transactions') }}
),
sales_agg as (
    select 
        transaction_id,
        any(datetime) as transaction_date,
        sum(amount) as sum_amount
    from source_sales
    group by transaction_id
),
sat_sales as (
    select 
        toString(md5(sa.transaction_id)) as hk_transaction_id,
        toFixedString('staging.stg_sales, staging.stg_transactions', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        toFixedString(md5(concat(sa.transaction_date, '|',sa.sum_amount)), 32) as hash_diff,
        sa.transaction_date as transaction_date,
        sa.sum_amount as sum_amount,
        CASE
            when tr.source_transaction_id is null then toFixedString('нал', 10)
            else toFixedString('безнал', 10)
        end as payment_method
    from sales_agg sa
    left join source_transactions as tr
    on tr.source_transaction_id = tpString(sa.transaction_id)
)

select * from sat_sales
