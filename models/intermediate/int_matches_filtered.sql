/*
with filtered as (
    -- drop pre-2000 matches, out of scope for the cluster analysis
    select *
    from {{ ref('int_matches_unioned') }}
    where tourney_year >= 2000
),
tourney_week as (
    select
        f.*,

        -- min() over the same grouping that already distinguishes real
        -- separate editions from team-competition ties
        -- (tourney_level = 'D', which stays collapsed to one per year).
        -- this also doubles as the 2026 fix: tourney_date is match-date
        -- that year rather than tourney-start-date, so min() picks the
        -- earliest one regardless.
        min(f.tourney_date) over (
            partition by
                f.tour, f.tourney_name, f.tourney_year, f.tourney_level,
                case when f.tourney_level != 'D' then f.draw_size end
        ) as tourney_start_date
    from filtered as f
),
final as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'tour', 'tourney_name', 'tourney_level', 'tourney_start_date'
        ]) }} as tourney_id,
        tw.tourney_id as tourney_id_raw,
        tw.* exclude (tourney_id)
    from tourney_week as tw
)

select * from final*/

with filtered as (
    -- drop pre-2000 matches, out of scope for the cluster analysis
    select *
    from {{ ref('int_matches_unioned') }}
    where tourney_year >= 2000
),

tourney_grouping_key as (
    select
        f.*,
        case
            when f.tourney_level = 'D'
                then concat(f.tour, '|', f.tourney_name, '|', f.tourney_level, '|', year(f.tourney_date))
            else concat(f.tour, '|', f.tourney_id)
        end as tourney_group_key
    from filtered as f
),

with_start_date as (
    select
        g.*,
        min(g.tourney_date) over (partition by g.tourney_group_key) as tourney_start_date
    from tourney_grouping_key as g
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'tour', 'tourney_name', 'tourney_level', 'tourney_start_date'
        ]) }} as tourney_id,
        d.tourney_id as tourney_id_raw,
        d.* exclude (tourney_id, tourney_group_key)
    from with_start_date as d
)

select * from final
