with source as (
    select * from {{ source('raw', 'atp_matches') }}
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

id_fixed as (
    -- fix for winner and loser id
    select
        s.*,
        coalesce(cw.correct_player_id, mw.right_player_id, s.winner_id) as winner_id_fixed,
        coalesce(cl.correct_player_id, ml.right_player_id, s.loser_id) as loser_id_fixed
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
        to_date(cast(f.tourney_date as varchar), 'YYYYMMDD') as tourney_date,
        f.match_num as tourney_match_num,
        f.winner_id,
        f.winner_id_fixed,
        f.winner_seed,
        f.winner_entry,
        f.winner_name,
        f.winner_hand,
        f.winner_ht,
        f.winner_ioc as winner_country_code,
        f.winner_age,
        f.winner_rank,
        f.winner_rank_points,
        f.loser_id,
        f.loser_id_fixed,
        f.loser_seed,
        f.loser_entry,
        f.loser_name,
        f.loser_hand,
        f.loser_ht,
        f.loser_ioc as loser_country_code,
        f.loser_age,
        f.loser_rank,
        f.loser_rank_points,
        f.score,
        f.best_of,
        f.round,
        f.minutes as match_duration,
        -- Null out the entire serve-stats block (all w_*/l_* columns) for any
        -- match flagged in wta_match_stat_corrections (seed). These matches
        -- failed the first_serve_won_valid / first_serve_in_valid tests with
        -- internally inconsistent numbers that couldn't be confidently corrected, 
        -- so the whole stat line is nulled.
        --
        -- Looping over stat_columns instead of writing 18 individual
        -- `iff(...)` lines by hand with one flag check (msc.tourney_match_num
        -- is not null). This applies identically to every column, so the Jinja
        -- for-loop generates all 18 lines from one list.
        {% set stat_columns = [
            'w_ace', 'w_df', 'w_svpt', 'w_1stIn', 'w_1stWon', 'w_2ndWon', 'w_svgms', 'w_bpSaved', 'w_bpFaced',
            'l_ace', 'l_df', 'l_svpt', 'l_1stIn', 'l_1stWon', 'l_2ndWon', 'l_svgms', 'l_bpSaved', 'l_bpFaced'] %}
        {%-for col in stat_columns-%}
        iff(msc.tourney_match_num is not null, null, f.{{ col }}) as {{ col }}{{ "," if not loop.last }}
        {% endfor %}
    from id_fixed as f
    -- fix for incorrect player stats
    left join {{ ref('atp_match_stat_corrections') }} as msc
        on f.tourney_id = msc.tourney_id
        and f.match_num = msc.tourney_match_num
        and f.winner_id_fixed = msc.winner_id_fixed

)


select
    {{ dbt_utils.generate_surrogate_key(['tourney_id', 'tourney_date', 'winner_id_fixed', 'loser_id_fixed', 'round']) }} as match_id,
    r.*
from renamed as r
qualify row_number() over (
    partition by tourney_id, tourney_date, winner_id_fixed, loser_id_fixed, round, score
    order by tourney_match_num
) = 1

