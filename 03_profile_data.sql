/* ============================================================================
    03_profile_data.sql
    Purpose: Used this as my scratchpad. These were used to investigate raw data 
    and staging models across all three tables.
    I used the results to identify possible data quality issues and
    determine where tests were needed. 
============================================================================*/
use database tennis;
use schema tennis.raw;

select distinct (loser_hand) from wta_matches;
select loser_name from wta_matches where loser_hand = 'U';

select distinct upper(trim(winner_entry)) from wta_matches union all select distinct upper(trim(loser_entry)) from wta_matches;
select distinct(loser_entry) from atp_matches;
select * from atp_matches where score is null; -- returns 19 rows with null. no indication if there was a walkover
select count(*), loser_entry from atp_matches group by loser_entry;
select distinct indoor from atp_matches;
select distinct tourney_level from wta_matches;
select distinct backhand from players;
select * from players where id in (select id from players group by id having count(*) > 1);


-- Trying to identify columns that could be combined to create a unique identifier for atp_matches 
select count(*) from atp_matches where match_num is null; -- thought about creating a match_id with tourney_id and match_num but can't use that seince match_num is has 489 rows with nulls

select tourney_id, tourney_date, winner_id, loser_id, count(*)
from atp_matches
group by 1,2,3,4
having count(*) > 1;


select *from atp_matches
where (tourney_id, tourney_date, winner_id, loser_id) in (
    select tourney_id, tourney_date, winner_id, loser_id
    from atp_matches
    group by 1,2,3,4
    having count(*) > 1
)
order by tourney_id, tourney_date, winner_id, loser_id;

-- Part of the diagnosis of many ids referencing multiple players
select * from players where id = 'BK92';
select * from players where player = 'Alexander Shevchenko';
select * from atp_matches where loser_id = 'V0DO';

-- Identify where one id is reference two different players
-- then return the list of ids and player_names
with player_appearances as(
    select 
      winner_id as player_id,
      winner_name as player_name,
      'winner' as player_type,
    from atp_matches
    union all 
    select 
      loser_id as player_id,
      loser_name as player_name,
      'loser' as player_type,
    from atp_matches
)
select
    player_id,
    listagg(distinct(player_name), '; ') as player_names,
    count(distinct player_name) as name_count
from player_appearances
where player_id is not null --filtering out nulls for now
group by player_id
having count(distinct player_name) > 1;


-- Identifying rows with bad data for first serve won 
with serves as (
    select 
        tourney_id,
        winner_name as player_name
        winner_id as player_id,
        'winner' as player_type,
        w_1stin as first_serves_in,
        w_1stwon as first_serves_won,
        w_svpt as total_service_points
    from atp_matches
    union all
    select 
        tourney_id,
        loser_id as player_id,
        loser_name as player_name,
        'loser' as player_type,
        l_1stin as first_serves_in,
        l_1stwon as first_serves_won,
        l_svpt as total_service_points
    from atp_matches
)
select * from serves 
where first_serves_won > first_serves_in 
   or first_serves_won > total_service_points;


with player_appearances as(
    select 
      id as player_id,
     atpname as player_name,
    from players
)
select
player_name,
listagg(distinct(player_id), '; ') as player_ids,
count(distinct player_id) as id_count
from player_appearances
where player_name is not null --filtering out nulls for now
group by player_name
having count(distinct player_id) > 1;


-- Identifying rows with bad data for first serve won 
with serves as (
    select 
        tourney_id,
        winner_name as player_name,
        winner_id as player_id,
        'winner' as player_type,
    from atp_matches
    union all
    select 
        tourney_id,
        loser_id as player_id,
        loser_name as player_name,
        'loser' as player_type,
    from atp_matches
)
select * from serves 
where player_id = 'T0ET' 
   or player_id = 'T873';

select * from atp_matches where winner_name = 'Harshana Godamanna';


-- Identify where one id is reference two different players
-- then return the list of ids and player_names
with player_appearances as(
    select 
      winner_id as player_id,
      winner_name as player_name,
      'winner' as player_type,
    from atp_matches
    union all 
    select 
      loser_id as player_id,
      loser_name as player_name,
      'loser' as player_type,
    from atp_matches
)
select
    player_name,
    listagg(distinct(player_id), '; ') as player_ids,
    count(distinct player_id) as name_count
from player_appearances
where player_name is not null --filtering out nulls for now
group by player_name
having count(distinct player_id) > 1;


-- Frequency of raw entry values after only trimming and upper-casing.
with entries as (
    select 'ATP' as tour, upper(trim(winner_entry)) as entry_code
    from atp_matches
    union all
    select 'ATP', upper(trim(loser_entry)) from atp_matches
    union all
    select 'WTA', upper(trim(winner_entry)) from wta_matches
    union all
    select 'WTA', upper(trim(loser_entry)) from wta_matches
)

select
    tour,
    entry_code,
    count(*) as occurrence_count
from entries
group by tour, entry_code
order by tour, occurrence_count desc, entry_code;

use database tennis;
use schema dbt_malamu;

with candidate_ids as (
    select * from values
        ('R042'),('R524'),('S0H2'),('BK92'),('L018'),('C044'),
        ('D0DT'),('D214'),('N026'),('N768'),('C0JE'),('C526'),
        ('H0FO'),('H0FW'),('C017'),('C0JD'),('104631'),('G793'),
        ('S0OD'),('S0LN'),('S0PS'),('S343'),('C694'),('C100'),
        ('MP06'),('MD26'),('L150'),('LE17'),('HH06'),('MH30'),
        ('S257'),('S0OS'),('HE10'),('H048'),('CH99'),('C022'),
        ('G0H3'),('G0L2'),('T0ET'),('T873'),('S243'),('SS02')
    as t(player_id)
),
match_counts as (
    select player_id, player_name, count(*) as n_matches
    from (
        select winner_id as player_id, winner_name as player_name from stg_raw__atp_matches
        union all
        select loser_id as player_id, loser_name as player_name from stg_raw__atp_matches
    )
    group by player_id, player_name
)
select
    c.player_id, 
    mc.player_name,
    coalesce(mc.n_matches, 0) as n_matches,
    p.player_id is not null as exists_in_players_table
from candidate_ids c
left join match_counts mc on c.player_id = mc.player_id
left join stg_players_bio p on c.player_id = p.player_id
order by mc.player_name, c.player_id


select * from stg_raw__atp_matches
where loser_id = 'E030';

select count(year_turned_pro) from stg_players_bio where year_turned_pro = 0 ;

select * from stg_raw__atp_matches where winner_name = 'Sumit Nagal' and tourney_match_num = 3 and tourney_name = 'Davis Cup WG1 R1: SUI vs IND';

select distinct winner_entry from stg_raw__atp_matches union all select distinct loser_entry from stg_raw__atp_matches;

select dob, try_to_date(dob::varchar, 'YYYYMMDD') as parsed
from stg_players_bio
where try_to_date(dob::varchar, 'YYYYMMDD') is null
  and dob is not null;

select * from stg_raw__atp_matches where winner_entry = '6/ITF' or loser_entry = '6/ITF'; -- 6 is entry seed and ITF is the entry, Olympics
select * from stg_raw__wta_matches where winner_entry = 'ITF' or loser_entry = 'ITF';
select * from stg_raw__atp_matches where winner_entry = 'UP' or loser_entry = 'UP'; -- One row Danka Kovinic, Olympics 2024
select * from stg_raw__wta_matches where winner_entry = 'IP' or loser_entry = 'IP'; -- < 2012, Olympics Alize Cornet, Elena Naitacha, Anna Tatishvili. IP means ITF place in older olympic draws

select distinct winner_entry, loser_entry from stg_wta where tourney_name = 'Olympics';

select *from stg_raw__atp_matches where tourney_id = '2024-96';

select winner_hand as hand from stg_raw__atp_matches union all select loser_hand as hand from stg_raw__atp_matches;
select player_backhand from stg_players_bio;

