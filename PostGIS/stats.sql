select count(1) as points, avg(brightness) as brightness, avg(brightness_t31) as brightness_t31, avg(radiative_power) as radiative_power, avg(dist_road) as dist_road, avg(dist_rail) as dist_rail, avg(avg_population) as avg_population from geo_firms where intent = 1