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
NA_ext <- NA_ext <- ext(-180, -30, 14, 85) # Set spatial extent of analyis to NA in Western Hemisphere


sel <- c('wc2.1_2.5m_bio_1','wc2.1_2.5m_bio_4',
         'wc2.1_2.5m_bio_10','wc2.1_2.5m_bio_11',
         'wc2.1_2.5m_bio_15','wc2.1_2.5m_bio_16')


# Historical climate 1970-2000
wclim <- geodata::worldclim_global(var = 'bio',
                                   res = 2.5, 
                                   version = '2.1', 
                                   path = "./wclim_data/") %>% 
  crop(NA_ext) %>% 
  tidyterra::select(sel) %>% 
  mask(great_lakes, inverse = TRUE)

# put the names back
names(wclim) <- sel

# SSP (Shared social-economic pathway) 2.45 
# middle of the road projection, high climate adaptation, low climate mitigation
ssp245_2030 <- cmip6_world(model = "CanESM5",
                           ssp = "245",
                           time = "2021-2040",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") %>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

ssp245_2050 <- cmip6_world(model = "CanESM5",
                           ssp = "245",
                           time = "2041-2060",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") %>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

ssp245_2070 <- cmip6_world(model = "CanESM5",
                           ssp = "245",
                           time = "2061-2080",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") %>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

# SPP 5.85 
# low regard for environmental sustainability, increased fossil fuel reliance, this is the current tracking projection
ssp585_2030 <- cmip6_world(model = "CanESM5",
                           ssp = "585",
                           time = "2021-2040",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") %>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

ssp585_2050 <- cmip6_world(model = "CanESM5",
                           ssp = "585",
                           time = "2041-2060",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/") %>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

ssp585_2070 <- cmip6_world(model = "CanESM5",
                           ssp = "585",
                           time = "2061-2080",
                           var = "bioc",
                           res = 2.5,
                           path = "./wclim_data/")%>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

# Load cliped wclim data to ecoregions
wclim_ang <- readRDS(file = './wclim_data/clipped_wclim/wclim_ang.rds') 

climate_predictors <- names(wclim_ang) # extract climate predictor names, to rename layers in the rasters below
# This is important to do for making predictions once the SDMs have been made on future climate data
# Note that the names of the layers still correspond to the same environmental variables

# Future SSPs
# Do not need to create RasterStacks
# SSP 245
names(ssp245_2030) <- climate_predictors #rename raster layers for downsteam analysis
names(ssp245_2050) <- climate_predictors 
names(ssp245_2070) <- climate_predictors 

# SSP 585
names(ssp585_2030) <- climate_predictors #rename raster layers for downsteam analysis
names(ssp585_2050) <- climate_predictors 
names(ssp585_2070) <- climate_predictors

# Saved formatted Predictor Rasters ---------------------------------------
saveRDS(wclim, './wclim_data/wclim_NA/wclim.rds')
saveRDS(ssp245_2030, './wclim_data/wclim_NA/ssp245_2030.rds')
saveRDS(ssp245_2050, './wclim_data/wclim_NA/ssp245_2050.rds')
saveRDS(ssp245_2070, './wclim_data/wclim_NA/ssp245_2070.rds')
saveRDS(ssp585_2030, './wclim_data/wclim_NA/ssp585_2030.rds')
saveRDS(ssp585_2050, './wclim_data/wclim_NA/ssp585_2050.rds')
saveRDS(ssp585_2070, './wclim_data/wclim_NA/ssp585_2070.rds')


