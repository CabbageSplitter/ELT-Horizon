{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='date_key'
) }}

with dates as (
    select distinct toDate(assumeNotNull(transaction_date)) as transaction_date
    from {{ source('core', 'SAT_TRANSACTION') }}
    where transaction_date is not null
      and toDate(assumeNotNull(transaction_date)) > toDate('1970-01-01')
)

select
    toYYYYMMDD(transaction_date) as date_key,
    transaction_date as full_date,
    toDayOfWeek(transaction_date) as day_of_week,
    arrayElement(
        ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'],
        toDayOfWeek(transaction_date)
    ) as day_name,
    toQuarter(transaction_date) as quarter,
    toYear(transaction_date) as year,
    if(toDayOfWeek(transaction_date) in (6, 7), 1, 0) as is_holiday
from dates