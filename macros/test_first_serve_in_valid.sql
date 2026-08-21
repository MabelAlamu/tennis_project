{%test first_serve_in_valid (model, player_id, player_name, stg=true) %}

{{ get_player_service_stats(model, player_id, player_name, stg)}}

select *
from combined
where total_service_points > 0 -- assuming 0 means the data isn't recorded at source
 and first_serve_in > total_service_points

{% endtest %}