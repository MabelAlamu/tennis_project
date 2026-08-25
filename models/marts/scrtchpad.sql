--select * from {{ ref('int_matches_unpivoted') }} where tourney_name = 'Wimbledon' and round = 'F' order by tourney_date DESC

--select * from {{ ref('int_matches_unpivoted') }} where tourney_name = 'Wimbledon' and round = 'F' order by tourney_date DESC

/*
select 
    tourney_id,
    tourney_name,
    player_name as tourney_winner
from {{ ref('int_matches_unpivoted') }}
where round = 'F'
    and result = 'Win'*/

select *
from {{ ref('dim_tourney') }}
where tourney_name = 'Roland Garros'
order by tourney_date desc, tour