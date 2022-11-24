import numpy as np
from DBEngine import db_engine
import pandas as pd
from datetime import datetime
import math

def get_annotated(cursor):
  query = """
    select ST_X(point) as lat, ST_Y(point) as lon, brightness, brightness_t31, radiative_power, dist_road, dist_rail, avg_population, intent 
    from geo_firms where intent is not NULL and source != 6
  """
  cursor.execute(query)
  return np.array(cursor.fetchall())

def get_raw(cursor):
  query = """
    select id, ST_X(point) as lat, ST_Y(point) as lon, brightness, brightness_t31, radiative_power, dist_road, dist_rail, avg_population 
    from geo_firms where intent is NULL
  """
  cursor.execute(query)
  return np.array(cursor.fetchall())

def get_extent(cursor):
  query = """
    with ukraine as (select ST_Union(geom) as geom from ukraine_regions)
    select ST_XMin(geom), ST_XMax(geom), ST_YMin(geom), ST_YMax(geom) from ukraine
  """
  cursor.execute(query)
  return cursor.fetchone()
  
def get_min_max(cursor):
  query = """
    select min(brightness), max(brightness), min(brightness_t31), max(brightness_t31), min(radiative_power), max(radiative_power), min(avg_population), max(avg_population) from geo_firms
  """
  cursor.execute(query)
  return cursor.fetchone()

extent = db_engine.execute(get_extent)
min_max = db_engine.execute(get_min_max)
min_date = datetime.timestamp(datetime(2021, 1, 1, 0, 0, 0))
max_date = datetime.timestamp(datetime(2022, 12, 31, 0, 0, 0))

def normalize(df: pd.DataFrame):
  df['lat'] = (df['lat'] - extent[0]) / (extent[1] - extent[0])
  df['lon'] = (df['lon'] - extent[2]) / (extent[3] - extent[2])
  #df['date'] = df['date'].apply(lambda x: datetime.timestamp(datetime.strptime(str(x), "%Y-%m-%d")))
  #df['date'] = (df['date'] - min_date) / (max_date - min_date)

  df['brightness'] = (df['brightness'] - min_max[0])/(min_max[1] - min_max[0])
  df['brightness_t31'] = (df['brightness_t31'] - min_max[2])/(min_max[3] - min_max[2])
  df['radiative_power'] = (df['radiative_power'] - min_max[4])/(min_max[5] - min_max[4])

  df['dist_road'] = np.where(np.isnan(df['dist_road'].astype('float32')), 0, 1/math.e ** (df['dist_road'] / 100))
  df['dist_rail'] = np.where(np.isnan(df['dist_rail'].astype('float32')), 0, 1/math.e ** (df['dist_rail'] / 100))

  df['avg_population'] = (df['avg_population'] - min_max[6])/(min_max[7] - min_max[6])

  if('intent' in df):
    df['accident'] = np.where(df['intent'] == 1, 1, 0)
    df['attack'] = np.where(df['intent'] == 2, 1, 0)

    df = df.drop(columns=['intent'])

  return df