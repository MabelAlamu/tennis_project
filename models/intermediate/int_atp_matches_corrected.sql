with source as (
    select * from {{ ref('stg_raw__atp_matches') }}
),

merge_w as (
    select * from {{ ref('atp_player_id_merge_map') }}
),

merge_l as (
    select * from {{ ref('atp_player_id_merge_map') }}
),

corr_w as (
    select * from {{ ref('atp_player_id_corrections') }}
),

corr_l as (
    select * from {{ ref('atp_player_id_corrections') }}
),

name_corr_w as (
    select * from {{ ref('atp_player_name_corrections') }}
),

name_corr_l as (
    select * from {{ ref('atp_player_name_corrections') }}
),

id_fixed as (

    -- Correct winner and loser IDs using:
    -- 1. specific ID-and-name corrections;
    -- 2. general player-ID merge mappings;
    -- 3. the original source ID when no correction exists.
    select
        s.*,
        coalesce(
            cw.correct_player_id,
            mw.right_player_id,
            s.winner_id
        ) as winner_id_fixed,
        coalesce(
            cl.correct_player_id,
            ml.right_player_id,
            s.loser_id
        ) as loser_id_fixed
    from source as s

    left join merge_w as mw
        on s.winner_id = mw.old_player_id

    left join corr_w as cw
        on s.winner_id = cw.bad_player_id
        and s.winner_name = cw.player_name

    left join merge_l as ml
        on s.loser_id = ml.old_player_id

    left join corr_l as cl
        on s.loser_id = cl.bad_player_id
        and s.loser_name = cl.player_name

),
renamed as (

    select
        f.tourney_id,
        f.tourney_name,
        f.surface,
        f.draw_size,
        f.tourney_level,
        f.indoor,
        f.tourney_date,
        f.tourney_match_num,
        f.winner_id,
        f.winner_id_fixed,
        {{ clean_numeric_seed('f.winner_seed','f.winner_entry') }} as winner_seed,
        {{ clean_entry_code('f.winner_entry','f.winner_seed') }} as winner_entry,
        -- Use the reviewed corrected name when one exists.
        -- Otherwise preserve the original source name.
        f.winner_name,
        coalesce(ncw.correct_player_name, f.winner_name) as winner_name_fixed,
        f.winner_hand,
        f.winner_ht,
        f.winner_country_code,
        f.winner_age,
        f.winner_rank,
        f.winner_rank_points,
        f.loser_id,
        f.loser_id_fixed,
        {{ clean_numeric_seed('f.loser_seed', 'f.loser_entry') }} as loser_seed,
        {{ clean_entry_code( 'f.loser_entry', 'f.loser_seed' ) }} as loser_entry,
        -- Use the reviewed corrected name when one exists.
        -- Otherwise preserve the original source name.
        f.loser_name,
        coalesce(ncl.correct_player_name, f.loser_name) as loser_name_fixed,
        f.loser_hand,
        f.loser_ht,
        f.loser_country_code,
        f.loser_age,
        f.loser_rank,
        f.loser_rank_points,
        f.score,
        f.best_of,
        f.round,
        f.match_duration,

        -- Null out the entire serve-stat block for matches flagged in
        -- atp_match_stat_corrections. These matches failed the
        -- first_serve_won_valid or first_serve_in_valid tests and could
        -- not be confidently corrected.
        --
        -- The Jinja loop applies the same correction to all 18 columns.
        {% set stat_columns = [
            'w_ace', 'w_df', 'w_svpt', 'w_1stIn', 'w_1stWon', 'w_2ndWon', 'w_svgms', 'w_bpSaved', 'w_bpFaced',
            'l_ace', 'l_df', 'l_svpt', 'l_1stIn', 'l_1stWon', 'l_2ndWon', 'l_svgms', 'l_bpSaved', 'l_bpFaced'] %}
        {%- for col in stat_columns %}
        iff(
            msc.tourney_match_num is not null,
            null,
            f.{{ col }}
        ) as {{ col }}{{ "," if not loop.last }}
        {% endfor %}

    from id_fixed as f

    -- Identify matches with internally inconsistent serve statistics.
    left join {{ ref('atp_match_stat_corrections') }} as msc
        on f.tourney_id = msc.tourney_id
        and f.tourney_match_num = msc.tourney_match_num
        and f.winner_id_fixed = msc.winner_id_fixed

    -- Apply reviewed winner-name corrections to one specific match
    -- and player combination.
    left join name_corr_w as ncw
        on f.tourney_id = ncw.tourney_id
        and f.tourney_match_num = ncw.tourney_match_num
        and f.winner_id_fixed = ncw.player_id
        and f.winner_name = ncw.bad_player_name

    -- Apply reviewed loser-name corrections to one specific match
    -- and player combination.
    left join name_corr_l as ncl
        on f.tourney_id = ncl.tourney_id
        and f.tourney_match_num = ncl.tourney_match_num
        and f.loser_id_fixed = ncl.player_id
        and f.loser_name = ncl.bad_player_name

),
-- Remove unverifiable score conflicts; for identical duplicates,
-- retain the earliest tourney_match_num.
deduplicated as (
    {{deduplicate_matches('renamed','winner_id_fixed','loser_id_fixed')}}
)

select * from deduplicated

