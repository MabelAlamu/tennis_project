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
)
/*select distinct tourney_id, tourney_name, count(surface)  
from combined 
group by tourney_id, tourney_name
having count(surface) > 1*/
select
    {{ dbt_utils.generate_surrogate_key(['tour', 'tourney_id', 'tourney_date', 'tourney_name']) }} as tourney_id,
    c.tourney_id as tourney_id_raw,
    c.* exclude (tourney_id)
from combined as c
