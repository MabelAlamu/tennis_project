with filtered as (
    select 
        imu.*,
        case when score like '%RET%' then 'Retired'
             when score like '%DEF%' then 'Default'
             when score like '%W/O%' then 'Walkover'
             else 'Completed'
        end as match_status,
        case
            when tourney_name like 'Davis Cup%' then 'Davis Cup'
            when tourney_name in ('ATP Tour Finals', 'ATP Finals', 'Tour Finals', 'Masters Cup') then 'ATP Finals'
            when tourney_name in ('NextGen Finals', 'Next Gen Finals', 'Next Gen ATP Finals') then 'Next Gen Finals'
            else tourney_name
        end as standardised_tourney_name
    from {{ ref('int_matches_unioned') }} as imu
    where tourney_date >= '2000-01-01'
)
--  select score from filtered 
-- where score not like '%-%'  -- getting a list of scores without a normal set-score pattern

select * from filtered