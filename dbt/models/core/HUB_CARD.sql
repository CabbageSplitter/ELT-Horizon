with source as (
    select * from {{ source('staging', 'stg_cards') }}
),

hub_card as (
    select 
        toString(md5(card_id)) as hk_card_id,
        card_id,
        toFixedString('staging.stg_cards', 50) as source,
        toDateTime(now()) as load_dts
    from source
    where card_id is not null
)

select * from hub_card