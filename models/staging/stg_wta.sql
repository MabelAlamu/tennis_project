with 

source as (

    select * from {{ source('raw', 'wta_matches') }}

),

renamed as (

    select
        tourney_id,
        tourney_name,
        surface,
        draw_size,
        tourney_level,
        indoor,
        tourney_date,
        match_num as tourney_match_num,
        winner_id,
        winner_seed,
        upper(trim(winner_entry)) as winner_entry,
        winner_name,
        winner_hand,
        winner_ht,
        winner_ioc as winner_country,
        winner_age,
        winner_rank,
        winner_rank_points,
        loser_id,
        loser_seed,
        upper(trim(loser_entry)) as loser_entry,
        loser_name,
        loser_hand,
        loser_ht,
        loser_ioc as loser_country,
        loser_age,
        loser_rank,
        loser_rank_points,
        score,
        best_of,
        round,
        minutes as match_duration,
        w_ace,
        w_df,
        w_svpt,
        w_1stin,
        w_1stwon,
        w_2ndwon,
        w_svgms,
        w_bpsaved,
        w_bpfaced,
        l_ace,
        l_df,
        l_svpt,
        l_1stin,
        l_1stwon,
        l_2ndwon,
        l_svgms,
        l_bpsaved,
        l_bpfaced

    from source

)

--select * from renamed

select distinct winner_entry from renamed UNION ALL select distinct loser_entry from renamed