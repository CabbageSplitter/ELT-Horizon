with source as (
    select * from {{ source('staging', 'stg_clients') }}
),

sat_client as (
    select 
        toString(md5(client_id)) as hk_client_id,
        toFixedString('staging.stg_clients', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        toFixedString(md5(concat(toFixedString(full_name, 255), '|',toFixedString(phone, 20), '|',toFixedString(email, 255))), 32) as hash_diff,
        toFixedString(full_name, 255) as full_name,
        birth_date,
        toFixedString(phone, 20),
        toFixedString(email, 255),
        registration_date
    from source
    where client_id is not null
)

select * from sat_client