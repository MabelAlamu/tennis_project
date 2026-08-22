with filtered as (
    select 
        imu.*,
        case when score like '%RET%' then 'Retired'
             when score like '%DEF%' then 'Default'
             when score like '%W/O%' then 'Walkover'
             else 'Completed'
        end as match_status
    from {{ ref('int_matches_unioned') }} as imu
    where tourney_date >= '2000-01-01'
)
-- select distinct score from filtered
-- where score not like '%-%'  -- filter out scores without a normal set-score pattern

select * from filtered