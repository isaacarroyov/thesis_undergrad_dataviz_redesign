import numpy as np 
import pandas as pd 
import geopandas
from sklearn.cluster import KMeans
from sklearn.preprocessing import MinMaxScaler

def mod_clave_municipio(clave):
    if len(str(clave)) == 3:
        return str(clave)
    elif len(str(clave)) == 2:
        return '0'+str(clave)
    else:
        return '00'+str(clave)

df = geopandas.read_file("./../data/datos_conafor_2017.geojson")
df_geom_municipios = geopandas.read_file("./../data/31mun.shp")

df_freq = df.groupby("Clave municipio").count()[['Total']].rename(columns = {"Total":"freq"}).reset_index()
df_affected_area = df.groupby("Clave municipio").sum()[['Total']].rename(columns = {"Total":"affected_area"}).reset_index()
df_municipios = pd.merge(left=df_freq, right=df_affected_area, on="Clave municipio")

X = MinMaxScaler().fit_transform(df_municipios[["freq","affected_area"]])
df_municipios[["scaled_freq","scaled_affected_area"]] = X

kmeans = KMeans(n_clusters=3, init="k-means++", random_state=11)
kmeans.fit(df_municipios[["scaled_freq","scaled_affected_area"]])
arr_labels = kmeans.predict(df_municipios[["scaled_freq","scaled_affected_area"]])
df_municipios['cluster'] = arr_labels + 1


df_municipios["code_mun"] = df_municipios["Clave municipio"].apply(mod_clave_municipio)
df_municipios.drop(columns="Clave municipio", inplace=True)
df_municipios = pd.merge(left=df_municipios, right=df_geom_municipios, left_on="code_mun", right_on="CVE_MUN", how="outer")

df_municipios = df_municipios[['freq', 'affected_area', 'cluster', 'CVE_MUN', 'NOMGEO','geometry']]
df_municipios = geopandas.GeoDataFrame(df_municipios)

df_municipios[['freq','affected_area','cluster']] = df_municipios[['freq','affected_area','cluster']].fillna(0)
df_municipios["cluster"] = df_municipios["cluster"].astype(int)
df_municipios = df_municipios.rename(columns={"CVE_MUN":"code","NOMGEO":"name"})

df_geom_municipios.to_file("./../data/clean-data_01_municipalities-info.geojson", driver='GeoJSON')