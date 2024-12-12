# Top ---------------------------------------------------------------------
# MaxEnt Species Distribution Modeling (SDM) for Vaccinium CWR 
# Terrell Roulston
# Started Nov 20, 2024

library(tidyverse) # Grammar and data management
library(terra) # Spatial Data package
library(predicts) # SDM package
library(geodata) # basemaps
library(rJava) # MaxEnt models are dependant on JDK
library(ENMeval) # Another modeling package, useful for data partitioning (Checkerboarding)
library(ecospat) # Useful spatial ecology tools
library(parallel) # speed up computation by running in parallel
library(doParallel) # added functionality to parallel

# Load background, occurrence and map data --------------------------------
# Load bg SpatVectors
ang_bg_vec <- readRDS(file = './bg_data/ang_bg_vec.Rdata')

# Load occurrence data 
occ_angThin <- readRDS(file = './occ_data/thinned/occ_angThin.Rdata')
occ_angPankajThin <- readRDS(file = './occ_data/thinned/occ_angPankajThin.Rdata')

# Great Lakes shapefiles for making pretty maps and cropping
great_lakes <- vect('C:/Users/terre/Documents/Acadia/Malus Project/maps/great lakes/combined great lakes/')
NA_ext <- ext(-180, -30, 18, 85) # Set spatial extent of analyis to NA in Western Hemisphere

# Historical climate 1970-2000
wclim <- geodata::worldclim_global(var = 'bio',
                                   res = 2.5, 
                                   version = '2.1', 
                                   path = "./wclim_data/") %>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

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
                           path = "../wclim_data/")%>% 
  crop(NA_ext) %>% #crop raster to NA 
  mask(great_lakes, inverse = T) # cut out the great lakes

# Load cliped wclim data to ecoregions
wclim_ang <- readRDS(file = './wclim_data/wclim_ang.Rdata') 

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

# Spatial partitioning prep -----------------------------------------------
# V. angustifolium
occ_ang_coords <- as.data.frame(geom(occ_angThin)[,3:4]) # extract longitude, lattitude from occurence points
occ_angPankaj_coords <- as.data.frame(geom(occ_angPankajThin)[,3:4]) # extract longitude, lattitude from occurence points
bg_ang_coords <- as.data.frame(geom(ang_bg_vec)[,3:4]) # extract longitude, lattitude from background points





# V. angustifolium Maxent Species Distribution Model ----------------------
# Run prediction in a parallel using 'socket' clusters to help speed up computation
# <ENMeval> implements parallel functions natively
# But load <parallel> library for additional functions like <decectCores()>
cn <- detectCores(logical = F) # logical = F, is number of physical RAM cores in your computer
set.seed(1337)

# current version of maxent.jar =  v3.4.4

ang_maxent <- ENMevaluate(occ_ang_coords, # occurrence records
                          envs = wclim_ang, # environment from background training area
                          n.bg = 10000, # 10000 bg points
                          tune.args =
                            list(rm = seq(0.5, 8, 0.5),
                                 fc = c("L", "LQ", "H",
                                        "LQH", "LQHP")),
                          partition.settings =
                            list(aggregation.factor = c(9, 9), gridSampleN = 10000), # 9,9 agg
                          partitions = 'checkerboard2',
                          parallel = TRUE,
                          numCores = cn - 1, # leave one core available for other apps
                          parallelType = "doParallel", # use doParrallel on Windows - socket cluster  
                          algorithm = 'maxent.jar')

# Model with Pankaj's points added
angPankaj_maxent <- ENMevaluate(occ_angPankaj_coords, # occurrence records
                          envs = wclim_ang, # environment from background training area
                          n.bg = 10000, # 10000 bg points
                          tune.args =
                            list(rm = seq(0.5, 8, 0.5),
                                 fc = c("L", "LQ", "H",
                                        "LQH", "LQHP")),
                          partition.settings =
                            list(aggregation.factor = c(9, 9), gridSampleN = 10000), # 9,9 agg
                          partitions = 'checkerboard2',
                          parallel = TRUE,
                          numCores = cn - 1, # leave one core available for other apps
                          parallelType = "doParallel", # use doParrallel on Windows - socket cluster  
                          algorithm = 'maxent.jar')




# Save the MaxEnt model so you do not have to waste time re-running the model
saveRDS(ang_maxent, file = './sdm_output/ang_maxent.Rdata') # save
saveRDS(angPankaj_maxent, file = './sdm_output/angPankaj_maxent.Rdata') # save

ang_maxent <- readRDS(file = './sdm_output/ang_maxent.Rdata')

# V. angustifolium Model Selection ----------------------------------------
# Model selection and variable importance
best_ang_maxent <- subset(ang_maxent@results, delta.AICc == 0) # selects the best performing model based on delta AICc - returns data frame object
mod.best_ang_maxent <- eval.models(ang_maxent)[[best_ang_maxent$tune.args]] # extracts the best model - returns MaxEnt object
eval.variable.importance(ang_maxent) # return varaible importance
# Permutational importance > 10%
# Bio 1 - Annual Mean Temperature
# Bio 10 -  Mean Temperature of Warmest Quarter
# Bio 12 - Annual Precipitation
# Bio 5 - Max Temperature of Warmest Month

# Model selection and variable importance
best_angPankaj_maxent <- subset(angPankaj_maxent@results, delta.AICc == 0) # selects the best performing model based on delta AICc - returns data frame object
mod.best_angPankaj_maxent <- eval.models(angPankaj_maxent)[[best_angPankaj_maxent$tune.args]] # extracts the best model - returns MaxEnt object
eval.variable.importance(angPankaj_maxent) # return varaible importance
# Permutational importance > 10%
# Bio 1 - Annual Mean Temperature
# Bio 10 -  Mean Temperature of Warmest Quarter
# Bio 12 - Annual Precipitation
# Bio 5 - Max Temperature of Warmest Month



# V. angustifolium Predictions --------------------------------------------
# Habitat Suitability Predictions
cn <- detectCores(logical = F) 
ang_pred_hist <- terra::predict(wclim, mod.best_ang_maxent, cores = cn - 1, na.rm = T)
ang_pred_ssp245_30 <- terra::predict(ssp245_2030, mod.best_ang_maxent, cores = cn - 1, na.rm = T)
ang_pred_ssp245_50 <- terra::predict(ssp245_2050, mod.best_ang_maxent, cores = cn - 1, na.rm = T)
ang_pred_ssp245_70 <- terra::predict(ssp245_2070, mod.best_ang_maxent, cores = cn - 1, na.rm = T)
ang_pred_ssp585_30 <- terra::predict(ssp585_2030, mod.best_ang_maxent, cores = cn - 1, na.rm = T)
ang_pred_ssp585_50 <- terra::predict(ssp585_2050, mod.best_ang_maxent, cores = cn - 1, na.rm = T)
ang_pred_ssp585_70 <- terra::predict(ssp585_2070, mod.best_ang_maxent, cores = cn - 1, na.rm = T)

# Save predictions
saveRDS(ang_pred_hist, file = './sdm_output/ang_pred_hist.Rdata')
saveRDS(ang_pred_ssp245_30, file = './sdm_output/ang_pred_ssp245_30.Rdata')
saveRDS(ang_pred_ssp245_50, file = './sdm_output/ang_pred_ssp245_50.Rdata')
saveRDS(ang_pred_ssp245_70, file = './sdm_output/ang_pred_ssp245_70.Rdata')
saveRDS(ang_pred_ssp585_30, file = './sdm_output/ang_pred_ssp585_30.Rdata')
saveRDS(ang_pred_ssp585_50, file = './sdm_output/ang_pred_ssp585_50.Rdata')
saveRDS(ang_pred_ssp585_70, file = './sdm_output/ang_pred_ssp585_70.Rdata')
# Load predictions
ang_pred_hist <- readRDS(file = './sdm_output/ang_pred_hist.Rdata')
ang_pred_ssp245_30 <- readRDS(file = './sdm_output/ang_pred_ssp245_30.Rdata')
ang_pred_ssp245_50 <- readRDS(file = './sdm_output/ang_pred_ssp245_50.Rdata')
ang_pred_ssp245_70 <- readRDS(file = './sdm_output/ang_pred_ssp245_70.Rdata')
ang_pred_ssp585_30 <- readRDS(file = './sdm_output/ang_pred_ssp585_30.Rdata')
ang_pred_ssp585_50 <- readRDS(file = './sdm_output/ang_pred_ssp585_50.Rdata')
ang_pred_ssp585_70 <- readRDS(file = './sdm_output/ang_pred_ssp585_70.Rdata')

# With Pankaj's observations
cn <- detectCores(logical = F) 
angPankaj_pred_hist <- terra::predict(wclim, mod.best_angPankaj_maxent, cores = cn - 1, na.rm = T)
angPankaj_pred_ssp245_30 <- terra::predict(ssp245_2030, mod.best_angPankaj_maxent, cores = cn - 1, na.rm = T)
angPankaj_pred_ssp245_50 <- terra::predict(ssp245_2050, mod.best_angPankaj_maxent, cores = cn - 1, na.rm = T)
angPankaj_pred_ssp245_70 <- terra::predict(ssp245_2070, mod.best_angPankaj_maxent, cores = cn - 1, na.rm = T)
angPankaj_pred_ssp585_30 <- terra::predict(ssp585_2030, mod.best_angPankaj_maxent, cores = cn - 1, na.rm = T)
angPankaj_pred_ssp585_50 <- terra::predict(ssp585_2050, mod.best_angPankaj_maxent, cores = cn - 1, na.rm = T)
angPankaj_pred_ssp585_70 <- terra::predict(ssp585_2070, mod.best_angPankaj_maxent, cores = cn - 1, na.rm = T)

# Save predictions
saveRDS(angPankaj_pred_hist, file = './sdm_output/angPankaj_pred_hist.Rdata')
saveRDS(angPankaj_pred_ssp245_30, file = './sdm_output/angPankaj_pred_ssp245_30.Rdata')
saveRDS(angPankaj_pred_ssp245_50, file = './sdm_output/angPankaj_pred_ssp245_50.Rdata')
saveRDS(angPankaj_pred_ssp245_70, file = './sdm_output/angPankaj_pred_ssp245_70.Rdata')
saveRDS(angPankaj_pred_ssp585_30, file = './sdm_output/angPankaj_pred_ssp585_30.Rdata')
saveRDS(angPankaj_pred_ssp585_50, file = './sdm_output/angPankaj_pred_ssp585_50.Rdata')
saveRDS(angPankaj_pred_ssp585_70, file = './sdm_output/angPankaj_pred_ssp585_70.Rdata')
# Load predictions
angPankaj_pred_hist <- readRDS(file = './sdm_output/angPankaj_pred_hist.Rdata')
angPankaj_pred_ssp245_30 <- readRDS(file = './sdm_output/angPankaj_pred_ssp245_30.Rdata')
angPankaj_pred_ssp245_50 <- readRDS(file = './sdm_output/angPankaj_pred_ssp245_50.Rdata')
angPankaj_pred_ssp245_70 <- readRDS(file = './sdm_output/angPankaj_pred_ssp245_70.Rdata')
angPankaj_pred_ssp585_30 <- readRDS(file = './sdm_output/angPankaj_pred_ssp585_30.Rdata')
angPankaj_pred_ssp585_50 <- readRDS(file = './sdm_output/angPankaj_pred_ssp585_50.Rdata')
angPankaj_pred_ssp585_70 <- readRDS(file = './sdm_output/angPankaj_pred_ssp585_70.Rdata')

# V. angustifolium Evaluation ---------------------------------------------
# Evaluate predictions using Boyce Index
# the number of true presences should decline with suitability groups 100-91, 90-81, etc. 
# First extract suitability values for the background and presence points, make sure to omit NA values
angPred_bg_val <- terra::extract(ang_pred_hist, bg_ang_coords)$lyr1 %>% 
  na.omit()

angPred_val_na <- terra::extract(ang_pred_hist, occ_ang_coords)$lyr1 %>% 
  na.omit()

# Evaluate predictions using Boyce Index
ecospat.boyce(fit = angPred_bg_val, # vector of predicted habitat suitability of bg points
              obs = angPred_val_na, # vector of 
              nclass = 0, 
              PEplot = TRUE,
              method = 'spearman')

# V. angustifolium Thresholds ---------------------------------------------
# Gradients can be hard to understand at a glance, so lets create categorical bins of high suitability, moderate suitability, low suitability using thresholds
angPred_val <- terra::extract(ang_pred_hist, occ_ang_coords)$lyr1
angPred_threshold_1 <- quantile(angPred_val, 0.01, na.rm = T) # Low suitability
angPred_threshold_10 <- quantile(angPred_val, 0.1, na.rm = T) # Moderate suitability
angPred_threshold_50 <- quantile(angPred_val, 0.5, na.rm = T) # High suitability
# Save
saveRDS(angPred_threshold_1, file = './sdm_output/thresholds/angPred_threshold_1.Rdata')
saveRDS(angPred_threshold_10, file = './sdm_output/thresholds/angPred_threshold_10.Rdata')
saveRDS(angPred_threshold_50, file = './sdm_output/thresholds/angPred_threshold_50.Rdata')
# Load
angPred_threshold_1 <- readRDS(file = './sdm_output/thresholds/angPred_threshold_1.Rdata')
angPred_threshold_10 <- readRDS(file = './sdm_output/thresholds/angPred_threshold_10.Rdata')
angPred_threshold_50 <- readRDS(file = './sdm_output/thresholds/angPred_threshold_50.Rdata')

#Pankaj models
angPankajPred_val <- terra::extract(angPankaj_pred_hist, occ_angPankaj_coords)$lyr1
angPankajPred_threshold_1 <- quantile(angPankajPred_val, 0.01, na.rm = T) # Low suitability
angPankajPred_threshold_10 <- quantile(angPankajPred_val, 0.1, na.rm = T) # Moderate suitability
angPankajPred_threshold_50 <- quantile(angPankajPred_val, 0.5, na.rm = T) # High suitability
# Save
saveRDS(angPankajPred_threshold_1, file = './sdm_output/thresholds/angPankajPred_threshold_1.Rdata')
saveRDS(angPankajPred_threshold_10, file = './sdm_output/thresholds/angPankajPred_threshold_10.Rdata')
saveRDS(angPankajPred_threshold_50, file = './sdm_output/thresholds/angPankajPred_threshold_50.Rdata')
# Load
angPankajPred_threshold_1 <- readRDS(file = './sdm_output/thresholds/angPankajPred_threshold_1.Rdata')
angPankajPred_threshold_10 <- readRDS(file = './sdm_output/thresholds/angPankajPred_threshold_10.Rdata')
angPankajPred_threshold_50 <- readRDS(file = './sdm_output/thresholds/angPankajPred_threshold_50.Rdata')


