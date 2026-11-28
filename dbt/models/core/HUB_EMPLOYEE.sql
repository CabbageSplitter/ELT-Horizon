{{ config(materialized='incremental', incremental_strategy='append') }}
with source as (
    select * from {{ source('staging', 'stg_hr') }}
),

hub_employee as (
    select distinct
        {{ hash_key(['employee_id']) }} as hk_employee_id,
        employee_id,
        toFixedString('staging.stg_hr', 50) as source,
        toDateTime(now()) as load_dts
    from source where employee_id is not null
)

select * from hub_employee
{% if is_incremental() %} where hk_employee_id not in (select hk_employee_id from {{ this }}) {% endif %}
