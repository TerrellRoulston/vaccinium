# Top ---------------------------------------------------------------------
# Preparing Bioclimatic predictor rasters for Maxent Predictions
# Terrell Roulston
# Started Dec 12 2024
library(tidyverse) # Grammar and data management
library(tidyterra)
library(terra) # Spatial Data package
library(predicts) # SDM package
library(geodata) # basemaps

# Great Lakes shapefiles for making pretty maps and cropping
great_lakes <- vect('C:/Users/terre/Documents/Acadia/Malus Project/maps/great lakes/combined great lakes/')
# NA_ext <- ext(-180, -30, 5, 90) # Set spatial extent of analysis to NA in Western Hemisphere, approximate north of Panama

# Bring in the extent of the countries included in the analysis. Just using a box
# 
# # Country ISO-2 codes for those that contain species occurrence data for Vaccinium
country_codes <- c("CA","MX","GT","HN","SV","NI","CR","PA")
us_code <- c("US")
base_path <- "./maps/base_maps/" # path to GADM files

# map to download/load GADM level-1 maps for all countries, returns list of SpatVectors
maps_list <- map(country_codes, ~gadm(country = .x, level = 0, resolution = 2, path = base_path))

us_map_0 <- gadm(country = us_code, level = 0, resolution = 2, path = base_path)
us_map_1 <- gadm(country = us_code, level = 1, resolution = 2, path = base_path)
us_map_noHawaii <- us_map_1 %>% tidyterra::filter(NAME_1 != "Hawaii") # I want all the US states except Hawawii
us_map_0 <- terra::intersect(us_map_noHawaii, us_map_0) %>% crop(NA_ext) # drop Hawaii from US country map plus crop Alaska archipelago at 180th parallel.
us_map_0 <- terra::aggregate(us_map_0, fact = 2, disolve = TRUE) # dissolve into one SpatVector rather than different state polygons
# Combine all SpatVectors into one
all_countries_map <- do.call(rbind, c(maps_list, us_map_0)) # combine other countries and US less Hawaii

# Use this all_countries vector as a crop/mask for the wclim data below!


# This is the sub set of worldclim bioclimatic variables that we are using to model
sel <- c('wc2.1_2.5m_bio_1','wc2.1_2.5m_bio_4',
         'wc2.1_2.5m_bio_10','wc2.1_2.5m_bio_11',
         'wc2.1_2.5m_bio_15','wc2.1_2.5m_bio_16')


# Historical climate 1970-2000
wclim <- geodata::worldclim_global(var = 'bio',
                                   res = 2.5, 
                                   version = '2.1', 
                                   path = "./wclim_data/") 

# Now subset the climate layers we want, and mask great lakes and limit to North America north of Panama
wclim_NA <- wclim %>% 
  tidyterra::select(sel) %>% 
  terra::crop(., all_countries_map, mask = TRUE) %>% 
  terra::mask(great_lakes, inverse = TRUE) # mask has a bug where it renames all the masked layers...

# put the names back
names(wclim_NA) <- sel

# SSP (Shared social-economic pathway) 2.45 
# middle of the road projection, high climate adaptation, low climate mitigation

# SSP245 2030
ssp245_2030 <- cmip6_world(model = "CanESM5",
                           ssp = "245",
                           time = "2021-2040",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/")

names(ssp245_2030) <- names(wclim) # rename the layer names the same as names from historical layers

ssp245_2030_NA <- ssp245_2030 %>% 
  tidyterra::select(sel) %>%
  terra::crop(., all_countries_map, mask = TRUE) %>% 
  mask(great_lakes, inverse = T) # cut out the great lakes

# put the names back
names(ssp245_2030_NA) <- sel


# SSP245 2050
ssp245_2050 <- cmip6_world(model = "CanESM5",
                           ssp = "245",
                           time = "2041-2060",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") 

names(ssp245_2050) <- names(wclim) # rename the layer names the same as names from historical layers

ssp245_2050_NA <- ssp245_2050 %>%
  tidyterra::select(sel) %>%
  terra::crop(., all_countries_map, mask = TRUE) %>% 
  mask(great_lakes, inverse = T) # cut out the great lakes

# put the names back
names(ssp245_2050_NA) <- sel


# SSP245 2070
ssp245_2070 <- cmip6_world(model = "CanESM5",
                           ssp = "245",
                           time = "2061-2080",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") 

names(ssp245_2070) <- names(wclim) # rename the layer names the same as names from historical layers

ssp245_2070_NA <- ssp245_2070 %>% 
  tidyterra::select(sel) %>%
  terra::crop(., all_countries_map, mask = TRUE) %>% 
  mask(great_lakes, inverse = T) # cut out the great lakes

# put the names back
names(ssp245_2070_NA) <- sel

# SPP 5.85 
# low regard for environmental sustainability, increased fossil fuel reliance, this is the current tracking projection

# SSP585 2030
ssp585_2030 <- cmip6_world(model = "CanESM5",
                           ssp = "585",
                           time = "2021-2040",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") 

names(ssp585_2030) <- names(wclim) # rename the layer names the same as names from historical layers

ssp585_2030_NA <- ssp585_2030 %>% 
  tidyterra::select(sel) %>%
  terra::crop(., all_countries_map, mask = TRUE) %>% 
  mask(great_lakes, inverse = T) # cut out the great lakes

# put the names back
names(ssp585_2030_NA) <- sel


# SSP585 2050
ssp585_2050 <- cmip6_world(model = "CanESM5",
                           ssp = "585",
                           time = "2041-2060",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") 

names(ssp585_2050) <- names(wclim) # rename the layer names the same as names from historical layers

ssp585_2050_NA <- ssp585_2050 %>%
  tidyterra::select(sel) %>%
  terra::crop(., all_countries_map, mask = TRUE) %>% 
  mask(great_lakes, inverse = T) # cut out the great lakes

# put the names back
names(ssp585_2050_NA) <- sel


# SSP585 2070
ssp585_2070 <- cmip6_world(model = "CanESM5",
                           ssp = "585",
                           time = "2061-2080",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/")

names(ssp585_2070) <- names(wclim) # rename the layer names the same as names from historical layers

ssp585_2070_NA <- ssp585_2070 %>% 
  tidyterra::select(sel) %>%
  terra::crop(., all_countries_map, mask = TRUE) %>% 
  mask(great_lakes, inverse = T) # cut out the great lakes

# put the names back
names(ssp585_2070_NA) <- sel

# Saved formatted Predictor Rasters ---------------------------------------
saveRDS(wclim_NA, './wclim_data/wclim_NA/wclim_NA.rds')
saveRDS(ssp245_2030_NA, './wclim_data/wclim_NA/ssp245_2030_NA.rds')
saveRDS(ssp245_2050_NA, './wclim_data/wclim_NA/ssp245_2050_NA.rds')
saveRDS(ssp245_2070_NA, './wclim_data/wclim_NA/ssp245_2070_NA.rds')
saveRDS(ssp585_2030_NA, './wclim_data/wclim_NA/ssp585_2030_NA.rds')
saveRDS(ssp585_2050_NA, './wclim_data/wclim_NA/ssp585_2050_NA.rds')
saveRDS(ssp585_2070_NA, './wclim_data/wclim_NA/ssp585_2070_NA.rds')


