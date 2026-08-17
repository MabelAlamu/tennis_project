with source as (
    select * from {{ source('raw', 'atp_matches') }}
),
merge_w as (
    select * from {{ ref('player_id_merge_map') }}
),
merge_l as (
    select * from {{ ref('player_id_merge_map') }}
),
corr_w as (
    select * from {{ ref('player_id_corrections') }}
),
corr_l as (
    select * from {{ ref('player_id_corrections') }}
),

renamed as (

    select
        s.tourney_id,
        s.tourney_name,
        s.surface,
        s.draw_size,
        s.tourney_level,
        s.indoor,
        s.tourney_date,
        s.match_num as tourney_match_num,
        s.winner_id,
        coalesce(cw.correct_player_id, mw.right_player_id, s.winner_id) as winner_id_fixed,
        s.winner_seed,
        s.winner_entry,
        s.winner_name,
        s.winner_hand,
        s.winner_ht,
        s.winner_ioc as winner_country_code,
        s.winner_age,
        s.winner_rank,
        s.winner_rank_points,
        s.loser_id,
        coalesce(cl.correct_player_id, ml.right_player_id, s.loser_id) as loser_id_fixed,
        s.loser_seed,
        s.loser_entry,
        s.loser_name,
        s.loser_hand,
        s.loser_ht,
        s.loser_ioc as loser_country_code,
        s.loser_age,
        s.loser_rank,
        s.loser_rank_points,
        s.score,
        s.best_of,
        s.round,
        s.minutes as match_duration,
        {% set stat_columns = [
            'w_ace', 'w_df', 'w_svpt', 'w_1stIn', 'w_1stWon', 'w_2ndWon', 'w_svgms', 'w_bpSaved', 'w_bpFaced',
            'l_ace', 'l_df', 'l_svpt', 'l_1stIn', 'l_1stWon', 'l_2ndWon', 'l_svgms', 'l_bpSaved', 'l_bpFaced'] %}
        {%-for col in stat_columns-%}
        iff(msc.tourney_match_num is not null, null, s.{{ col }}) as {{ col }}{{ "," if not loop.last }}
        {% endfor %}
    from source as s
    -- fix for winner
    left join merge_w as mw
        on s.winner_id = mw.old_player_id
    left join corr_w as cw
        on s.winner_id = cw.bad_player_id
        and s.winner_name = cw.player_name
    -- fix for loser
    left join merge_l as ml
        on s.loser_id = ml.old_player_id
    left join corr_l as cl
        on s.loser_id = cl.bad_player_id
        and s.loser_name = cl.player_name
    -- fix for incorrect stats
    left join {{ ref('match_stat_corrections') }} as msc
        on s.tourney_id = msc.tourney_id
        and s.match_num = msc.tourney_match_num
        and winner_id_fixed = msc.winner_id_fixed

)

select
    {{ dbt_utils.generate_surrogate_key(['tourney_id', 'tourney_date', 'winner_id_fixed', 'loser_id_fixed', 'round']) }} as match_id,
    r.*
from renamed as r
qualify row_number() over (
    partition by tourney_id, tourney_date, winner_id_fixed, loser_id_fixed, round, score
    order by tourney_match_num
) = 1