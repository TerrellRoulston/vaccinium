# Quick example for Henry on how to download climate data from site coordinates

library(terra)
library(geodata)

# Some df of site names and column with latitude and longitude
sites_df <- data.frame(
  site = c(
    "Vancouver_BC",
    "Calgary_AB",
    "Winnipeg_MB",
    "Toronto_ON",
    "Halifax_NS",
    "Anchorage_AK",
    "Seattle_WA",
    "Denver_CO",
    "Austin_TX",
    "Mexico_City_MX"
  ),
  lat = c(
    49.2827,
    51.0447,
    49.8951,
    43.6532,
    44.6488,
    61.2181,
    47.6062,
    39.7392,
    30.2672,
    19.4326
  ),
  lon = c(
    -123.1207,
    -114.0719,
    -97.1384,
    -79.3832,
    -63.5752,
    -149.9003,
    -122.3321,
    -104.9903,
    -97.7431,
    -99.1332
  )
)

# Using terra create a SpatVector (points) from df - it keeps the variables that are found in the dataframe as information about each point
site_vect <- terra::vect(
  sites_df,
  geom = c("lon", "lat"),
  crs = "EPSG:4326"  # WGS84 - this is the refernence system you are using
)

# Download historical WorldClim data using geodata
wclim <- geodata::worldclim_global(var = 'bio', # 19 bioclimatic variables
                                   res = 2.5, # this is the higest spatial resolution available
                                   version = '2.1', 
                                   path = "./wclim_data/") # change where you want to save it to load from disk next time

# Extract climate data from wclim raster using spatvector of points
# x = Wclim raster, y = site vector
# returns dataframe
sites_wclim <- terra::extract(wclim, site_vect)

# Then combine back with origional df as long as row order is still the same
sites_df_wclim <- bind_cols(
  sites_df,
  sites_wclim %>% select(-ID) # drop the ID column added by extract
)

