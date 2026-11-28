{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_transactions') }}
),

sat_loyalty_txn as (
    select distinct
        {{ hash_key(['loyalty_transaction_id']) }} as hk_loyalty_transaction_id,
        toFixedString('staging.stg_transactions', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['points', 'transaction_date']) }} as hash_diff,
        points,
        transaction_date,
        CASE
            when points >= 0 then toFixedString('начисление', 20)
            else toFixedString('списание', 20)
        end as type
    from source
    where loyalty_transaction_id is not null
)

select * from sat_loyalty_txn
{% if is_incremental() %} where (hk_loyalty_transaction_id, hash_diff) not in (select hk_loyalty_transaction_id, hash_diff from {{ this }}) {% endif %}
