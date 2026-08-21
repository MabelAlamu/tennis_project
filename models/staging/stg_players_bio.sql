with source as (
    {{ dbt_utils.deduplicate(
    relation=source('raw', 'players'),
    partition_by='id, upper(player), birthdate, birthplace, ioc',
    order_by="atpname",
   )
   }} -- there are duplicated rows with player and atpname as the difference because of varying letter cases,
      -- used this macro to filter out the duplicates 
),

renamed as (

    select
        id as player_id,
        player as player_name,
        atpname,
        to_date(cast(birthdate as varchar), 'YYYYMMDD') as birthdate,
        weight,
        height,
        turnedpro as year_turned_pro,
        birthplace,
        nullif(trim(coaches),'') as coaches,
        nullif(trim(hand),'') as player_hand,
        nullif(trim(backhand),'') as player_backhand,
        nullif(trim(ioc),'') as country_code 
    from source 

)

select * from renamed