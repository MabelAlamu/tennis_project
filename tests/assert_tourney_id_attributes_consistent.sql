-- Every match row sharing a tourney_id should agree on the attributes
-- that define that tourney. If a single tourney_id maps to more than
-- one distinct combination of these, something upstream (corrections or key generation) 
-- let inconsistent data through before dim_tourney even gets built.
--
-- draw_size is checked too, but excluded for team events (tourney_level
-- = 'D') in the case expression below: Davis Cup/BJK Cup legitimately
-- have multiple draw_size values per tourney_id (round-robin groups vs
-- knockout ties). With that known exception filtered out here, any
-- remaining failure is a genuine issue, not a false positive

select
    tourney_id,
    count(distinct tour) as n_tour,
    count(distinct tourney_name) as n_tourney_name,
    count(distinct tourney_level) as n_tourney_level,
    count(distinct tourney_start_date) as n_tourney_start_date,
    count(distinct case when tourney_level != 'D' then draw_size end) as n_draw_size
from {{ ref('int_matches_tourney_enriched') }}
group by tourney_id
having
    count(distinct tour) > 1
    or count(distinct tourney_name) > 1
    or count(distinct tourney_level) > 1
    or count(distinct tourney_start_date) > 1
    or count(distinct case when tourney_level != 'D' then draw_size end) > 1