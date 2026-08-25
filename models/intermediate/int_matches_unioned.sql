with combined as (
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

tourney_mapping as (
    select source_tourney_name, standard_tourney_name
    from {{ ref('tourney_name_mapping') }}
),

tourney_level_corrections as (
    select tourney_name, tourney_year, bad_tourney_level, correct_tourney_level
    from {{ ref('tourney_level_corrections') }}
),

standardised as (
    select 
        c.* exclude (tourney_name, tourney_level),
        case
            when c.tourney_name ilike 'Davis Cup%' then 'Davis Cup'
            when c.tourney_name ilike any ('Fed Cup%', 'Billie Jean King Cup%', 'BJK Cup%') then 'Billie Jean King Cup'
            else coalesce(tm.standard_tourney_name, c.tourney_name)
        end as tourney_name,
        year(c.tourney_date) as tourney_year,
        coalesce(tlc.correct_tourney_level, c.tourney_level) as tourney_level,
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
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['tour', 'tourney_name', 'tourney_year', 'tourney_level']) }} as tourney_id,
        s.tourney_id as tourney_id_raw,
        s.* exclude (tourney_id),
        min(s.tourney_date) over (partition by s.tour, s.tourney_name, s.tourney_year, s.tourney_level) as tourney_start_date
    from standardised as s
)

select * from final
