with combined as (

    select
        tourney_id,
        winner_id_fixed as player_id,
        winner_name as player_name,
        'winner' as player_type,
        tourney_match_num,
        w_1stWon as first_serve_won,
        w_1stIn as first_serve_in,
        w_svpt as total_service_points
    from {{ ref('stg_atp') }}

    union all

    select
        tourney_id, 
        loser_id_fixed as player_id,
        loser_name as player_name, 
        'loser' as player_type,
        tourney_match_num,
        l_1stWon as first_serve_won,
        l_1stIn as first_serve_in,
        l_svpt as total_service_points
    from {{ ref('stg_atp') }}

)

select *
from combined
where (first_serve_in > 0 and first_serve_won > first_serve_in) -- assuming 0 means the data isn't recorded at source
   or (total_service_points > 0 and first_serve_won > total_service_points) -- assuming 0 means the data isn't recorded at source
