with matches as (
    select * from {{ ref('int_matches_unioned') }}
    where tourney_date >= date '2000-01-01'
),
tourney_mapping as (
    select
        source_tourney_name,
        standard_tourney_name
    from {{ ref('tourney_name_mapping') }}
),
standardised as (
    select 
        m.* exclude (tourney_name),
        case
            when m.tourney_name ilike 'Davis Cup%' then 'Davis Cup'
            when m.tourney_name ilike any ('Fed Cup%', 'Billie Jean King Cup%', 'BJK Cup%') then 'Billie Jean King Cup'
            else coalesce(tm.standard_tourney_name, m.tourney_name)
        end as tourney_name,
        case when score like '%RET%' then 'Retired'
             when score like '%DEF%' then 'Default'
             when score like '%W/O%' then 'Walkover'
             else 'Completed'
        end as match_status,
    from matches as m 
    left join tourney_mapping as tm
    on m.tourney_name = tm.source_tourney_name
)
-- select score from filtered 
-- where score not like '%-%'  -- getting a list of scores without a normal set-score pattern

select * from standardised
