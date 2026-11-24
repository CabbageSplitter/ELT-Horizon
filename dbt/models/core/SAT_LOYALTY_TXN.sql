with source as (
    select * from {{ source('staging', 'stg_transactions') }}
),

sat_loyalty_txn as (
    select 
        toString(md5(loyalty_transaction_id)) as hk_loyalty_transaction_id,
        toFixedString('staging.stg_transactions', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        toFixedString(md5(concat(points, '|',transaction_date)), 32) as hash_diff,
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