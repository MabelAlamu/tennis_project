with player_appearances as (

    select winner_id_fixed as player_id, winner_name as player_name
    from {{ ref('stg_atp') }}

    union all

    select loser_id_fixed as player_id, loser_name as player_name
    from {{ ref('stg_atp') }}

)

select
    player_name,
    listagg(distinct player_id, '; ') as player_ids,
    count(distinct player_id) as id_count
from player_appearances
where player_name is not null
group by player_name
having count(distinct player_id) > 1