with source as (select * from {{ source('raw', 'raw_cards') }}),
cleaned as (
    select
        toUInt32(card_id) as card_id,
        toUInt32(client_id) as client_id,
        toString(card_number) as card_number,
        toDate(issue_date) as issue_date,
        toString(status) as status
    from source
    where card_id is not null
)
select * from cleaned