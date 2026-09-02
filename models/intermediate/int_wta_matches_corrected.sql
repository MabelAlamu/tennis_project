with source as (
 select * from {{ ref('stg_raw__wta_matches') }}
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
        s.tourney_match_num,
        s.winner_id,
        s.winner_id as winner_id_fixed,
        {{ clean_numeric_seed ('s.winner_seed', 's.winner_entry')}} as winner_seed,
        {{ clean_entry_code('s.winner_entry','s.winner_seed')}} as winner_entry,
        s.winner_name,
        s.winner_name as winner_name_fixed,
        s.winner_hand,
        s.winner_ht,
        s.winner_country_code,
        s.winner_age,
        s.winner_rank,
        s.winner_rank_points,
        s.loser_id,
        s.loser_id as loser_id_fixed,
        {{ clean_numeric_seed ('s.loser_seed', 's.loser_entry')}} as loser_seed,
        {{ clean_entry_code('s.loser_entry', 's.loser_seed') }} as loser_entry,
        s.loser_name,
        s.loser_name as loser_name_fixed,
        s.loser_hand,
        s.loser_ht,
        s.loser_country_code,
        s.loser_age,
        s.loser_rank,
        s.loser_rank_points,
        s.score,
        s.best_of,
        s.round,
        s.match_duration,
        -- Null out the entire serve-stat block for matches flagged in
        -- atp_match_stat_corrections. These matches failed the
        -- first_serve_won_valid or first_serve_in_valid tests and could
        -- not be confidently corrected.
        --
        -- The Jinja loop applies the same correction to all 18 columns.
        {% set stat_columns = [
            'w_ace', 'w_df', 'w_svpt', 'w_1stIn', 'w_1stWon', 'w_2ndWon', 'w_svgms', 'w_bpSaved', 'w_bpFaced',
            'l_ace', 'l_df', 'l_svpt', 'l_1stIn', 'l_1stWon', 'l_2ndWon', 'l_svgms', 'l_bpSaved', 'l_bpFaced'] %}
        {%-for col in stat_columns-%}
        iff(msc.tourney_match_num is not null, null, s.{{ col }}) as {{ col }}{{ "," if not loop.last }}
        {% endfor %}
     
    from source as s

    -- Identify matches with internally inconsistent serve statistics.
    left join {{ ref('wta_match_stat_corrections') }} as msc
        on  s.tourney_id = msc.tourney_id
        and s.tourney_match_num = msc.tourney_match_num
        and s.winner_id = msc.winner_id

),
-- Remove unverifiable score conflicts; for identical duplicates,
-- retain the earliest tourney_match_num.
deduplicated as (
    {{deduplicate_matches('renamed','winner_id_fixed','loser_id_fixed')}}
)

select * from deduplicated


