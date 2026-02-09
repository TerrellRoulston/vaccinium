# Top ---------------------------------------------------------------------
# MaxEnt Species Distribution Modeling (SDM) for Vaccinium CWR
# Script for HPC anaylsis
# Terrell Roulston
# Started Dec 12, 2024
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
ang_bg_vec <- readRDS(file = '/project/6074193/mig_lab/vac_sdm/ang_bg_vec.rds')
# Load occurrence data 
occ_angThin <- readRDS(file = '/project/6074193/mig_lab/vac_sdm/occ_angThin.rds')
# Load cliped wclim data to ecoregions
wclim_ang <- readRDS(file = '/project/6074193/mig_lab/vac_sdm/wclim_ang.rds')

# Spatial partitioning prep -----------------------------------------------
# V. angustifolium
occ_ang_coords <- as.data.frame(geom(occ_angThin)[,3:4]) # extract longitude, lattitude from occurence points
bg_ang_coords <- as.data.frame(geom(ang_bg_vec)[,3:4]) # extract longitude, lattitude from background points

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
                          numCores = cn, # leave one core available for other apps
                          parallelType = "doSNOW", # use doParrallel on Windows - socket cluster  
                          algorithm = 'maxent.jar')

saveRDS(ang_maxent, file = '/project/6074193/mig_lab/vac_sdm/sdm_output/ang_maxent.rds') # save

