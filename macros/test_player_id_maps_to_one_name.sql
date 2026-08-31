{% test player_id_maps_to_one_name(model, player_id, player_name) %}

{{ get_player_basic_info(model, player_id, player_name) }},

player_pairs as (

    -- Reduce the match history to one row per distinct ID–name pair.
    -- Repeated match appearances should not affect the identity check.
    select distinct
        player_id,
        player_name
    from players
    where player_id is not null
      and player_name is not null

),

reviewed_pairs as (

    -- Identity combinations that have already been investigated.
    -- Inclusion means that the relationship is understood, not that
    -- every recorded spelling is necessarily canonical.
    select
        player_id,
        player_name
    from {{ ref('reviewed_player_identity_pairs') }}

)

select
    pp.player_id,

    -- Show every recorded name for the ID in a stable order.
    listagg(distinct pp.player_name, '; ')
        within group (order by pp.player_name) as player_names,

    -- Count the number of names associated with the player ID.
    count(distinct pp.player_name) as name_count,

    -- Count the ID–name pairs that were not found in the reviewed seed.
    count_if(rp.player_id is null) as unreviewed_pair_count

from player_pairs as pp

-- Retain unreviewed pairs so they can be detected through a null match.
left join reviewed_pairs as rp
    on pp.player_id = rp.player_id
    and pp.player_name = rp.player_name

group by pp.player_id

-- Warn only when an ID has multiple names and at least one of the
-- identity combinations has not previously been reviewed.
having count(distinct pp.player_name) > 1
   and count_if(rp.player_id is null) > 0

{% endtest %}