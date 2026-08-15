with player_appearances as(
    select 
      winner_id as player_id,
      winner_name as player_name,
      'winner' as player_type,
    from {{ ref('stg_atp') }}


    union all 

    select 
      loser_id as player_id,
      loser_name as player_name,
      'loser' as player_type,
    from {{ ref('stg_atp') }}
 

)
select
    player_id,
    count(distinct player_name) as name_count
from player_appearances
where player_id is not null
group by player_id
having count(distinct player_name) > 1