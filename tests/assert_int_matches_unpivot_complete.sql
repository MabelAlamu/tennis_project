with
filter_count as (
    select count(*) as n_rows from {{ ref('int_matches_tourney_enriched') }}
),
unpivoted_count as (
    select count(*) as n_rows from {{ ref('int_matches_unpivoted') }}
),
excluded_count as ( --null player_id rows were dropped in int_matches_unpivoted
    select count(*) as n_rows
    from (
        select match_id, winner_id_fixed as player_id from {{ ref('int_matches_tourney_enriched') }}
        union all
        select match_id, loser_id_fixed as player_id from {{ ref('int_matches_tourney_enriched') }}
    )
    where player_id is null
)

select *
from filter_count, unpivoted_count, excluded_count
where unpivoted_count.n_rows != (filter_count.n_rows * 2) - excluded_count.n_rows
