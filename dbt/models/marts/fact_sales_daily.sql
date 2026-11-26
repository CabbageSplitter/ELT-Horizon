{{ config(
    engine='MergeTree()',
    order_by='(date_key, store_key, product_key)',
    partition_by='intDiv(date_key, 100)'
) }}

with link_sale as (

    select hk_sale_id, hk_transaction_id, hk_product_id
    from {{ source('core', 'LINK_SALE') }}

),

sat_sale as (

    select
        hk_sale_id,
        argMax(amount, load_dts) as amount
    from {{ source('core', 'SAT_SALE') }}
    group by hk_sale_id

),

sat_txn as (

    -- из сата чека нужна только дата; сумму чека считаем сами из позиций
    select
        hk_transaction_id,
        argMax(transaction_date, load_dts) as transaction_date
    from {{ source('core', 'SAT_TRANSACTION') }}
    group by hk_transaction_id

),

txn_store as (

    select
        hk_transaction_id,
        argMax(hk_store_id, load_dts) as hk_store_id
    from {{ source('core', 'LINK_TRANSACTION_STORE') }}
    group by hk_transaction_id

),

all_lines as (

    -- все позиции всех чеков: нужно для итога чека по всем товарам
    select
        l.hk_transaction_id,
        l.hk_product_id,
        s.amount
    from link_sale as l
    inner join sat_sale as s
        on l.hk_sale_id = s.hk_sale_id

),

check_totals as (

    -- 1: итог каждого чека по всем товарам, до группировки по товару
    select
        hk_transaction_id,
        sum(amount) as check_total
    from all_lines
    group by hk_transaction_id

),

lines as (

    -- позиции с датой и магазином чека
    select
        toDate(t.transaction_date) as transaction_date,
        ts.hk_store_id,
        al.hk_product_id,
        al.hk_transaction_id,
        al.amount
    from all_lines as al
    inner join sat_txn   as t  on al.hk_transaction_id = t.hk_transaction_id
    inner join txn_store as ts on al.hk_transaction_id = ts.hk_transaction_id

),

with_bk as (

    select
        l.transaction_date,
        hp.product_id,
        hs.store_id,
        l.hk_transaction_id,
        l.amount
    from lines as l
    inner join {{ source('core', 'HUB_PRODUCT') }} as hp
        on l.hk_product_id = hp.hk_product_id
    inner join {{ source('core', 'HUB_STORE') }} as hs
        on l.hk_store_id = hs.hk_store_id

),

with_keys as (

    -- SK измерений (SCD2-версия на дату чека) + итог чека на каждой строке
    select
        dc.date_key,
        ds.store_key,
        dp.product_key,
        b.hk_transaction_id,
        b.amount,
        ct.check_total
    from with_bk as b
    inner join check_totals as ct
        on b.hk_transaction_id = ct.hk_transaction_id
    inner join {{ ref('dim_calendar') }} as dc
        on b.transaction_date = dc.full_date
    inner join {{ ref('dim_store') }} as ds
        on  b.store_id        = ds.store_id
        and b.transaction_date >= ds.valid_from
        and b.transaction_date <  ds.valid_to
    inner join {{ ref('dim_product') }} as dp
        on  b.product_id      = dp.product_id
        and b.transaction_date >= dp.valid_from
        and b.transaction_date <  dp.valid_to

),

txn_product as (

    -- 2а: grain «чек × товар» - каждый чек в группе ровно один раз
    select
        date_key,
        store_key,
        product_key,
        hk_transaction_id,
        sum(amount)      as product_amount,   -- сумма товара в этом чеке
        any(check_total) as check_total       -- константа в рамках чека
    from with_keys
    group by
        date_key, store_key, product_key, hk_transaction_id

)

-- 2б: финальный grain «день × магазин × товар»
select
    date_key,
    store_key,
    product_key,
    cast(sum(product_amount) as Decimal(12, 2)) as sum_sales,
    cast(count() as UInt32)                     as num_transactions,      -- строк = уникальных чеков
    cast(avg(check_total) as Decimal(10, 2))    as avg_transaction_amount -- средний итог чека
from txn_product
group by
    date_key, store_key, product_key