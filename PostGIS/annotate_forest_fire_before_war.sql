with regions as (
	select ST_Union(geom) as geom
	from ukraine_regions 
	where ukraine_regions.hasc_1 != 'UA.DT' 
	and ukraine_regions.hasc_1 != 'UA.LH'
),
nature as (
	select ukraine_terrain.geom as geom from ukraine_terrain, regions
	where ST_Intersects(ukraine_terrain.geom, regions.geom)
	and ukraine_terrain.fclass in ('forest', 'meadow', 'nature_reserve')
)
update geo_firms set
intent = 1, source = 1
from nature
where date < '2022-02-24'
and ST_Intersects(
	ST_MakeEnvelope(
		ST_X(ST_Project(geo_firms.point, 1000, radians(90))::geometry), 
		ST_Y(ST_Project(geo_firms.point, 1000, radians(180))::geometry), 
		ST_X(ST_Project(geo_firms.point, 1000, radians(-90))::geometry),
		ST_Y(ST_Project(geo_firms.point, 1000, radians(0))::geometry),
		4326
	), nature.geom)

