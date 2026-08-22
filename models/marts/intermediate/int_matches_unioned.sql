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
select 
    {{ dbt_utils.generate_surrogate_key(['tour', 'tourney_id']) }} as new_tourney_id,
    c.* 
from combined as c