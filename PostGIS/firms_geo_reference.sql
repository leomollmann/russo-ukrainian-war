with
envelope as (
	select ST_MakeEnvelope(
		ST_X(ST_Project(firms.point, 1000, radians(90))::geometry), 
		ST_Y(ST_Project(firms.point, 1000, radians(180))::geometry), 
		ST_X(ST_Project(firms.point, 1000, radians(-90))::geometry),
		ST_Y(ST_Project(firms.point, 1000, radians(0))::geometry),
		4326
	) as geom, firms.point as point, date, brightness, brightness_t31, radiative_power
	from firms where id = 3000
),
roads as (
	select ST_Union(ST_Intersection(envelope.geom, ukraine_roads.geom)) as geom
	from ukraine_roads, envelope
	where ST_Intersects(envelope.geom, ukraine_roads.geom)
),
rails as (
	select ST_Union(ST_Intersection(envelope.geom, ukraine_railways.geom)) as geom
	from ukraine_railways, envelope
	where ST_Intersects(envelope.geom, ukraine_railways.geom)
),
settlements as (
	select population, ukraine_settlements.geom as geom, name,
	ST_Distance(ukraine_settlements.geom::geography, envelope.point::geography) as distance
	from ukraine_settlements, envelope
	order by distance asc
	limit 10
),
center as (
	select ARRAY_AGG(population) as population, ARRAY_AGG(distance) as distance from settlements
)
select 
	ST_X(envelope.point) as lon, ST_Y(envelope.point) as lat,
	date, brightness, brightness_t31, radiative_power,
	ST_Distance(roads.geom::geography, envelope.point::geography) as dist_road,
	ST_Distance(rails.geom::geography, envelope.point::geography) as dist_rail,
	population, distance
from roads, rails, envelope, center