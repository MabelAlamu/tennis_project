with 

source as (

    select * from {{ source('raw', 'atp_matches') }}

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
        winner_entry,
        winner_name,
        winner_hand,
        winner_ht,
        winner_ioc as winner_country_code,
        winner_age,
        winner_rank,
        winner_rank_points,
        loser_id,
        loser_seed,
        loser_entry,
        loser_name,
        loser_hand,
        loser_ht,
        loser_ioc as loser_country_code,
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

select * from renamed