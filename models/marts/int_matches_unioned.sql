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
select * from combined