{% test player_name_maps_to_one_id(model, player_id, player_name) %}

{{ get_player_basic_info(model, player_id, player_name) }},

player_pairs as (

    -- Reduce the match data to one row per distinct ID–name combination.
    -- This prevents a player appearing in many matches from affecting counts.
    select distinct
        player_id,
        player_name
    from players
    where player_id is not null
      and player_name is not null

      -- Unknown players are retained in staging but cannot be identity-checked.
      and player_name <> 'Unknown Unknown'

),

reviewed_pairs as (

    -- ID–name combinations that have already been investigated
    -- and confirmed as legitimate.
    select
        player_id,
        player_name
    from {{ ref('reviewed_player_identity_pairs') }}

)

select
    pp.player_name,

    -- Display all IDs associated with the name in a readable, stable order.
    listagg(distinct pp.player_id, '; ')
        within group (order by pp.player_id) as player_ids,

    -- Count how many distinct IDs are associated with the name.
    count(distinct pp.player_id) as id_count,

    -- Count ID–name pairs that did not match the reviewed allowlist.
    count_if(rp.player_id is null) as unreviewed_pair_count

from player_pairs as pp

-- Keep every source pair, even when no reviewed pair exists.
left join reviewed_pairs as rp 
    on pp.player_id = rp.player_id
    and pp.player_name = rp.player_name

group by pp.player_name

-- Return a failure only when:
-- 1. the name belongs to multiple IDs, and
-- 2. at least one of those ID–name pairs has not been reviewed.
having count(distinct pp.player_id) > 1
   and count_if(rp.player_id is null) > 0

{% endtest %}