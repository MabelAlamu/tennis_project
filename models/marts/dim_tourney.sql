with tourney_attrs as (
    select distinct 
        tourney_id,
        tourney_name,
        tour,
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
        a.tour,
        a.surface,
        a.draw_size,
        a.tourney_level, 
        a.indoor,
        a.tourney_date,
        c.tourney_winner
    from tourney_attrs as a
    left join champions as c
    on a.tourney_id = c.tourney_id 
)

select * from final
