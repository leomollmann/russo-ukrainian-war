with war_accidents as (select count(1) from geo_firms where (accident > 0 or intent = 1) and date >= '2022-02-24'),
war_attacks as (select count(1) from geo_firms where (attack > 0  or intent = 2) and date >= '2022-02-24'),
pre_accidents as (select count(1) from geo_firms where (accident > 0 or intent = 1) and date < '2022-02-24'),
pre_attacks as (select count(1) from geo_firms where (attack > 0 or intent = 2) and date < '2022-02-24')
select * from pre_accidents, pre_attacks, war_accidents, war_attacks