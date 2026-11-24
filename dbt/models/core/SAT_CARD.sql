with source as (
    select * from {{ source('staging', 'stg_cards') }}
),

sat_card as (
    select 
        toString(md5(card_id)) as hk_card_id,
        toFixedString('staging.stg_cards', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        toFixedString(md5(concat(toFixedString(card_number, 50), '|',toFixedString(status, 20))), 32) as hash_diff,
        toFixedString(card_number, 50) as card_number,
        issue_date,
        toFixedString(status, 20)


    from source
    where card_id is not null
)

select * from sat_card