with sat_store as (
    select * from {{ source('core', 'SAT_STORE') }}
),
hub_store as (
    select * from {{ source('core', 'HUB_STORE') }}
)


dim_store as (
    select
        toInt64(replaceAll(ss.phone, '+', '')) as store_key,
        hs.store_id as store_id,
        ss.address as address,
        ss.region as region,
        ss.load_dts as valid_from,
        ss.load_end_dts as valid_to,
        case
            when ss.load_end_dts = toDateTime('9999-12-31 23:59:59')
                then True
            else False
        end as is_current

    from sat_store ss
    left any join hub_store hs
    on ss.hk_store_id = hs.hk_store_id
)

select * from dim_store