with 

source as (

    select * from {{ source('raw', 'players') }}

),

renamed as (

    select
        id as player_id,
        player as player_name,
        atpname,
        birthdate as dob,
        weight,
        height,
        turnedpro as year_turned_pro,
        birthplace,
        coaches,
        hand as player_hand,
        backhand as player_backhand,
        ioc as country_code
    -- there are two rows that are duplicated, used qualify to filter out the duplicates  
    from source qualify row_number() over (partition by player_id order by player_id) = 1

)

select * from renamed