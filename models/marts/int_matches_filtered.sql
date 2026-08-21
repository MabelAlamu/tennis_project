with filtered as (
    select * from {{ ref('int_matches_unioned') }}
    where tourney_date >= '1996-01-01'
)
select * from filtered
 