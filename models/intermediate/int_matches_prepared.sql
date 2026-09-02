with combined as (
    -- union ATP and WTA int corrected models into one match-level table, tagged by tour
    select
        'ATP' as tour,
        atp.*
    from {{ ref('int_atp_matches_corrected') }} as atp

    union all

    select 
        'WTA' as tour, 
        wta.*
    from {{ ref('int_wta_matches_corrected') }} as wta
),

scoped as (
    -- drop pre-2000 matches, out of scope for the cluster analysis
    select * from combined
    where tourney_date >= '2000-01-01'
),

final as (
    select 
        s.*,
        -- standardise raw score text into a match outcome flag
        case when s.score like '%RET%' then 'Retired'
             when s.score like '%DEF%' then 'Default'
             when s.score like '%W/O%' then 'Walkover'
             else 'Completed'
        end as match_status
    from scoped as s
)

select
    {{ dbt_utils.generate_surrogate_key(['tour', 'tourney_id','tourney_date','winner_id_fixed','loser_id_fixed','round' ]) }} as match_id,
    f.tourney_id as tourney_id_raw,
    f.* exclude tourney_id, 
from final as f 

