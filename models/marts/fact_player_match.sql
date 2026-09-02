with player_matches as (
    select * from {{ ref('int_matches_unpivoted') }}
),
with_opponent as (

    select
        pm.*,
        opponent.player_id as opponent_id
    from player_matches as pm
    left join player_matches as opponent
        on pm.match_id = opponent.match_id
        and pm.player_match_id <> opponent.player_match_id

),
final as (

    select
        -- Primary and degenerate keys
        player_match_id,
        match_id,

        -- Dimension foreign keys
        tourney_id,
        player_id,
        opponent_id,

        -- Match context
        tourney_match_num,
        surface,
        result,
        round,
        score,
        best_of,
        match_duration,
        match_status,

        -- Player context at the time of the match
        player_seed,
        player_entry,
        player_entry_category,
        player_age,
        player_rank,
        player_rank_points,

        -- Serve-stat measures
        ace,
        double_fault,
        total_service_points,
        first_serve_in,
        first_serve_won,
        second_serve_won,
        service_games,
        bp_saved,
        bp_faced

    from with_opponent
)

select * from final