with atp_count as (

    select
        count(*) as expected_atp_rows
    from {{ ref('int_atp_matches_corrected') }}
    where tourney_date >= '2000-01-01'

),

wta_count as (

    select
        count(*) as expected_wta_rows
    from {{ ref('int_wta_matches_corrected') }}
    where tourney_date >= '2000-01-01'

),

prepared_count as (

    select
        count_if(tour = 'ATP') as actual_atp_rows,
        count_if(tour = 'WTA') as actual_wta_rows
    from {{ ref('int_matches_prepared') }}

)

select
    atp_count.expected_atp_rows,
    prepared_count.actual_atp_rows,
    wta_count.expected_wta_rows,
    prepared_count.actual_wta_rows
from atp_count
cross join wta_count
cross join prepared_count
where atp_count.expected_atp_rows
        <> prepared_count.actual_atp_rows
   or wta_count.expected_wta_rows
        <> prepared_count.actual_wta_rows