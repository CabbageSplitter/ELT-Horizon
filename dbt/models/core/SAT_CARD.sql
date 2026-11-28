{{ config(materialized='incremental', incremental_strategy='append') }}
with source as (
    select * from {{ source('staging', 'stg_cards') }}
),

sat_card as (
    select distinct
        {{ hash_key(['card_id']) }} as hk_card_id,
        toFixedString('staging.stg_cards', 50) as source,
        toDateTime(now()) as load_dts,
        toDateTime('9999-12-31 23:59:59') as load_end_dts,
        {{ hash_key(['card_number', 'status']) }} as hash_diff,
        toFixedString(card_number, 50) as card_number,
        issue_date,
        toFixedString(status, 20) as status


    from source
    where card_id is not null
)

select * from sat_card
{% if is_incremental() %} where (hk_card_id, hash_diff) not in (select hk_card_id, hash_diff from {{ this }}) {% endif %}