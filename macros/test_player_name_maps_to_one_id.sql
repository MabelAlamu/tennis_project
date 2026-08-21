{% test player_name_maps_to_one_id(model, player_id, player_name) %}
{{get_player_basic_info (model, player_id, player_name)}}
select
    player_name,
    listagg(distinct player_id, '; ') as player_ids,
    count(distinct player_id) as id_count
from players
where player_name is not null
group by player_name
having count(distinct player_id) > 1
{% endtest %}