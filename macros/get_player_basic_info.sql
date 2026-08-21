{% macro get_player_basic_info(model, player_id, player_name) %}

with players as (

    select
        winner_{{ player_id }} as player_id,
        winner_{{ player_name }} as player_name,
        'winner' as player_type,
    from {{ model }}

    union all

    select
        loser_{{ player_id }} as player_id,
        loser_{{ player_name }} as player_name,
        'loser' as player_type,
    from {{ model }}

)

{% endmacro %}
