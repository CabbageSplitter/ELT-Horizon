with source as (
    select * from {{ source('raw', 'clients') }}
),

cleaned as (
    select 
        toUInt32(client_id),
        toString(full_name),
        toDate(birth_date),
        toString(phone),
        toString(email)
        toDate(registration_date)
    from source
    where event_id is not null
)

select * from cleaned