-- the opponent self-join assumes exactly two player rows per match,
-- this test verifies that condition
select
    match_id,
    count(*) as player_count
from {{ ref('int_matches_unpivoted') }}
group by match_id
having count(*) <> 2