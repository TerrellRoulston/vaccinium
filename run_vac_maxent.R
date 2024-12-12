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
    bg_file = '/project/6074193/mig_lab/vac_sdm/ang_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_angThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_ang.Rdata'
  ),
  "arb" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/arb_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_arbThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_arb.Rdata'
  ),
  "bor" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/bor_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_borThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_bor.Rdata'
  ),
  "ces" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/ces_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_cesThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_ces.Rdata'
  ),
  "cor" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/cor_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_corThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_cor.Rdata'
  ),
  "cra" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/cra_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_craThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_cra.Rdata'
  ),
  "dar" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/dar_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_darThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_dar.Rdata'
  ),
  "del" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/del_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_delThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_del.Rdata'
  ),
  "ery" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/ery_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_eryThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_ery.Rdata'
  ),
  "hir" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/hir_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_hirThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_hir.Rdata'
  ),
  "mac" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/mac_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_macThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_mac.Rdata'
  ),
  "mem" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/mem_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_memThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_mem.Rdata'
  ),
  "mys" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/mys_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_mysThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_mys.Rdata'
  ),
  "myr" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/myr_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_myrThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_myr.Rdata'
  ),
  "mtu" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/mtu_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_mtuThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_mtu.Rdata'
  ),
  "ova" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/ova_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_ovaThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_ova.Rdata'
  ),
  "ovt" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/ovt_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_ovtThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_ovt.Rdata'
  ),
  "oxy" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/oxy_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_oxyThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_oxy.Rdata'
  ),
  "pal" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/pal_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_palThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_pal.Rdata'
  ),
  "par" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/par_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_parThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_par.Rdata'
  ),
  "sco" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/sco_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_scoThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_sco.Rdata'
  ),
  "sta" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/sta_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_staThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_sta.Rdata'
  ),
  "ten" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/ten_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_tenThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_ten.Rdata'
  ),
  "vir" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/vir_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_virThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_vir.Rdata'
  ),
  "vid" = list(
    bg_file = '/project/6074193/mig_lab/vac_sdm/vid_bg_vec.Rdata',
    occ_file = '/project/6074193/mig_lab/vac_sdm/occ_vidThin.Rdata',
    env_file = '/project/6074193/mig_lab/vac_sdm/wclim_vid.Rdata'
  )
)

if (!species %in% names(species_list)) {
  stop("Error: Species not found in the species list.")
}


# Load data specific to species -------------------------------------------
# Load data for the specified species
sp_data <- species_list[[species]] # What species is being performed in the array?
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
    occ_coords = occ_coords, # geom of occ data
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

# Save Maxent Outputs -----------------------------------------------------
# Save outputs
output_dir <- file.path("/project/6074193/mig_lab/vac_sdm/output", species)
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE) # check if dir exists, if not create (avoids errors when outputting)
if (exists("maxent_model")) {
  saveRDS(maxent_model, file = file.path(output_dir, paste0(species, "_maxent_model.RDS"))) #Save the MaxEnt model object as an RDS file in the species-specific output directory
  write.csv(subset(maxent_model@results, delta.AICc == 0), 
            file = file.path(output_dir, paste0(species, "_evaluation.csv")))
}

cat("Processing completed for species:", species, "\n")

Finish <- Sys.time()
cat("Time elasped", Finish - Start, "\n")
