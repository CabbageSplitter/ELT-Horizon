{{ config(materialized='incremental', incremental_strategy='append') }}
with source as (
    select * from {{ source('staging', 'stg_cards') }}
),

hub_card as (
    select distinct
        {{ hash_key(['card_id']) }} as hk_card_id,
        card_id,
        toFixedString('staging.stg_cards', 50) as source,
        toDateTime(now()) as load_dts
    from source where card_id is not null
)

select * from hub_card
{% if is_incremental() %} where hk_card_id not in (select hk_card_id from {{ this }}) {% endif %}
