{% test player_id_maps_to_one_name(model, player_id, player_name) %}
{{get_player_basic_info (model, player_id, player_name)}}
select
    player_id,
    listagg(distinct player_name, '; ') as player_names,
    count(distinct player_name) as name_count
from players
where player_id is not null
group by player_id
having count(distinct player_name) > 1
{% endtest %}