#######################################################
# Omniscape resistance and source layer preparation ###
#######################################################
#
# Terrell Roulston
#
#
# NOTE: The cloglog [0,1] suitability values are transformed to equal 
# 10^(3 * (1 - cloglog_suitability))
# to calculate mean resistance with the land type classification 
# which ranges [1 , 1000],
# penalizing low suitability areas such that values are transformed:
# 
# | Cloglog suitability |        Resistance |
# | ------------------: | ----------------: |
# |                1.00 |                 1 |
# |                0.67 |  approximately 10 |
# |                0.33 | approximately 100 |
# |                0.00 |              1000 |
# 

# COMPLETE RESISTANCE CALCULATION
# 1. TRANSFORMED SUITABILITY RASTER (calculated upstream)
# 2. LANDCOVER COST RASTER (See below)
# 3. PROTECTEED AREA MODIFIER (* 0.75, )
# 
# Resistance layer:
#
#   suitability resistance = 10^(3 * (1 - suitability))
#
#   base resistance =
#     mean(suitability resistance, land-cover resistance)
#
#   final resistance =
#     base resistance * protected-area modifier
#
# Land-cover resistance classes:
#   1, 10, 100, 1000
#
# Protected areas:
#   resistance multiplied by 0.75
#
#
# SOURCE LAYER (ALWAYS HISTORICAL RAW SUITABILITY SLICE)
# Source strength:
# 
# Historical suitability is used as source strength only where it is
# greater than or equal to the species-specific historical moderate
# suitability threshold (10th percentile at historical occurrences).
#
# RESISTANCE LAYER
# Resistance is calculated from the complete continuous historical or
# future cloglog suitability surface. Suitability is not thresholded
# before transformation to resistance.

# Libraries ---------------------------------------------------------------
library(tidyverse)
library(terra)

# User settings -----------------------------------------------------------

# These are the spp codes for the corymbosum complex
# Note: Cae and For are now synonums for fus and cor respectively
# SDMs need to rerun for these species by combining data
# and filtering county level for corymbosum bc GBIF data for cor
# is widely sensu Vanderkloet 1988 and has not been updated following
# recent resurrections

# Species abbreviations
# RESERCETED sensu V. corymbosum Vander Kloet
# ash – Vaccinium ashei
# cor – Vaccinium corymbosum (syn. Vaccinium austral, Vaccinium formosum)
# cot – Vaccinium constablaei
# ell – Vaccinium elliottii
# fus – Vaccinium fuscatum (syn. Vaccinium arkansanum, Vaccinium atrococcum, Vaccinium caesariense)
# sim – Vaccinium simulatum
# vir – Vaccinium virgatum (syn. Vaccinium amoenum)
# REMAINING SECT CYANOCOCCUS
# ang – Vaccinium angustifolium
# bor – Vaccinium boreale
# dar – Vaccinium darrowii
# hir – Vaccinium hirsutum
# myr – Vaccinium myrtilloides
# mys – Vaccinium myrsinites
# pal – Vaccinium pallidum (syn. Vaccinium vacillans)
# ten – Vaccinium tenellum

spp_codes <- c(
  "ash", "cor", "cot", "ell", "fus", "sim", "vir", # resurrected Corym spp
  "ang", "bor", "dar", "hir", "myr", "mys", "pal", "ten"  # remaining sect Cyanoncoccus spp
)


# for pulling different scenario suitability rasters
scenario_keys <- c(
  "hist",
  "ssp245_30",
  "ssp245_50",
  "ssp245_70",
  "ssp585_30",
  "ssp585_50",
  "ssp585_70"
)


# Protected cells receive a 25% reduction in resistance
# I think it would be good to do a sensitivity analysis

pa_multiplier <- 0.75

# Whether protected-area status should reduce resistance in cells whose
# land-cover resistance is 1000
reduce_full_barriers <- FALSE

# Output directory
input_dir <- paste0(
  "C:/Users/terre/Documents/R/vaccinium/",
  "connectivity_inputs"
)

dir.create(
  input_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

# File paths --------------------------------------------------------------

# Path to CEC landcover classes
landcover_path <- paste0(
  "C:/Users/terre/Documents/Acadia/Vaccinium/map_data/",
  "land_cover_2020v2_30m_tif/",
  "land_cover_2020v2_30m_tif/",
  "NA_NALCMS_landcover_2020v2_30m/",
  "data/",
  "NA_NALCMS_landcover_2020v2_30m.tif"
)

# Path to masked suitability rasters
# NEED TO UPDATE MASKED SDMS
masked_dir <- paste0(
  "C:/Users/terre/Documents/R/vaccinium/",
  "sdm_output/sdm_output_feb_10_2026/masked"
)

# See r_scripts/occ_gap_analysis for script on preping protected area raster
pa_raster <- rast("./maps/wdpa_prot_area/wdpa_raster_ca_us_mx.tif")


# See below for wclim template (used to resample and project coarse landscape classification below)
wclim_template <- rast('connectivity_inputs/wclim_template.tif')


# Land-cover resistance preparation --------------------------------------
################################################################
######## RUN ONCE THEN SAVE/LOAD THE COARSE LANDCOVER ##########
################################################################

# land_cats_30m <- rast(landcover_path)
# 
# # Inspect available land-cover categories
# levels(land_cats_30m)
# 
# # Resistance values for NALCMS classes
# resistance_lookup <- data.frame(
#   Value = 0:19,
#   Resistance = c(
#     NA,    # 0  Unclassified
#     
#     1,     # 1  Needleleaf forest
#     1,     # 2  Taiga forest
#     1,     # 3  Tropical evergreen forest
#     1,     # 4  Tropical deciduous forest
#     1,     # 5  Temperate deciduous forest
#     1,     # 6  Mixed forest
#     1,     # 7  Tropical shrubland
#     1,     # 8  Temperate shrubland
#     1,     # 9  Tropical grassland
#     1,     # 10 Temperate grassland
#     
#     10,    # 11 Polar shrubland
#     10,    # 12 Polar grassland
#     10,    # 13 Polar barren
#     
#     1,     # 14 Wetland
#     
#     100,   # 15 Cropland
#     
#     1000,  # 16 Barren land
#     1000,  # 17 Urban
#     1000,  # 18 Water
#     1000   # 19 Snow and ice
#   )
# )
# 
# rcl <- as.matrix(
#   resistance_lookup[, c("Value", "Resistance")]
# )
# 
# 
# # Reclassify the original 30 m categorical raster
# land_resistance_30m <- classify(
#   land_cats_30m,
#   rcl = rcl,
#   others = NA
# )
# 
# names(land_resistance_30m) <- "land_resistance"
# 
# 
# # Save the full-resolution classified raster if desired
# land_resistance_30m_path <- file.path(
#   input_dir,
#   "landcover_resistance_30m.tif"
# )

# writeRaster(
#   land_resistance_30m,
#   land_resistance_30m_path,
#   overwrite = TRUE,
#   datatype = "INT2U",
#   gdal = c("COMPRESS=LZW")
# )

# LOAD INTERMEDIATE CLASSIFICATION
#resistance_classes_rast <- rast('./connectivity_inputs/landcover_resistance_30m.tif')

# Aggregate landscape classes to lower res of clim rast -------------------
# NOTE: RUN ONCE
# Bc the landscape class is 30m while wclim raster is 2.5 arc mins need to aggregate cells to match
# Going to average the resitstance values...

# Import one of the climate rasters to use as a template to resample landcover resistance to
# This is wclim clipped to Canada, US and Mexico
#wclim_CA_US_MX <- readRDS('./wclim_data/wclim_CA_US_MX/wclim_CA_US_MX.rds')
# NOTE: USE ONLY ONE LAYER AS REFERENCE TO RESAMPLE
# wclim_template <- wclim_CA_US_MX$wc2.1_2.5m_bio_1
# 
# rm(list = c("wclim_CA_US_MX"))
# gc()

# writeRaster(wclim_template, filename = 'connectivity_inputs/wclim_template.tif')

# Resampling the landscape classification takes a hot minute
##########################################################
#### NOTE: I RAN THIS REMOTELY ON HPC, 128gb ram, 16 cores
#### see sh_scripts/RUN_LAND_RESAMPLE.sh and r_scripts/run_project_resistance.R
##########################################################

# dir.create("D:/terra_temp", showWarnings = FALSE)
# 
# terra::terraOptions(
#   tempdir = "D:/terra_temp",
#   memfrac = 0.9,
#   progress = 1
# )
# 
# resistance_rast_coarse <- project(x = resistance_classes_rast, y = wclim_template, # x = what resampled. y = template
#                                  mask = T, # mask output to the wclim predictors used in rest of analysis
#                                  method = "mean", # calculate average landscape resistance at coarser resolution
#                                  threads = T, # faster for large files like the landclass raster
#                                    progress = T,
#                                  memfrac = 0.8,
#                                  filename = './connectivity_inputs/resistance_rast_coarse.tif' # save file
#                                  ) 
# 
# resistance_rast_coarse <- project(
#   x = resistance_classes_rast,
#   y = wclim_template,
#   method = "mean",
#   mask = TRUE,
#   threads = TRUE,
#   filename = "./connectivity_inputs/resistance_rast_coarse_unmasked.tif",
#   overwrite = TRUE,
#   datatype = "FLT4S",
#   gdal = c("COMPRESS=DEFLATE", "BIGTIFF=YES")
# )
# 
# resistance_rast_coarse <- mask(
#   resistance_rast_coarse,
#   wclim_template,
#   filename = "./connectivity_inputs/resistance_rast_coarse.tif",
#   overwrite = TRUE,
#   datatype = "FLT4S",
#   gdal = c("COMPRESS=DEFLATE", "BIGTIFF=YES")
# )

################################################
####### LOAD COARSE LANDSCAPE RESISTANCE #######
################################################

land_resistance_coarse <- rast(
  file.path(
    input_dir,
    "land_resistance_coarse.tif"
  )
)

# Check alignment
compareGeom(
  land_resistance_coarse,
  wclim_template,
  stopOnError = TRUE
)

# quick summary
global(
  land_resistance_coarse,
  fun = c("min", "mean", "max"),
  na.rm = TRUE
)

# Protected area prep -----------------------------------------------------
# Convert the protected-area raster explicitly to:
#   1 = protected
#   0 = unprotected
pa_binary_original <- ifel(
  pa_raster == 1,
  1,
  0
)

names(pa_binary_original) <- "protected"

pa_binary_original <- ifel(
  is.na(pa_binary_original),
  0,
  pa_binary_original
)

pa_binary_template <- terra::project(
  x = pa_binary_original,
  y = wclim_template,
  method = "near"
)

pa_binary_template <- ifel(
  is.na(pa_binary_template),
  0,
  pa_binary_template
)

pa_binary_template <- mask(
  pa_binary_template,
  wclim_template
)

names(pa_binary_template) <- "protected"

compareGeom(
  pa_binary_template,
  wclim_template,
  stopOnError = TRUE
)

pa_binary_path <- file.path(
  input_dir,
  "protected_areas_grid.tif"
)

writeRaster(
  pa_binary_template,
  pa_binary_path,
  overwrite = TRUE,
  datatype = "INT1U",
  gdal = c("COMPRESS=LZW")
)

#pa_binary_template <- rast("connectivity_inputs/protected_areas_grid.tif")


# Resistance functions ----------------------------------------------------

# Convert continuous suitability to continuous resistance on the
# same 1-1000 scale used for land cover.
#
# Suitability = 1.00 -> resistance = 1
# Suitability = 2/3  -> resistance = 10
# Suitability = 1/3  -> resistance = 100
# Suitability = 0.00 -> resistance = 1000

suitability_to_resistance <- function(suitability) {
  
  suitability <- clamp(
    suitability,
    lower = 0,
    upper = 1
  )
  
  resistance <- 10^(
    3 * (1 - suitability)
  )
  
  names(resistance) <- "suitability_resistance"
  
  resistance
}

# Prepare an aligned covariate raster for a particular suitability raster.
#
# This is included defensively in case different species have different
# masks or extents even though their resolutions and grids should match.

align_continuous <- function(x, template) {
  
  if (!same.crs(x, template)) {
    
    x <- project(
      x,
      template,
      method = "bilinear"
    )
    
  } else if (!compareGeom(
    x,
    template,
    stopOnError = FALSE
  )) {
    
    x <- resample(
      x,
      template,
      method = "bilinear"
    )
  }
  
  x <- crop(
    x,
    template,
    snap = "near"
  )
  
  x <- extend(
    x,
    template
  )
  
  mask(
    x,
    template
  )
}


align_binary <- function(x, template) {
  
  if (
    same.crs(x, template) &&
    all(res(x) == res(template)) &&
    all(origin(x) == origin(template))
  ) {
    
    x <- crop(
      x,
      template,
      snap = "near"
    )
    
    x <- extend(
      x,
      template
    )
    
    x <- resample(
      x,
      template,
      method = "near"
    )
    
  } else {
    
    x <- project(
      x,
      template,
      method = "near"
    )
  }
  
  x <- ifel(
    is.na(x),
    0,
    x
  )
  
  mask(x, template)
}


# Function to create all omniscape input layers (source and resistance) --------

make_omniscape_layers <- function(
    source_suitability,
    resistance_suitability,
    land_resistance,
    protected_binary,
    source_threshold,
    pa_multiplier = 0.75,
    reduce_full_barriers = FALSE
) {
  
  if (
    is.null(source_suitability) ||
    is.null(resistance_suitability)
  ) {
    return(NULL)
  }
  
  if (
    length(source_threshold) != 1 ||
    is.na(source_threshold) ||
    source_threshold < 0 ||
    source_threshold > 1
  ) {
    stop(
      "source_threshold must be one non-missing value between 0 and 1."
    )
  }
  
  if (
    length(pa_multiplier) != 1 ||
    is.na(pa_multiplier) ||
    pa_multiplier <= 0 ||
    pa_multiplier > 1
  ) {
    stop(
      "pa_multiplier must be greater than 0 and no greater than 1."
    )
  }
  
  source_suitability <- source_suitability[[1]]
  resistance_suitability <- resistance_suitability[[1]]
  
  source_suitability <- clamp(
    source_suitability,
    lower = 0,
    upper = 1
  )
  
  resistance_suitability <- clamp(
    resistance_suitability,
    lower = 0,
    upper = 1
  )
  
  # Align the fixed historical source to the scenario-specific grid.
  if (!same.crs(
    source_suitability,
    resistance_suitability
  )) {
    
    source_suitability <- project(
      source_suitability,
      resistance_suitability,
      method = "bilinear"
    )
    
  } else if (!compareGeom(
    source_suitability,
    resistance_suitability,
    stopOnError = FALSE
  )) {
    
    source_suitability <- resample(
      source_suitability,
      resistance_suitability,
      method = "bilinear"
    )
  }
  
  # -----------------------------------------------------------------------
  # Complete North American analysis template
  # -----------------------------------------------------------------------
  
  # The complete coarse-resolution land-cover resistance raster defines
  # the spatial extent, resolution, origin, and valid land domain used by
  # all Omniscape input layers.
  #
  # Suitability rasters may have smaller species-specific masks, but they
  # must not define or crop the complete connectivity-analysis domain.
  
  analysis_template <- land_resistance[[1]]
  
  
  # Align historical source suitability to the complete North American
  # land-cover template.
  
  source_suitability <- align_continuous(
    source_suitability,
    analysis_template
  )
  
  
  # Align scenario-specific resistance suitability to the complete North
  # American land-cover template.
  
  resistance_suitability <- align_continuous(
    resistance_suitability,
    analysis_template
  )
  
  
  # Land-cover resistance already defines the analysis template. Retain
  # its complete geometry rather than resampling it to a masked suitability
  # raster.
  
  land_aligned <- analysis_template
  
  
  # Align the protected-area layer to the complete North American template.
  
  pa_aligned <- align_binary(
    protected_binary,
    analysis_template
  )
  
  
  # Confirm that every input has exactly the same geometry.
  
  compareGeom(
    analysis_template,
    source_suitability,
    stopOnError = TRUE
  )
  
  compareGeom(
    analysis_template,
    resistance_suitability,
    stopOnError = TRUE
  )
  
  compareGeom(
    analysis_template,
    pa_aligned,
    stopOnError = TRUE
  )
  
  
  # -----------------------------------------------------------------------
  # Complete valid land domain
  # -----------------------------------------------------------------------
  
  # Land-cover data define the complete North American analysis domain.
  # Only cells outside the valid land-cover domain remain NA.
  
  valid_domain <- !is.na(land_aligned)
  
  
  # Historical suitability may have a smaller species-specific mask.
  # Assign zero source strength in valid land-domain cells that fall
  # outside the historical suitability mask.
  
  source_suitability <- ifel(
    valid_domain & is.na(source_suitability),
    0,
    source_suitability
  )
  
  
  # Preserve NA only outside the complete North American land domain.
  
  source_suitability <- ifel(
    valid_domain,
    source_suitability,
    NA
  )
  
  
  # Scenario-specific suitability may also have a smaller ecological mask.
  # Assign zero suitability within valid North American land cells outside
  # that mask. These cells will consequently receive maximum suitability
  # resistance rather than becoming absolute gaps in the analysis domain.
  
  resistance_suitability <- ifel(
    valid_domain & is.na(resistance_suitability),
    0,
    resistance_suitability
  )
  
  
  # Preserve NA only outside the complete North American land domain.
  
  resistance_suitability <- ifel(
    valid_domain,
    resistance_suitability,
    NA
  )
  
  
  # Retain the complete land-cover resistance surface.
  
  land_aligned <- ifel(
    valid_domain,
    land_aligned,
    NA
  )
  
  
  # Protected-area cells outside the valid land domain remain NA.
  #
  # Within the land domain, cells without protected-area coverage should
  # be zero rather than NA so they are interpreted as unprotected cells.
  
  pa_aligned <- ifel(
    valid_domain & is.na(pa_aligned),
    0,
    pa_aligned
  )
  
  pa_aligned <- ifel(
    valid_domain,
    pa_aligned,
    NA
  )
  
  # -----------------------------------------------------------------------
  # Fixed historical source
  # -----------------------------------------------------------------------
  
  source <- ifel(
    source_suitability >= source_threshold,
    source_suitability,
    0
  )
  
  source <- mask(
    source,
    resistance_suitability
  )
  
  names(source) <- "source_strength"
  
  # -----------------------------------------------------------------------
  # Continuous scenario-specific climate resistance
  # -----------------------------------------------------------------------
  
  suitability_resistance <- suitability_to_resistance(
    resistance_suitability
  )
  
  # -----------------------------------------------------------------------
  # Equal arithmetic mean of climate and land-cover resistance
  # -----------------------------------------------------------------------
  
  base_resistance <- (
    suitability_resistance +
      land_aligned
  ) / 2
  
  names(base_resistance) <- "base_resistance"
  
  # -----------------------------------------------------------------------
  # Protected-area modifier
  # -----------------------------------------------------------------------
  
  if (reduce_full_barriers) {
    
    pa_eligible <- pa_aligned == 1
    
  } else {
    
    pa_eligible <-
      pa_aligned == 1 &
      land_aligned < 1000
  }
  
  protected_modifier <- ifel(
    pa_eligible,
    pa_multiplier,
    1
  )
  
  names(protected_modifier) <- "protected_modifier"
  
  final_resistance <-
    base_resistance *
    protected_modifier
  
  final_resistance <- clamp(
    final_resistance,
    lower = 1,
    upper = 1000
  )
  
  final_resistance <- mask(
    final_resistance,
    resistance_suitability
  )
  
  names(final_resistance) <- "resistance"
  
  list(
    source = source,
    source_suitability = source_suitability,
    resistance_suitability = resistance_suitability,
    suitability_resistance = suitability_resistance,
    land_resistance = land_aligned,
    protected = pa_aligned,
    protected_modifier = protected_modifier,
    base_resistance = base_resistance,
    resistance = final_resistance
  )
}

# READ SDM predictions and thresholds ----------------------------

# Read in masked SDM predictions
safe_read_rds <- function(path) {
  
  if (!file.exists(path)) {
    warning("Prediction file not found: ", path)
    return(NULL)
  }
  
  x <- readRDS(path)
  
  if (!inherits(x, "SpatRaster")) {
    stop(
      "File does not contain a SpatRaster: ",
      path
    )
  }
  
  if (nlyr(x) < 1) {
    stop(
      "Prediction raster has no layers: ",
      path
    )
  }
  
  x[[1]]
}

load_preds <- function(
    sp,
    masked_dir,
    scenario_keys
) {
  
  paths <- setNames(
    file.path(
      masked_dir,
      sp,
      paste0(
        sp,
        "_",
        scenario_keys,
        "_mask.rds"
      )
    ),
    scenario_keys
  )
  
  setNames(
    lapply(
      paths,
      safe_read_rds
    ),
    scenario_keys
  )
}

all_preds <- setNames(
  lapply(
    spp_codes,
    load_preds,
    masked_dir = masked_dir,
    scenario_keys = scenario_keys
  ),
  spp_codes
)


# Read in thresholds
threshold_dir <- file.path(
  "C:/Users/terre/Documents/R/vaccinium",
  "sdm_output",
  "sdm_output_feb_10_2026",
  "thresholds"
)

load_thresholds <- function(sp, threshold_dir) {
  
  threshold_path <- file.path(
    threshold_dir,
    paste0(sp, "_thresholds_hist.rds")
  )
  
  if (!file.exists(threshold_path)) {
    stop("Threshold file not found: ", threshold_path)
  }
  
  thresholds <- readRDS(threshold_path)
  
  if (!is.numeric(thresholds)) {
    stop("Threshold object is not numeric for species: ", sp)
  }
  
  required_names <- c("low", "mod", "high")
  
  if (!all(required_names %in% names(thresholds))) {
    stop(
      "Threshold object for ", sp,
      " must contain: ",
      paste(required_names, collapse = ", "),
      ". Found: ",
      paste(names(thresholds), collapse = ", ")
    )
  }
  
  if (
    anyNA(thresholds[required_names]) ||
    any(thresholds[required_names] < 0) ||
    any(thresholds[required_names] > 1)
  ) {
    stop(
      "Threshold values for ", sp,
      " must be non-missing and between 0 and 1."
    )
  }
  
  thresholds
}

all_thresholds <- setNames(
  lapply(
    spp_codes,
    load_thresholds,
    threshold_dir = threshold_dir
  ),
  spp_codes
)


# PREFLIGHT CHECKS --------------------------------------------------------
# MAKE SURE YOU GOT ALL THE STUFF
required_objects <- c(
  "spp_codes",
  "scenario_keys",
  "all_preds",
  "all_thresholds",
  "land_resistance_coarse",
  "pa_binary_template",
  "pa_multiplier",
  "reduce_full_barriers",
  "input_dir"
)

missing_objects <- required_objects[
  !vapply(
    required_objects,
    exists,
    logical(1),
    inherits = TRUE
  )
]

if (length(missing_objects) > 0) {
  stop(
    "Missing required objects: ",
    paste(
      missing_objects,
      collapse = ", "
    )
  )
}

missing_prediction_species <- setdiff(
  spp_codes,
  names(all_preds)
)

if (length(missing_prediction_species) > 0) {
  stop(
    "Species missing from all_preds: ",
    paste(
      missing_prediction_species,
      collapse = ", "
    )
  )
}

missing_threshold_species <- setdiff(
  spp_codes,
  names(all_thresholds)
)

if (length(missing_threshold_species) > 0) {
  stop(
    "Species missing from all_thresholds: ",
    paste(
      missing_threshold_species,
      collapse = ", "
    )
  )
}

# CREATE ALL LAYERS -------------------------------------------------------
all_connectivity_layers <- setNames(
  vector(
    mode = "list",
    length = length(spp_codes)
  ),
  spp_codes
)

for (sp in spp_codes) {
  
  message("Preparing species: ", sp)
  
  species_preds <- all_preds[[sp]]
  historical_suitability <- species_preds[["hist"]]
  
  if (is.null(historical_suitability)) {
    warning("Historical raster missing for: ", sp)
    next
  }
  
  species_thresholds <- all_thresholds[[sp]]
  
  moderate_threshold <- unname(
    species_thresholds[["mod"]]
  )
  
  message(
    "  Historical moderate threshold: ",
    round(moderate_threshold, 6)
  )
  
  all_connectivity_layers[[sp]] <- setNames(
    vector(
      mode = "list",
      length = length(scenario_keys)
    ),
    scenario_keys
  )
  
  for (scenario in scenario_keys) {
    
    scenario_suitability <- species_preds[[scenario]]
    
    if (is.null(scenario_suitability)) {
      
      warning(
        "Skipping missing raster: ",
        sp,
        " / ",
        scenario
      )
      
      next
    }
    
    message("  Scenario: ", scenario)
    
    all_connectivity_layers[[sp]][[scenario]] <-
      make_omniscape_layers(
        source_suitability = historical_suitability,
        resistance_suitability = scenario_suitability,
        land_resistance = land_resistance_coarse,
        protected_binary = pa_binary_template,
        source_threshold = moderate_threshold,
        pa_multiplier = pa_multiplier,
        reduce_full_barriers = reduce_full_barriers
      )
  }
}


# Export all Omniscape source and resistance rasters ----------------------

for (sp in names(all_connectivity_layers)) {
  
  species_output_dir <- file.path(
    input_dir,
    sp
  )
  
  dir.create(
    species_output_dir,
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  for (scenario in names(all_connectivity_layers[[sp]])) {
    
    layers <- all_connectivity_layers[[sp]][[scenario]]
    
    if (is.null(layers)) {
      next
    }
    
    source_path <- file.path(
      species_output_dir,
      paste0(
        sp,
        "_",
        scenario,
        "_source.tif"
      )
    )
    
    resistance_path <- file.path(
      species_output_dir,
      paste0(
        sp,
        "_",
        scenario,
        "_resistance.tif"
      )
    )
    
    compareGeom(
      layers$source,
      layers$resistance,
      stopOnError = TRUE
    )
    
    source_minmax <- global(
      layers$source,
      c("min", "max"),
      na.rm = TRUE
    )
    
    resistance_minmax <- global(
      layers$resistance,
      c("min", "max"),
      na.rm = TRUE
    )
    
    if (
      source_minmax[1, "min"] < 0 ||
      source_minmax[1, "max"] > 1
    ) {
      stop(
        "Invalid source values for ",
        sp,
        " / ",
        scenario
      )
    }
    
    if (
      resistance_minmax[1, "min"] < 1 ||
      resistance_minmax[1, "max"] > 1000
    ) {
      stop(
        "Invalid resistance values for ",
        sp,
        " / ",
        scenario
      )
    }
    
    n_source_cells <- global(
      layers$source > 0,
      "sum",
      na.rm = TRUE
    )[1, 1]
    
    if (
      is.na(n_source_cells) ||
      n_source_cells == 0
    ) {
      stop(
        "No source cells were produced for ",
        sp,
        " / ",
        scenario
      )
    }
    
    writeRaster(
      layers$source,
      source_path,
      overwrite = TRUE,
      datatype = "FLT4S",
      NAflag = 9999, # set NA flag as positive number of Omniscape fails
      gdal = c("COMPRESS=LZW")
    )
    
    writeRaster(
      layers$resistance,
      resistance_path,
      overwrite = TRUE,
      datatype = "FLT4S",
      NAflag = 9999, # set NA flag as positive number of Omniscape fails
      gdal = c("COMPRESS=LZW")
    )
  }
}


