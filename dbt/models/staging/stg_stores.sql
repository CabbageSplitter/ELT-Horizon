with source as (select * from {{ source('raw', 'raw_stores') }}),
cleaned as (
    select
        toString(store_id) as store_id,
        toString(address) as address,
        toString(region) as region,
        toString(phone) as phone,
        toString(type) as type
    from source
    where nullIf(store_id, '') is not null
)
select * from cleaned