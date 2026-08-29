-- Deliberately incorrect for testing CI protection.
-- A dbt test fails when this query returns one or more rows.

with player_count as (

    select count(*) as row_count
    from {{ ref('dim_player') }}

)

select *
from player_count
where row_count > 0