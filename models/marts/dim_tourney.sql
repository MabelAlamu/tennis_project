with tourney_attrs as (
    select distinct 
        tourney_id,
        tourney_name,
        tour,
        case when tourney_level != 'D' then draw_size end as draw_size,
        tourney_level, 
        tourney_start_date
    from {{ ref('int_matches_unpivoted') }}
)
select * from tourney_attrs

