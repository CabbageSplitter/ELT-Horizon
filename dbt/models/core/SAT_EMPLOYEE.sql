{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_hr') }}
),

sat_employee as (
    select distinct
        {{ hash_key(['employee_id']) }} as hk_employee_id,
        toFixedString('staging.stg_hr', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['full_name', 'position']) }} as hash_diff,
        toFixedString(full_name, 255) as full_name,
        toFixedString(position, 100) as position,
        hire_date,
        termination_date
    from source
    where employee_id is not null
)

select * from sat_employee
{% if is_incremental() %} where (hk_employee_id, hash_diff) not in (select hk_employee_id, hash_diff from {{ this }}) {% endif %}
