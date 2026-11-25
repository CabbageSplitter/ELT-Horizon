with source as (
    select * from {{ source('core', 'SAT_TRANSACTION') }}
),
dates as (
    select toDate(decimal(transaction_date)) as transaction_date from source
)

dim_calendar as (
    select 
        toYYYYMMDD(transaction_date) as date_key,
        transaction_date as full_date,
        toDayOfWeek(transaction_date) as day_of_week,
        (
            select arrayElement(array('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
            toDayOfWeek(transaction_date))
            from dates
        ) as day_name,
        toQuarter(transaction_date) as quarter,
        toYear(transaction_date) as year
        case
            when toDayOfWeek(transaction_date) = 6 or toDayOfWeek(transaction_date) = 7
                then 1
            else 0
        end as is_holyday

    from dates
    where transaction_date is not null
)

select * from dim_calendar