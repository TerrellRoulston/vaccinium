# Top ---------------------------------------------------------------------
# MaxEnt Species Distribution Modeling (SDM) for Vaccinium CWR
# Script for HPC anaylsis for V. cormybosum complex species
# Terrell Roulston
# Started Feb 10th, 2026

# Load libs ---------------------------------------------------------------
library(tidyverse) # Grammar and data management
library(terra) # Spatial Data package
library(predicts) # SDM package
library(geodata) # basemaps
library(rJava) # MaxEnt models are dependant on JDK
library(ENMeval) # Another modeling package, useful for data partitioning (Checkerboarding)
library(ecospat) # Useful spatial ecology tools
library(parallel) # speed up computation by running in parallel
library(doParallel) # added functionality to parallel
library(foreach) 

Start <- Sys.time() # Store start time
# Cores and Arguments -----------------------------------------------------
# Use the environment variable SLURM_CPUS_PER_TASK to set the number of cores.
cat("Retrieve number of cores\n")
ncores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 1))  # Default to 1 core if ncores isnt specified
cat("Number of cores available:", ncores, "\n")


# Script will only run for the species defined in the job array
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Error: No species specified.")
species <- args[1]
cat("Processing species:", species, "\n")

# Species List ------------------------------------------------------------
cat("Load data for each species\n")
# Corymbosum complex + relatives (subspecies workflow)
species_list_corym_sub <- list(
  "ash" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_ash_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_ash_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_ash_thin_bgmask.tif"
  ),
  "cae" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_cae_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_cae_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_cae_thin_bgmask.tif"
  ),
  "cor2" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_cor2_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_cor2_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_cor2_thin_bgmask.tif"
  ),
  "cot" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_cot_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_cot_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_cot_thin_bgmask.tif"
  ),
  "ell" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_ell_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_ell_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_ell_thin_bgmask.tif"
  ),
  "for" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_for_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_for_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_for_thin_bgmask.tif"
  ),
  "fus" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_fus_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_fus_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_fus_thin_bgmask.tif"
  ),
  "sim" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_sim_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_sim_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_sim_thin_bgmask.tif"
  ),
  "vir" = list(
    bg_file  = "/project/6074193/mig_lab/vac_sdm/bg_data/corym_sub/wclim_occ_vir_thin_bgpts.rds",
    occ_file = "/project/6074193/mig_lab/vac_sdm/occ_data/corym_sub/occ_vir_thin.rds",
    env_file = "/project/6074193/mig_lab/vac_sdm/wclim_data/corym_sub/wclim_occ_vir_thin_bgmask.tif"
  )
)

if (!species %in% names(species_list_corym_sub)) {
  stop("Error: Species not found in the species list.")
}


# Load data specific to species -------------------------------------------
# Load data for the specified species
sp_data <- species_list_corym_sub[[species]] # Return What species is being ran in the array
bg_vec <- readRDS(sp_data$bg_file) # Read bg data specific to that sp
occ <- readRDS(sp_data$occ_file) # Read occ data specific to that sp
envs <- terra::rast(sp_data$env_file) # Read cropped Wclim data for that sp
occ_coords <- as.data.frame(geom(occ)[,3:4]) # extract lon/lat from occurrence points
bg_coords <- as.data.frame(geom(bg_vec)[,3:4]) # extract lon/lat from background points

# Parallel Backend --------------------------------------------------------
registerDoParallel(cores = ncores) # Shows the number of Parallel Workers to be used
print(ncores) # this how many cores are available, and how many you have requested.
getDoParWorkers() # you can compare with the number of actual workers


# MaxEnt Model ------------------------------------------------------------
set.seed(1337)

cat("Running ENMevaluate\n")
tryCatch({ # tryCatch to capture errors and log them without terminating task
  maxent_model <- ENMevaluate( 
    occs = occ_coords, # geom of occ data
    envs = envs, # environment from background training area
    bg = bg_coords,
    # n.bg = 30000, # number of bg points sampled from env if bg = NULL
    tune.args = list(rm = seq(0.5, 8, 0.5), fc = c("L", "LQ", "H", "LQH", "LQHP")),
    partition.settings = list(aggregation.factor = c(9, 9), gridSampleN = 30000), # 9,9 agg
    partitions = 'checkerboard', # 4-fold checkboard partition
    parallel = TRUE, # run in parallel
    numCores = ncores, # utilize all available cores
    algorithm = 'maxent.jar'
  )
}, error = function(e) {
  cat("Error in ENMevaluate for species", species, ":", e$message, "\n")
})

cat("Finnished ")
# Save Maxent Outputs -----------------------------------------------------
# Save outputs
output_dir <- file.path("/project/6074193/mig_lab/vac_sdm/sdm_output/corym_sub", species)
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE) # check if dir exists, if not create (avoids errors when outputting)
if (exists("maxent_model")) {
  saveRDS(maxent_model, file = file.path(output_dir, paste0(species, "_maxent_model.rds"))) #Save the MaxEnt model object as an RDS file in the species-specific output directory
  write.csv(subset(maxent_model@results, delta.AICc == 0), 
            file = file.path(output_dir, paste0(species, "_evaluation.csv")))
}

# Select the best performing Maxent model for the predictions below
best_model <- subset(maxent_model@results, delta.AICc == 0) # selects the best performing model based on delta AICc - returns data frame object
mod.best_maxent <- eval.models(maxent_model)[[best_model$tune.args]]


# Load climate data for predictions ---------------------------------------
wclim <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_CA_US_MX.rds')
ssp245_2030 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp245_2030_CA_US_MX.rds')
ssp245_2050 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp245_2050_CA_US_MX.rds')
ssp245_2070 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp245_2070_CA_US_MX.rds')
ssp585_2030 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp585_2030_CA_US_MX.rds')
ssp585_2050 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp585_2050_CA_US_MX.rds')
ssp585_2070 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp585_2070_CA_US_MX.rds')
cat("Loaded bioclimatic predictor rasters")

# Habitat Suitability Predictions -----------------------------------------
cat("Historical suitability prediction\n")
pred_hist <- terra::predict(wclim, mod.best_maxent, cores = ncores, na.rm = T)
cat("ssp245_30 suitability prediction\n")
pred_ssp245_30 <- terra::predict(ssp245_2030, mod.best_maxent, cores = ncores, na.rm = T)
cat("ssp245_50 suitability prediction\n")
pred_ssp245_50 <- terra::predict(ssp245_2050, mod.best_maxent, cores = ncores, na.rm = T)
cat("ssp245_70 suitability prediction\n")
pred_ssp245_70 <- terra::predict(ssp245_2070, mod.best_maxent, cores = ncores, na.rm = T)
cat("ssp585_30 suitability prediction\n")
pred_ssp585_30 <- terra::predict(ssp585_2030, mod.best_maxent, cores = ncores, na.rm = T)
cat("ssp585_50 suitability prediction\n")
pred_ssp585_50 <- terra::predict(ssp585_2050, mod.best_maxent, cores = ncores, na.rm = T)
cat("ssp585_70 suitability prediction\n")
pred_ssp585_70 <- terra::predict(ssp585_2070, mod.best_maxent, cores = ncores, na.rm = T)
cat("All predictions completed\n")


# Save Predictions --------------------------------------------------------
cat("Save suitability predictions\n")
saveRDS(pred_hist, file = file.path(output_dir, paste0(species, "_pred_hist.rds")))
saveRDS(pred_ssp245_30, file = file.path(output_dir, paste0(species, "_pred_ssp245_30.rds")))
saveRDS(pred_ssp245_50, file = file.path(output_dir, paste0(species, "_pred_ssp245_50.rds")))
saveRDS(pred_ssp245_70, file = file.path(output_dir, paste0(species, "_pred_ssp245_70.rds")))
saveRDS(pred_ssp585_30, file = file.path(output_dir, paste0(species, "_pred_ssp585_30.rds")))
saveRDS(pred_ssp585_50, file = file.path(output_dir, paste0(species, "_pred_ssp585_50.rds")))
saveRDS(pred_ssp585_70, file = file.path(output_dir, paste0(species, "_pred_ssp585_70.rds")))

# Evaluate model predictions ----------------------------------------------
cat("Boyce Index for species:", species, "\n")
pred_bg_val <- terra::extract(pred_hist, bg_coords)$lyr1 %>% 
  na.omit()
pred_occ_val <- terra::extract(pred_hist, occ_coords)$lyr1 %>% 
  na.omit()

jpeg(file = file.path(output_dir, paste0(species, "_boyce_plot.jpeg")))
ecospat.boyce(fit = pred_bg_val, # vector of predicted habitat suitability of bg points
              obs = pred_occ_val, # vector of 
              nclass = 0, 
              PEplot = TRUE,
              method = 'spearman')
dev.off()
cat("Saved Boyce as .jpeg\n")

# End ---------------------------------------------------------------------
Finish <- Sys.time()
cat("Time elasped", Finish - Start, "\n")
