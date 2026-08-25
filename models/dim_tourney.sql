with tourney_attrs as (
    select distinct 
        tourney_id,
        tourney_name,
        surface,
        draw_size,
        tourney_level, 
        indoor,
        tourney_date
    from {{ ref('int_matches_unpivoted') }}
),
champions as (
    select 
        tourney_id,
        tourney_name,
        player_name as tourney_winner
    from {{ ref('int_matches_unpivoted') }}
    where round = 'F'
     and result = 'Win'
),
final as (
    select distinct 
        a.tourney_id,
        a.tourney_name,
        a.surface,
        a.draw_size,
        a.tourney_level, 
        a.indoor,
        a.tourney_date,
        c.tourney_winner
    from tourney_attrs as a
    left join champions as c
    on a.tourney_id = c.tourney_id 
    and a.tourney_name = c.tourney_name
)
select * from final
where tourney_id in
    (select tourney_id from final
    group by tourney_id
    having count(distinct surface) > 1)
order by tourney_id


--select * from final where tourney_id = '2010-D030'
