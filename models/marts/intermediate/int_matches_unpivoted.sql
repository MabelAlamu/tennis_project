with unpivoted as (

    select
        match_id,
        tour,
        tourney_id,
        tourney_name,
        surface,
        draw_size,
        tourney_level,
        indoor,
        tourney_date,
        tourney_match_num,
        winner_id_fixed as player_id,
        winner_name as player_name,
        'Win' as result,
        winner_seed as player_seed,
        winner_entry as player_entry,
        winner_hand as player_hand,
        winner_ht as player_ht,
        winner_country_code as player_country_code,
        winner_age as player_age,
        winner_rank as player_rank,
        winner_rank_points as player_rank_points,
        w_ace as ace,
        w_df as double_fault,
        w_svpt as total_service_points,
        w_1stIn as first_serve_in,
        w_1stWon as first_serve_won,
        w_2ndWon as second_serve_won,
        w_svgms as service_games,
        w_bpSaved as bp_saved,
        w_bpFaced as bp_faced,
        score,
        best_of,
        round,
        match_duration,
        match_status
    from {{ ref('int_matches_filtered') }}

    union all

    select
        match_id,
        tour,
        tourney_id,
        tourney_name,
        surface,
        draw_size,
        tourney_level,
        indoor,
        tourney_date,
        tourney_match_num,
        loser_id_fixed as player_id,
        loser_name as player_name,
        'Loss' as result,
        loser_seed as player_seed,
        loser_entry as player_entry,
        loser_hand as player_hand,
        loser_ht as player_ht,
        loser_country_code as player_country_code,
        loser_age as player_age,
        loser_rank as player_rank,
        loser_rank_points as player_rank_points,
        l_ace as ace,
        l_df as double_fault,
        l_svpt as total_service_points,
        l_1stIn as first_serve_in,
        l_1stWon as first_serve_won,
        l_2ndWon as second_serve_won,
        l_svgms as service_games,
        l_bpSaved as bp_saved,
        l_bpFaced as bp_faced,
        score,
        best_of,
        round,
        match_duration,
        match_status
    from {{ ref('int_matches_filtered') }}

),
final as (
    select 
        {{ dbt_utils.generate_surrogate_key(['match_id','player_id']) }} as player_match_id,
        up.*,
        case --clean up player_entry -- see tennis_docs.md for reasoning
            when player_entry in ('ALT', 'A') then 'ALT'
            when player_entry in ('PR', 'SR') then 'PR'
            when player_entry in ('ITF', 'IP') then 'ITF'
            else player_entry  -- WC, Q, LL, SE, UP, NG stay as they are
        end as player_entry_category
    from unpivoted as up
    where player_id is not null -- excludes 3 rows with no player_id recorded in source, see tennis_docs.md
)

select * from final