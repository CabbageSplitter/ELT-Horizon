with source as (
    select * from {{ source('staging', 'stg_clients') }}
),

hab_client as (
    select 
        toString(md5(client_id)) as hk_client_id,
        client_id,
        toFixedString('staging.stg_clients', 50) as source,
        toDateTime(now()) as load_dts
    from source
    where client_id is not null
)

select * from hab_client