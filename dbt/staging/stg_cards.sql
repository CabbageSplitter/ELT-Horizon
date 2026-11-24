with source as (
    select * from {{ source('raw', 'cards') }}
),

cleaned as (
    select 
        toUInt32(card_id),
        toString(client_id),
        toString(card_number),
        toDate(issue_date)
        toString(status)
    from source
    where card_id is not null
)

select * from cleaned