with sviatohirsk as (
	select * from places where id = 4
)
update geo_firms set event = 4
from sviatohirsk
where ST_Intersects(sviatohirsk.geom, geo_firms.point)