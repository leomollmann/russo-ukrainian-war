with sievierodonetsk as (
	select * from places where id = 3
)
update geo_firms set intent = 2, event = 3
from sievierodonetsk 
where ST_Intersects(sievierodonetsk.geom, geo_firms.point)
and date >= '2022-05-06'
and date <= '2022-07-03';

update geo_firms set source = 5
where source is NULl and event = 3
