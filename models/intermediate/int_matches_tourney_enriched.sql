{{ config(materialized='table') }}

with all_matches as (

    select * from {{ ref('int_matches_prepared') }}
),
-- Raw tournament-name variants mapped to one standard name.
tourney_mapping as (

    select
        source_tourney_name,
        standard_tourney_name
    from {{ ref('tourney_name_mapping') }}
),
-- Known cases where tournament level was incorrectly recorded
-- for a particular tournament edition.
tourney_level_corrections as (

    select
        tourney_name,
        tourney_year,
        bad_tourney_level,
        correct_tourney_level
    from {{ ref('tourney_level_corrections') }}
),
-- Known draw-size errors confirmed against tournament records.
-- The source tournament ID is used because tournament names and years
-- may not uniquely identify an event, particularly for team competitions.
draw_size_corrections as (

    select
        tour,
        tourney_id_raw,
        corrected_draw_size
    from {{ ref('draw_size_corrections') }}
),
tourney_corrected as (

    select
        am.* exclude (tourney_name, tourney_level, draw_size),

        -- Collapse historical team-competition naming variants before
        -- falling back to the general tournament-name mapping.
        case
            when am.tourney_name ilike 'Davis Cup%' then 'Davis Cup'
            when am.tourney_name ilike any ('Fed Cup%', 'Billie Jean King Cup%', 'BJK Cup%') then 'Billie Jean King Cup'
            else coalesce(tm.standard_tourney_name, am.tourney_name)
        end as tourney_name,
        year(am.tourney_date) as tourney_year,
        -- Use the reviewed tournament-level correction when one exists.
        coalesce(tlc.correct_tourney_level, am.tourney_level) as tourney_level,

        -- Use the reviewed draw-size correction when one exists.
        coalesce(dsc.corrected_draw_size, am.draw_size) as draw_size

    from all_matches as am
    left join tourney_mapping as tm
        on am.tourney_name = tm.source_tourney_name

    left join tourney_level_corrections as tlc
        on am.tourney_name = tlc.tourney_name
        and year(am.tourney_date) = tlc.tourney_year
        and am.tourney_level = tlc.bad_tourney_level

    left join draw_size_corrections as dsc
        on am.tour = dsc.tour
        and am.tourney_id_raw = dsc.tourney_id_raw
),
with_grouping_key as (

    select
        tc.*,

        -- Team competitions can have multiple source IDs for ties within
        -- the same annual competition, so group them by tour, corrected
        -- name, corrected level and year.
        -- Other tournaments retain the source tournament ID because it
        -- identifies the individual tournament edition.
        case
            when tc.tourney_level = 'D'
                then concat(tc.tour, '|',tc.tourney_name,'|',tc.tourney_level,'|',tc.tourney_year)
            else concat(tc.tour,'|',tc.tourney_id_raw)
        end as tourney_group_key
    from tourney_corrected as tc
),
with_start_date as (

    select
        wg.*,
        -- Some source records contain match dates rather than a consistent
        -- tournament start date. Use the earliest date in each corrected
        -- tournament group as the canonical start date.
        min(wg.tourney_date) over (partition by wg.tourney_group_key) as tourney_start_date
    from with_grouping_key as wg
),
final as (

    select
        -- Create the project's canonical tournament identifier from
        -- corrected tournament attributes.
        {{ dbt_utils.generate_surrogate_key(['tour','tourney_name','tourney_level','tourney_start_date']) }} as tourney_id,
        ws.* exclude (tourney_group_key)
    from with_start_date as ws
)

select * from final