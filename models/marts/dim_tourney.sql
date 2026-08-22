select
    tourney_id,
    tourney_name,
    surface,
    tourney_level, 
    indoor
from {{ ref('int_matches_unpivoted') }}