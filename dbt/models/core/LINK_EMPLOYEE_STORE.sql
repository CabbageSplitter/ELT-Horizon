with source_hr as (
    select * from {{ source('staging', 'stg_hr') }}
),

source_stores as (
    select * from {{ source('staging', 'stg_stores') }}
),

link_employee_store as (
    select 
        toString(md5(concat(hr.employee_id, '|',st.store_id)) as hk_employee_store_id,
        toString(md5(hr.employee_id)) as hk_employee_id,
        toString(md5(st.store_id)) as hk_store_id,
        toFixedString('staging.stg_hr, staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source_hr as hr
    left any join source_stores as st
    on hr.employee_id = st.employee_id
)

select * from link_employee_store