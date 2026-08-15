with combined as (

    select
        tourney_id,
        winner_id as player_id,
        'winner' as player_type,
        w_1stWon as first_serve_won,
        w_1stIn as first_serve_in,
        w_svpt as total_service_points
    from {{ ref('stg_atp') }}

    union all

    select
        tourney_id, 
        loser_id as player_id,
        'loser' as player_type,
        l_1stWon as first_serve_won,
        l_1stIn as first_serve_in,
        l_svpt as total_service_points
    from {{ ref('stg_atp') }}

)

select *
from combined
where first_serve_won > first_serve_in
   or first_serve_won > total_service_points