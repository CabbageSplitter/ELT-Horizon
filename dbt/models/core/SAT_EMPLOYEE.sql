with source as (
    select * from {{ source('staging', 'stg_hr') }}
),

sat_employee as (
    select 
        toString(md5(employee_id)) as hk_employee_id,
        toFixedString('staging.stg_hr', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        toFixedString(md5(concat(toFixedString(full_name, 255), '|',toFixedString(position, 100))), 32) as hash_diff,
        toFixedString(full_name, 255) as full_name,
        toFixedString(position, 100) as position,
        ohire_date,
        termination_date
    from source
    where employee_id is not null
)

select * from sat_employee