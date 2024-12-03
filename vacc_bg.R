# Top ---------------------------------------------------------------------
# Sample ecoregions to establish background (bg) extent
# Started Nov 20, 2024
library(tidyverse)
library(terra) 
library(predicts)
library(geodata)
library(ENMTools)
library(plotly) # 3D surface Kernel bivariate plots
library(MASS)

# Ecoregion prep ----------------------------------------------------------
# Download NA Ecoregion shapefile from: https://www.epa.gov/eco-research/ecoregions-north-america
# Load shapefile from local files
# Reusing files from Malus SDM

ecoNA <- vect(x = "C:/Users/terre/Documents/Acadia/Malus Project/maps/eco regions/na_cec_eco_l2/", layer = 'NA_CEC_Eco_Level2')
ecoNA <- project(ecoNA, 'WGS84') # project ecoregion vector to same coords ref as basemap

# (Down)Load basemaps -----------------------------------------------------
us_map <- gadm(country = 'USA', level = 1, resolution = 2,
               path = "./maps/base_maps/") #USA basemap w. States

# Load basemaps and wclim data --------------------------------------------
ca_map <- gadm(country = 'CA', level = 1, resolution = 2,
               path = './maps/base_maps/') #Canada basemap w. Provinces

mex_map <-gadm(country = 'MX', level = 1, resolution = 2,
               path = './maps/base_maps/') # Mexico basemap w. States

canUSMex_map <- rbind(us_map, ca_map, mex_map) # Combine Mexico, US and Canada vector map

wclim <- geodata::worldclim_global(var = 'bio', res = 2.5, version = '2.1', path = "./wclim_data/")

# Load occurrence data ----------------------------------------------------
occ_angThin <- readRDS(file = './occ_data/thinned/occ_angThin.Rdata')

# Extract ecogregions for each spp. ---------------------------------------
# V. angustifolium 
eco_ang <- extract(ecoNA, occ_angThin)
eco_ang_code <- eco_ang$NA_L2CODE %>% unique() 
eco_ang_code <- eco_ang_code[!is.na(eco_ang_code) & eco_ang_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_ang <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_ang_code) # subset eco region spat vector by the codes
#plot(ecoNA_ang) # plot the subseted M. coronaria eco regions

saveRDS(ecoNA_ang, file = './bg_data/eco_regions/ecoNA_cor.Rdata') # save Ecoregions for downstream

# Crop wclim layers to ecoregions -----------------------------------------
# V. angustifolium
wclim_ang <- terra::crop(wclim, ecoNA_ang, mask = T)
saveRDS(wclim_ang, file = './wclim_data/wclim_ang.Rdata')

# Sample background points ------------------------------------------------
set.seed(1337) # set a seed to ensure reproducible results

# V. angustifolium
ang_bg_vec <- spatSample(wclim_ang, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
# Plot to take a look
plot(wclim_ang[[1]])
points(ang_bg_vec, cex = 0.01)
saveRDS(ang_bg_vec, file = './bg_data/ang_bg_vec.Rdata')
