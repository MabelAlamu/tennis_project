with source as (
    {{ dbt_utils.deduplicate(
        relation=source('raw', 'wta_matches'),
        partition_by='tourney_id, tourney_date, winner_id, loser_id, round',
        order_by="match_num",
    )
    }}
),

renamed as (

    select
        s.tourney_id,
        s.tourney_name,
        s.surface,
        s.draw_size,
        s.tourney_level,
        s.indoor,
        to_date(cast(s.tourney_date as varchar), 'YYYYMMDD') as tourney_date,
        s.match_num as tourney_match_num,
        s.winner_id,
        s.winner_id as winner_id_fixed,
        {{ clean_numeric_seed ('s.winner_seed', 's.winner_entry')}} as winner_seed,
        {{ clean_entry_code('s.winner_entry','s.winner_seed')}} as winner_entry,
        s.winner_name,
        s.winner_hand,
        s.winner_ht,
        s.winner_ioc as winner_country_code,
        s.winner_age,
        s.winner_rank,
        s.winner_rank_points,
        s.loser_id,
        s.loser_id as loser_id_fixed,
        {{ clean_numeric_seed ('s.loser_seed', 's.loser_entry')}} as loser_seed,
        {{ clean_entry_code('s.loser_entry', 's.loser_seed') }} as loser_entry,
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
        iff(msc.tourney_match_num is not null, null, s.{{ col }}) as {{ col }}{{ "," if not loop.last }}
        {% endfor %}
     
    from source as s
    -- fix for incorrect stats
    left join {{ ref('wta_match_stat_corrections') }} as msc
        on  s.tourney_id = msc.tourney_id
        and s.match_num = msc.tourney_match_num
        and s.winner_id = msc.winner_id

)

select
    {{ dbt_utils.generate_surrogate_key(['tourney_id', 'tourney_date', 'winner_id', 'loser_id', 'round']) }} as match_id,
    r.*
from renamed as r

--select distinct winner_seed from renamed union all select distinct loser_seed from renamed