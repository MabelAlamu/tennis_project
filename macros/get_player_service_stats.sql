{% macro get_player_service_stats(model, player_id, player_name, stg=true) %}

with combined as (

    {% if stg %}

    select
        tourney_id,
        winner_{{ player_id }} as player_id,
        winner_{{ player_name }} as player_name,
        'winner' as player_type,
        tourney_match_num,
        w_1stwon as first_serve_won,
        w_1stin as first_serve_in,
        w_svpt as total_service_points
    from {{ model }}

    union all

    select
        tourney_id,
        loser_{{ player_id }} as player_id,
        loser_{{ player_name }} as player_name,
        'loser' as player_type,
        tourney_match_num,
        l_1stwon as first_serve_won,
        l_1stin as first_serve_in,
        l_svpt as total_service_points
    from {{ model }}

    {% else %}

    select
        tourney_id,
        {{ player_id }} as player_id,
        {{ player_name }} as player_name,
        player_type,
        tourney_match_num,
        first_serve_won,
        first_serve_in,
        total_service_points
    from {{ model }}

    {% endif %}

)

{% endmacro %}
