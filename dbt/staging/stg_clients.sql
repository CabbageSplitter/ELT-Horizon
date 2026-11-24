with source as (
    select * from {{ source('raw', 'clients') }}
),

cleaned as (
    select 
        toUInt32(client_id) as client_id,
        toString(full_name) as full_name,
        toDate(birth_date) as birth_date,
        toString(phone) as phone,
        toString(email) as email,
        toDate(registration_date) as registration_date
    from source
    where event_id is not null
)

select * from cleaned