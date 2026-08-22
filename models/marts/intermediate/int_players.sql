with match_player_attrs as (

    -- Most frequently recorded value per player, computed independently
    -- per column (mode() ignores nulls per-column, so a player missing
    -- one attribute still fully contributes to the others). Guards
    -- against the rare name-spelling variant (e.g. "Alexander" vs
    -- "Aleksander" Shevchenko) and any inconsistency across match rows
    -- for hand/height/country_code.
    select
        player_id,
        mode(player_name) as player_name,
        mode(player_hand) as hand,
        mode(player_ht) as height,
        mode(player_country_code) as country_code,
        mode(tour) as tour
    from {{ ref('int_matches_unpivoted') }}
    where player_id is not null
    group by player_id

),

final as (

    select
        a.player_id,
        a.player_name,
        case 
            when a.tour = 'WTA' then 'F'
            when a.tour = 'ATP' then 'M'
            else null
        end as gender,
        coalesce(a.hand, pb.player_hand) as hand,
        coalesce(a.height, pb.height) as height,
        pb.weight,
        pb.birthdate,
        pb.birthplace,
        pb.year_turned_pro,
        coalesce(a.country_code, pb.country_code) as country_code,
        case
            when pb.player_id is not null then 'players_bio'
            else 'matches_only'
        end as bio_source
    from match_player_attrs as a
    left join {{ ref('stg_players_bio') }} as pb
        on a.player_id = pb.player_id

)

select * from final
