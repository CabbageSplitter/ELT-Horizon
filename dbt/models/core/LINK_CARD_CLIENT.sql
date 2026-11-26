{{ config(materialized='incremental', incremental_strategy='append') }}
with source_cards as (
    select * from {{ source('staging', 'stg_cards') }}
),

source_clients as (
    select * from {{ source('staging', 'stg_clients') }}
),

link_card_client as (
    select  distinct
        {{ hash_key(['ca.card_id', 'cl.client_id']) }} as hk_card_client_id,
        {{ hash_key(['ca.card_id']) }} as hk_card_id,
        {{ hash_key(['cl.client_id']) }} as hk_client_id,
        toFixedString('staging.stg_cards, staging.stg_clients', 50) as source,
        toDateTime(now()) as load_dts
    from source_cards as ca
    any inner join source_clients as cl
    on cl.client_id = ca.client_id
)

select * from link_card_client
{% if is_incremental() %} where hk_card_client_id not in (select hk_card_client_id from {{ this }}) {% endif %}