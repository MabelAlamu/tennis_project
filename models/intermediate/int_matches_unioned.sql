with combined as (
    -- union ATP and WTA staging models into one match-level table, tagged by tour
    select
        atp.*,
        'ATP' as tour
    from {{ ref('stg_atp') }} as atp

    union all

    select 
        wta.*,
        'WTA' as tour
    from {{ ref('stg_wta') }} as wta
),

-- Correction seeds 
-- these fix known errors/inconsistencies in the raw source data.
-- kept together here since they're all the same kind of operation:
-- look up a known-bad value, coalesce to the corrected one.

tourney_mapping as (
    -- raw tourney_name spellings/variants -> one canonical name per event
    select source_tourney_name, standard_tourney_name
    from {{ ref('tourney_name_mapping') }}
),

tourney_level_corrections as (
    -- fixes rows where tourney_level was mis-recorded for a given event/year
    select tourney_name, tourney_year, bad_tourney_level, correct_tourney_level
    from {{ ref('tourney_level_corrections') }}
),

draw_size_corrections as (
    -- fixes rows where draw_size was mis-recorded for a given event
    -- (confirmed case-by-case: total matches for the event should equal
    -- draw_size - 1 in a single-elim bracket; mismatches were looked up
    -- against official sources). keyed on raw tourney_id since it's unique
    -- per physical event, unlike tourney_name/year/level which can collide
    -- (e.g. Davis Cup ties across countries in the same year).
    select tour, tourney_id_raw, corrected_draw_size
    from {{ ref('draw_size_corrections') }}
),


final as (
    select 
        c.* exclude (tourney_name, tourney_level, draw_size),

        -- collapse team-competition name variants (Davis Cup/BJK Cup have
        -- historically inconsistent raw names, e.g. group/tie info baked in)
        -- before falling back to the general name-mapping seed
        case
            when c.tourney_name ilike 'Davis Cup%' then 'Davis Cup'
            when c.tourney_name ilike any ('Fed Cup%', 'Billie Jean King Cup%', 'BJK Cup%') then 'Billie Jean King Cup'
            else coalesce(tm.standard_tourney_name, c.tourney_name)
        end as tourney_name,

        year(c.tourney_date) as tourney_year,

        coalesce(tlc.correct_tourney_level, c.tourney_level) as tourney_level,

        -- apply draw_size correction if this raw tourney_id has one, else keep raw value
        coalesce(dsc.corrected_draw_size, c.draw_size) as draw_size,

        -- standardise raw score text into a match outcome flag
        case when c.score like '%RET%' then 'Retired'
             when c.score like '%DEF%' then 'Default'
             when c.score like '%W/O%' then 'Walkover'
             else 'Completed'
        end as match_status
    from combined as c
    left join tourney_mapping as tm
        on c.tourney_name = tm.source_tourney_name
    left join tourney_level_corrections as tlc
        on c.tourney_name = tlc.tourney_name
        and year(c.tourney_date) = tlc.tourney_year
        and c.tourney_level = tlc.bad_tourney_level
    left join draw_size_corrections as dsc
        on c.tour = dsc.tour
        and c.tourney_id = dsc.tourney_id_raw
)

select * from final