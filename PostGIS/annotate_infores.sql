begin transaction;
with attacks as (
	select id, title,
	ST_MakeEnvelope(
		ST_X(ST_Project(info_res.point, 5000, radians(90))::geometry), 
		ST_Y(ST_Project(info_res.point, 5000, radians(180))::geometry), 
		ST_X(ST_Project(info_res.point, 5000, radians(-90))::geometry),
		ST_Y(ST_Project(info_res.point, 5000, radians(0))::geometry),
		4326
	) as geom,
	date + interval '1 DAY' as max_date,
	date - interval '1 DAY' as min_date
	from info_res
	where event_group in (3,5,6,7,10,11,12,14,15,18,19,20,21,22,23,24,25,27,28,29,30,31,32)
) 
update geo_firms set
intent = 2, source = 3
from attacks
where geo_firms.date >= min_date
and geo_firms.date <= max_date
and ST_Intersects(geo_firms.point, attacks.geom)