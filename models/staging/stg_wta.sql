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
        -- Some entry codes are compound values like '6/ITF' (seed + entry method
        -- crammed into one field). If winner/loser_seed is null but the
        -- seed is embedded in loser_entry, extract and backfill it here.
        coalesce(s.winner_seed, try_to_number(split_part(s.winner_entry, '/', 1))) as winner_seed,
        -- Split off the entry-method half of any compound value (e.g. '6/ITF' -> 'ITF'),
        -- leaving plain codes (WC, Q, LL, etc.) untouched. Also standardizes casing/
        -- whitespace (Alt/alt -> ALT, ' wc' -> 'WC') so accepted_values matches cleanly.
        upper(trim(case when winner_entry like '%/%' then split_part(winner_entry, '/', 2) else winner_entry end)) as winner_entry,
        s.winner_name,
        s.winner_hand,
        s.winner_ht,
        s.winner_ioc as winner_country_code,
        s.winner_age,
        s.winner_rank,
        s.winner_rank_points,
        s.loser_id,
        coalesce(s.loser_seed, try_to_number(split_part(s.loser_entry, '/', 1))) as loser_seed,
        upper(trim(case when loser_entry like '%/%' then split_part(loser_entry, '/', 2) else loser_entry end)) as loser_entry,
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




