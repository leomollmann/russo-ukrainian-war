with biloberezhia as (
	select * from places where id = 1
)
update geo_firms set intent = 1, source = 2
from biloberezhia 
where ST_Intersects(biloberezhia.geom, geo_firms.point)
and date > '2022-05-05'
and date < '2022-05-15'