# Top ---------------------------------------------------------------------
# MaxEnt Species Distribution Modeling (SDM) for Vaccinium CWR
# Script for HPC anaylsis for all species
# Terrell Roulston
# Started Dec 12, 2024


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
species_list <- list(
  "ang" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/ang_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_angThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_ang.Rdata'
  ),
  "arb" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/arb_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_arbThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_arb.Rdata'
  ),
  "bor" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/bor_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_borThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_bor.Rdata'
  ),
  "ces" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/ces_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_cesThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_ces.Rdata'
  ),
  "cor" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/cor_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_corThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_cor.Rdata'
  ),
  "cra" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/cra_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_craThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_cra.Rdata'
  ),
  "dar" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/dar_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_darThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_dar.Rdata'
  ),
  "del" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/del_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_delThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_del.Rdata'
  ),
  "ery" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/ery_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_eryThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_ery.Rdata'
  ),
  "hir" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/hir_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_hirThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_hir.Rdata'
  ),
  "mac" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/mac_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_macThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_mac.Rdata'
  ),
  "mem" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/mem_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_memThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_mem.Rdata'
  ),
  "mys" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/mys_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_mysThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_mys.Rdata'
  ),
  "myr" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/myr_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_myrThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_myr.Rdata'
  ),
  "mtu" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/mtu_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_mtuThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_mtu.Rdata'
  ),
  "ova" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/ova_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_ovaThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_ova.Rdata'
  ),
  "ovt" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/ovt_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_ovtThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_ovt.Rdata'
  ),
  "oxy" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/oxy_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_oxyThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_oxy.Rdata'
  ),
  "pal" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/pal_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_palThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_pal.Rdata'
  ),
  "par" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/par_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_parThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_par.Rdata'
  ),
  "sco" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/sco_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_scoThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_sco.Rdata'
  ),
  "sta" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/sta_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_staThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_sta.Rdata'
  ),
  "ten" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/ten_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_tenThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_ten.Rdata'
  ),
  "uli" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/uli_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_uliThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_uli.Rdata'
  ),
  "vir" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/vir_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_virThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_vir.Rdata'
  ),
  "vid" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bg_data/vid_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_data/occ_vidThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_data/wclim_vid.Rdata'
  )
)

if (!species %in% names(species_list)) {
  stop("Error: Species not found in the species list.")
}


# Load data specific to species -------------------------------------------
# Load data for the specified species
sp_data <- species_list[[species]] # Return What species is being ran in the array
bg_vec <- readRDS(sp_data$bg_file) # Read bg data specific to that sp
occ <- readRDS(sp_data$occ_file) # Read occ data specific to that sp
envs <- readRDS(sp_data$env_file) # Read cropped Wclim data for that sp
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
    n.bg = 10000, 
    tune.args = list(rm = seq(0.5, 8, 0.5), fc = c("L", "LQ", "H", "LQH", "LQHP")),
    partition.settings = list(aggregation.factor = c(9, 9), gridSampleN = 10000), # 9,9 agg
    partitions = 'checkerboard2',
    parallel = TRUE,
    numCores = ncores, # utalize all available cores
    parallelType = "doParallel", # set to doParallel for use on HPC
    algorithm = 'maxent.jar'
  )
}, error = function(e) {
  cat("Error in ENMevaluate for species", species, ":", e$message, "\n")
})

cat("Finnished ")
# Save Maxent Outputs -----------------------------------------------------
# Save outputs
output_dir <- file.path("/project/6074193/mig_lab/vac_sdm/sdm_output", species)
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE) # check if dir exists, if not create (avoids errors when outputting)
if (exists("maxent_model")) {
  saveRDS(maxent_model, file = file.path(output_dir, paste0(species, "_maxent_model.RDS"))) #Save the MaxEnt model object as an RDS file in the species-specific output directory
  write.csv(subset(maxent_model@results, delta.AICc == 0), 
            file = file.path(output_dir, paste0(species, "_evaluation.csv")))
}

# Select the best performing Maxent model for the predictions below
best_model <- subset(maxent_model@results, delta.AICc == 0) # selects the best performing model based on delta AICc - returns data frame object
mod.best_maxent <- eval.models(maxent_model)[[best_model$tune.args]]


# Load climate data for predictions ---------------------------------------
wclim <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/wclim.Rdata')
ssp245_2030 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp245_2030.Rdata')
ssp245_2050 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp245_2050.Rdata')
ssp245_2070 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp245_2070.Rdata')
ssp585_2030 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp585_2030.Rdata')
ssp585_2050 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp585_2050.Rdata')
ssp585_2070 <- readRDS('/project/6074193/mig_lab/vac_sdm/wclim_data/ssp585_2070.Rdata')
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
saveRDS(pred_hist, file = file.path(output_dir, paste0(species, "_pred_hist.RDS")))
saveRDS(pred_ssp245_30, file = file.path(output_dir, paste0(species, "_pred_ssp245_30.RDS")))
saveRDS(pred_ssp245_50, file = file.path(output_dir, paste0(species, "_pred_ssp245_50.RDS")))
saveRDS(pred_ssp245_70, file = file.path(output_dir, paste0(species, "_pred_ssp245_70.RDS")))
saveRDS(pred_ssp585_30, file = file.path(output_dir, paste0(species, "_pred_ssp585_30.RDS")))
saveRDS(pred_ssp585_50, file = file.path(output_dir, paste0(species, "_pred_ssp585_50.RDS")))
saveRDS(pred_ssp585_70, file = file.path(output_dir, paste0(species, "_pred_ssp585_70.RDS")))

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
