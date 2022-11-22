with mariupol as (
	select * from places where id = 2
)
update geo_firms set intent = 2, event = 2
from mariupol 
where ST_Intersects(mariupol.geom, geo_firms.point)
and date >= '2022-02-24'
and date <= '2022-05-20';

update geo_firms set source = 4
where source is NULl and event = 2
