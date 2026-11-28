{{ config(materialized='incremental', incremental_strategy='append') }}

with source_hr as (
    select * from {{ source('staging', 'stg_hr') }}
),

source_stores as (
    select * from {{ source('staging', 'stg_stores') }}
),

link_employee_store as (
    select distinct
        {{ hash_key(['hr.employee_id', 'st.store_id']) }} as hk_employee_store_id,
        {{ hash_key(['hr.employee_id']) }} as hk_employee_id,
        {{ hash_key(['st.store_id']) }} as hk_store_id,
        toFixedString('staging.stg_hr, staging.stg_stores', 50) as source,
        toDateTime(now()) as load_dts
    from source_hr as hr
    any inner join source_stores as st
    on hr.store_id = st.store_id
)

select * from link_employee_store
{% if is_incremental() %} where hk_employee_store_id not in (select hk_employee_store_id from {{ this }}) {% endif %}