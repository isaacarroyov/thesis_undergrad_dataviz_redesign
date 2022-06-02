import numpy as np 
import pandas as pd 
import geopandas

df = geopandas.read_file("./../data/datos_firms_2001_2020.geojson")
df = df.query("confidence > 90")
df["acq_date"] = pd.to_datetime(df["acq_date"])
df = df.set_index("acq_date")

df_ts_daily = df.resample('d').count()
df_ts_daily["day_of_the_year"] = df_ts_daily.index.day_of_year
df_ts_daily["year"] = df_ts_daily.index.year
df_ts_daily = df_ts_daily[['type','day_of_the_year', 'year']]
df_ts_daily = df_ts_daily.rename(columns={'type':'count'})
df_ts_daily.reset_index(inplace=True)

df_ts_weekly = df.resample("W").count()
df_ts_weekly["week_of_the_year"] = df_ts_weekly.index.weekofyear
df_ts_weekly["year"] = df_ts_weekly.index.year
df_ts_weekly = df_ts_weekly[['type','week_of_the_year', 'year']]
df_ts_weekly = df_ts_weekly.rename(columns={'type':'count'})
df_ts_weekly.reset_index(inplace=True)

df_ts_daily.to_csv("./../data/clean-data_02_time-series-heatpoints_daily.csv", index=False)
print("Done 1/2")
df_ts_weekly.to_csv("./../data/clean-data_02_time-series-heatpoints_weekly.csv", index=False)
print("Done 2/2")
