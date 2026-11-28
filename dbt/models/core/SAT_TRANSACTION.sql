{{ config(materialized='incremental', incremental_strategy='append') }}
with sa as (select * from {{ source('staging', 'stg_sales') }}),
tr as (select * from {{ source('staging', 'stg_transactions') }}),
sales_agg as (
    select transaction_id, any(datetime) as transaction_date, sum(amount) as sum_amount
    from sa group by transaction_id
),
sat as (
    select distinct
        {{ hash_key(['sa.transaction_id']) }} as hk_transaction_id,
        'staging.stg_sales, staging.stg_transactions' as source, now() as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['sa.transaction_date', 'sa.sum_amount']) }} as hash_diff,
        sa.transaction_date, sa.sum_amount,
        if(tr.source_transaction_id is null, 'нал', 'безнал') as payment_method
    from sales_agg sa any left join tr on tr.source_transaction_id = sa.transaction_id
)
select * from sat
{% if is_incremental() %} where (hk_transaction_id, hash_diff) not in (select hk_transaction_id, hash_diff from {{ this }}) {% endif %}