# Connectivity analysis using RSynroSim pacakge with Omniscape
# May 18th 2026
# Terrell Roulston


# Requires Julia, Conda and SynroSim software installed!
# See RSynroSim docs: https://cran.r-project.org/web/packages/rsyncrosim/rsyncrosim.pdf
# Omniscape docs: https://apexrms.github.io/omniscape/tutorials/omniscape
 
library(tidyverse) # Data management
library(rsyncrosim) # R interface for SynroSim
library(terra) # Spatial anylsis

# Load suitability rasters ------------------------------------------------
# - Corymbosum complex outputs in: sdm_output/sdm_output_feb_10_2026/masked/{sp}/

# Corymbossum complex species codes
sp_codes2 <- c(
  "ash", "cae", "cor2", "cot", "ell",
  "for", "fus", "sim", "vir"
)

# Path to cropped   
masked_dir <- "C:/Users/terre/Documents/R/vaccinium/sdm_output/sdm_output_feb_10_2026/masked"

# Helper: safe RDS read (expects SpatRaster inside)
safe_read_rds <- function(path) {
  if (!file.exists(path)) return(NULL)
  readRDS(path)
}

# Each subpath for each predicted layer
load_preds <- function(sp, masked_dir) {
  
  # paths
  key_paths <- list(
    hist      = file.path(masked_dir, sp, paste0(sp, "_hist_mask.rds")),
    ssp245_30 = file.path(masked_dir, sp, paste0(sp, "_ssp245_30_mask.rds")),
    ssp245_50 = file.path(masked_dir, sp, paste0(sp, "_ssp245_50_mask.rds")),
    ssp245_70 = file.path(masked_dir, sp, paste0(sp, "_ssp245_70_mask.rds")),
    ssp585_30 = file.path(masked_dir, sp, paste0(sp, "_ssp585_30_mask.rds")),
    ssp585_50 = file.path(masked_dir, sp, paste0(sp, "_ssp585_50_mask.rds")),
    ssp585_70 = file.path(masked_dir, sp, paste0(sp, "_ssp585_70_mask.rds"))
  )
  
  # iterate safe loader over paths
  preds <- lapply(key_paths, safe_read_rds) 
  
  # assign path attribute
  attr(preds, "paths") <- key_paths
  preds
}

# Now use helpers to load all predictors for all species
all_preds <- lapply(
  sp_codes2, # spp codes
  load_preds, # sub dirs
  masked_dir = masked_dir # main dir
)

names(all_preds) <- sp_codes2 # assign spp code names to each object


# Load resistance layers --------------------------------------------------
# This is a place holder for all the resistance layers I have to still make...
# Fuck me...

# Doing climate only resistance for now
# Test with one species first
test_sp <- "ash"

source_rasters <- all_preds[[test_sp]]

resistance_rasters <- map(source_rasters, function(r) {
  
  if (is.null(r)) return(NULL)
  
  # Make suitability sure values are bounded
  r <- clamp(r, lower = 0, upper = 1)
  
  # Avoid divide-by-zero
  conductance <- clamp(r, lower = 0.001)
  
  resistance <- 1 / conductance
  
  return(resistance)
})

# CHECK TO SEE IF WORKED
names(source_rasters)
names(resistance_rasters)

plot(source_rasters$hist)
plot(resistance_rasters$hist)

global(source_rasters$hist, range, na.rm = TRUE)
global(resistance_rasters$hist, range, na.rm = TRUE)

# Looks good

# !!!!! IMPORTATNT NOTE !!!!!
# To avoid very small source values all across the background threshold the suitability (source) layer
# using values >= 0.1 like the moderate threshold

source_rasters_thresh <- map(source_rasters, function(r) {
  
  if (is.null(r)) return(NULL)
  
  ifel(r >= 0.1, r, 0)
})

# For now I am going to export the source and restiance layer to the same folder for this test
# I want to simplify the omniscape work for now...

input_dir <- "C:/Users/terre/Documents/R/vaccinium/connectivity_inputs"
dir.create(input_dir, recursive = TRUE, showWarnings = FALSE)

writeRaster(
  source_rasters_thresh$hist,
  file.path(input_dir, "ash_hist_source.tif"),
  overwrite = TRUE
)

writeRaster(
  resistance_rasters$hist,
  file.path(input_dir, "ash_hist_resistance.tif"),
  overwrite = TRUE
)


# Start omniscape session -------------------------------------------------
ssim <- rsyncrosim::session() # Start session
packages(ssim) # Check what packages are installed

lib_path <- "C:/Users/terre/Documents/R/vaccinium/connectivity_syncrosim/vaccinium_connectivity.ssim"

dir.create(dirname(lib_path), recursive = TRUE, showWarnings = FALSE)

# Load the omniscape package  
lib <- ssimLibrary(
  name = lib_path,
  session = ssim,
  package = "omniscape"
)

lib # print loaded SynroSim libraries -- should see omniscape

# Inspect what data omniscape expects
datasheet(lib)

# List scenarios
scenario(lib)

# Define conda path -------------------------------------------------------
# Need to do before starting session
Sys.setenv(
  PATH = paste(
    "C:/Users/terre/miniconda3",
    "C:/Users/terre/miniconda3/Scripts",
    "C:/Users/terre/miniconda3/Library/bin",
    Sys.getenv("PATH"),
    sep = ";"
  )
)

Sys.which("conda")
system("conda --version")


# Define Julia path -------------------------------------------------------
# Setting path to Julia using the executable that R can actually find

julia_path <- "C:/Users/terre/.julia/juliaup/julia-1.12.6+0.x64.w64.mingw32/bin/julia.exe"

file.exists(julia_path) # TRUE

system2(julia_path, "--version")


# Save Julia executable path to SyncroSim core Julia config
jl <- rsyncrosim::datasheet(lib, name = "core_JlConfig", empty = TRUE)

jl[1, ] <- NA
jl$ExePath <- julia_path
jl$RunInWindow <- FALSE
jl$ExePathVSCode <- NA
jl$UseVSCode <- FALSE

rsyncrosim::saveDatasheet(
  ssimObject = lib,
  data = jl,
  name = "core_JlConfig"
)


# Save Julia executable path to Omniscape Julia config, if this datasheet exists
omni_jl <- rsyncrosim::datasheet(lib, name = "omniscape_juliaConfiguration", empty = TRUE)

omni_jl[1, ] <- NA
omni_jl$juliaPath <- julia_path

rsyncrosim::saveDatasheet(
  ssimObject = lib,
  data = omni_jl,
  name = "omniscape_juliaConfiguration"
)


# Check saved paths
rsyncrosim::datasheet(lib, name = "core_JlConfig")
rsyncrosim::datasheet(lib, name = "omniscape_juliaConfiguration")




# Open syncrosim project --------------------------------------------------
proj <- rsyncrosim::project(
  ssimObject = lib,
  project = "Definitions"
)

proj


# Open/create scenario ----------------------------------------------------
# Create a test scenario
scn <- scenario(
  ssimObject = proj,
  scenario = "ash_hist_test"
)

scn

# Inspect datasheets
rsyncrosim::datasheet(scn)

# Try to figure out what the key datasheets are...
required <- rsyncrosim::datasheet(scn, name = "omniscape_Required")
general  <- rsyncrosim::datasheet(scn, name = "omniscape_GeneralOptions")
res_opts <- rsyncrosim::datasheet(scn, name = "omniscape_ResistanceOptions")
out_opts <- rsyncrosim::datasheet(scn, name = "omniscape_OutputOptions")
cond1    <- rsyncrosim::datasheet(scn, name = "omniscape_Condition1")

required
general
res_opts
out_opts
cond1

str(required)
str(general)
str(res_opts)
str(cond1)

# Okay looks like I can start with the required stuff only
# Its expecting Resistance, Source, and Window Radius

source_path <- "C:/Users/terre/Documents/R/vaccinium/connectivity_inputs/ash_hist_source.tif"

resistance_path <- "C:/Users/terre/Documents/R/vaccinium/connectivity_inputs/ash_hist_resistance.tif"

# Minimal Omniscape required inputs

required_new <- data.frame(
  resistanceFile = resistance_path,
  radius = 5,
  sourceFile = source_path
)

# Save required inputs to the scenario

rsyncrosim::saveDatasheet(
  ssimObject = scn,
  data = required_new,
  name = "omniscape_Required"
)

rsyncrosim::datasheet(scn, name = "omniscape_Required") # Check to see if it saved properly




# Define pipeline ---------------------------------------------------------

pipe <- rsyncrosim::datasheet(scn, name = "core_Pipeline")
pipe
str(pipe)

#rsyncrosim::datasheet(lib, name = "core_Pipeline")
#rsyncrosim::datasheet(proj, name = "core_Pipeline")


pipe_new <- data.frame(
  StageNameId = factor(
    "1 - Omniscape",
    levels = levels(pipe$StageNameId)
  ),
  RunOrder = 1
)

rsyncrosim::saveDatasheet(
  ssimObject = scn,
  data = pipe_new,
  name = "core_Pipeline"
)

rsyncrosim::datasheet(scn, name = "core_Pipeline")

# General options were empty so need to tell it the source layer
general_new <- data.frame(
  sourceFromResistance = FALSE,
  calcNormalizedCurrent = TRUE,
  calcFlowPotential = TRUE
)

rsyncrosim::saveDatasheet(
  ssimObject = scn,
  data = general_new,
  name = "omniscape_GeneralOptions"
)

rsyncrosim::datasheet(scn, name = "omniscape_GeneralOptions")


# Debugging, omniscape is running now but options are missing
general <- rsyncrosim::datasheet(scn, name = "omniscape_GeneralOptions")
general
str(general)

rsyncrosim::datasheet(scn, name = "omniscape_GeneralOptions", empty = TRUE)


# RUN ---------------------------------------------------------------------
# I AM STILL HAVING ISSUES RUNNING THE SCENARIO FROM R
# CURRENTLY SETTING PARAMETERS IN R AND RUNNING VIA NATIVE
# SYNRCOSIM SOFTWARE

start <- Sys.time()
result <- rsyncrosim::run(
  scn,
  summary = FALSE
)
finish <- Sys.time()
elasped <- finish - start
print(elasped)



# Take a look at results --------------------------------------------------
# Open the completed result scenario
res15 <- rsyncrosim::scenario(proj, scenario = 15)

# See available output datasheets
rsyncrosim::datasheet(res15)
  
# Inspect spatial output
out_spatial <- rsyncrosim::datasheet(res15, name = "omniscape_outputSpatial")
out_spatial

# plot
library(terra)

cum <- rast(out_spatial$cumCurrmap) # cummlative current
plot(cum, main = 'Cumlative current flow')

rest <- rast(out_spatial$classifiedResistance)
plot(rest)
