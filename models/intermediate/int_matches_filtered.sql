with matches as (
    select * from {{ ref('int_matches_unioned') }}
    where tourney_date >= date '2000-01-01'
)

-- select score from filtered 
-- where score not like '%-%'  -- getting a list of scores without a normal set-score pattern

select * from matches
