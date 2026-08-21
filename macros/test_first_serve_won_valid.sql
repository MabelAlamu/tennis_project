{% test first_serve_won_valid(model, player_id, player_name, stg=true) %}

{{ get_player_service_stats(model, player_id, player_name, stg) }}

select *
from combined
-- assuming 0 means the data isn't recorded at source
where (first_serve_in > 0 and first_serve_won > first_serve_in)
   or (total_service_points > 0 and first_serve_won > total_service_points) 

{% endtest %}