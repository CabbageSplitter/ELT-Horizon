with source as (
    select * from {{ source('staging', 'stg_hr') }}
),

hub_employee as (
    select 
        toString(md5(employee_id)) as hk_employee_id,
        employee_id,
        toFixedString('staging.stg_hr', 50) as source,
        toDateTime(now()) as load_dts
    from source
    where employee_id is not null
)

select * from hub_employee