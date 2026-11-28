{{ config(materialized='incremental', incremental_strategy='append') }}

with source as (
    select * from {{ source('staging', 'stg_clients') }}
),

sat_client as (
    select distinct
        {{ hash_key(['client_id']) }} as hk_client_id,
        toFixedString('staging.stg_clients', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['full_name', 'phone', 'email']) }} as hash_diff,
        toFixedString(full_name, 255) as full_name,
        birth_date,
        toFixedString(phone, 20),
        toFixedString(email, 255),
        registration_date
    from source
    where client_id is not null
)

select * from sat_client
{% if is_incremental() %} where (hk_client_id, hash_diff) not in (select hk_client_id, hash_diff from {{ this }}) {% endif %}
