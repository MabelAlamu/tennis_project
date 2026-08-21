with 
atp_count as (
    select count(*) as n_rows from {{ ref('stg_atp') }}
),
wta_count as (
    select count(*) as n_rows from {{ ref('stg_wta') }}
),
union_count as (
    select count(*) as n_rows from {{ ref('int_matches_unioned') }}
)

select *
from union_count, atp_count, wta_count
where union_count.n_rows != (atp_count.n_rows + wta_count.n_rows)
