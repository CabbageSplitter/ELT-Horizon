with sat_product_static as (
    select * from {{ source('core', 'SAT_PRODUCT_STATIC') }}
),
hub_product as (
    select * from {{ source('core', 'SAT_PRODUCT_STATIC') }}
)


dim_products as (
    select 
        (select toInt32(replaceRegexpAll(hp.product_id, '\p{L}', ''))) as product_key,
        hp.product_id as product_id,
        sp.name as product_name,
        sp.category as category,
        sp.brand as brand,
        sp.load_dts as valid_from,
        sp.load_end_dts as valid_to,
        case
            when sp.load_end_dts = toDateTime('9999-12-31 23:59:59')
                then True
            else False
        end as is_current

    from sat_product_static sp
    left any join hub_product hp
    on sp.hk_product_id = hp.hk_product_id
)

select * from dim_products