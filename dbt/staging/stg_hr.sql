with source as (
    select * from {{ source('raw', 'hr') }}
),

cleaned as (
    select 
        toUInt32(employee_id) as employee_id,
        toString(full_name) as full_name,
        toString(position) as position,
        toString(transaction_date) as transaction_id,
        toString(store_id) as store_id,
        toDate(ohire_date) as ohire_date
        toDate(termination_date) as termination_date
    from source
    where employee_id is not null
)

select * from cleaned