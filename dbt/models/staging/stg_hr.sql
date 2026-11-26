with source as (select * from {{ source('raw', 'raw_hr') }}),
cleaned as (
    select
        toUInt32(employee_id) as employee_id,
        toString(full_name) as full_name,
        toString(position) as position,
        toString(store_id) as store_id,
        toDate(hire_date) as hire_date,
        toDateOrNull(termination_date) as termination_date
    from source
    where employee_id is not null
)
select * from cleaned