# Historical Omniscape sensitivity analysis
# July 2026
# Terrell Roulston
#
# Purpose:
# 1. Read previously prepared historical source and resistance rasters.
# 2. Validate all source-resistance raster pairs.
# 3. Create one Omniscape scenario for each species and sensitivity variant.
# 4. Run all historical sensitivity models.
# 5. Record run status, elapsed time, parameter values, and output paths.
#
# A separate model-selection script will:
# 1. Read the cumulative-current outputs.
# 2. Apply a common comparison mask.
# 3. Calculate pairwise Spearman rank correlations among sensitivity models.
# 4. Calculate the mean pairwise correlation for each model.
# 5. Select the consensus resistance parameterization.
#
# Requires:
# - Julia
# - Conda or Miniconda
# - SyncroSim
# - Omniscape SyncroSim package
# - R packages: tidyverse, rsyncrosim, terra
#
# Input directory structure:
#
# connectivity_inputs/
#   sensitivity_analysis/
#     baseline/
#       ang/
#         ang_hist_source.tif
#         ang_hist_resistance.tif
#       ash/
#         ash_hist_source.tif
#         ash_hist_resistance.tif
#     shallow_suitability/
#       ang/
#         ang_hist_source.tif
#         ang_hist_resistance.tif
#     ...
#
# Every model is identified by:
#
# species + climate + sensitivity variant
#
# Example:
#
# ang_hist_baseline


# Packages ----------------------------------------------------------------

library(tidyverse)   # Data management, iteration, and table export
library(rsyncrosim)  # R interface for SyncroSim
library(terra)       # Raster reading and validation


# User controls ------------------------------------------------------------

# Keep this TRUE while testing the R-to-SyncroSim workflow.
#
# TRUE:
#   Only the model identified by test_species and test_variant is run.
#
# FALSE:
#   All 120 historical sensitivity models are run.

run_test_only <- TRUE


# Model used for the initial test run
test_species <- "ang"
test_variant <- "land_weighted"


# Whether a previously successful model should be skipped when the script
# is restarted and an existing manifest is found.
#
# This is useful if a long batch stops partway through. Models already marked
# as successful will not be repeated.

skip_successful_runs <- TRUE


# Species and sensitivity parameters --------------------------------------

# Vaccinium sect. Cyanococcus species included in the connectivity analysis.
#
# The first group contains resurrected Corymbosum-complex taxa.
# The second group contains the remaining sect. Cyanococcus species.

spp_codes <- c(
  "ash", "cor", "cot", "ell", "fus", "sim", "vir",
  "ang", "bor", "dar", "hir", "myr", "mys", "pal", "ten"
)


# Resistance-layer sensitivity variants.
#
# These values document how the already-prepared resistance rasters were
# produced. This script does not reconstruct the resistance surfaces.
#
# The parameters are retained here so that:
#
# 1. each Omniscape run is traceable;
# 2. the final manifest records the tested assumptions;
# 3. the model-selection script can associate outputs with parameter values.

sensitivity_parameters <- tribble(
  ~variant, ~description, ~suitability_exponent, ~suitability_weight, ~land_weight, ~pa_multiplier, ~reduce_full_barriers,
  "baseline", "Main resistance model", 3, 0.50, 0.50, 0.75, FALSE,
  "shallow_suitability", "Shallower suitability-resistance curve", 2, 0.50, 0.50, 0.75, FALSE,
  "steep_suitability", "Steeper suitability-resistance curve", 4, 0.50, 0.50, 0.75, FALSE,
  "suitability_weighted", "Suitability receives 75% of component weight", 3, 0.75, 0.25, 0.75, FALSE,
  "land_weighted", "Land cover receives 75% of component weight", 3, 0.25, 0.75, 0.75, FALSE,
  "no_pa_effect", "Protected areas do not modify resistance", 3, 0.50, 0.50, 1.00, FALSE,
  "strong_pa_effect", "Protected areas reduce resistance by 50%", 3, 0.50, 0.50, 0.50, FALSE,
  "pa_full_barriers", "Protected areas may modify full land-cover barriers", 3, 0.50, 0.50, 0.75, TRUE
)


# Confirm that species and variant names are unique ------------------------

if (anyDuplicated(spp_codes)) {
  stop(
    "spp_codes contains duplicate species codes."
  )
}

if (anyDuplicated(sensitivity_parameters$variant)) {
  stop(
    "sensitivity_parameters contains duplicate variant names."
  )
}

if (!test_species %in% spp_codes) {
  stop(
    "test_species is not present in spp_codes: ",
    test_species
  )
}

if (!test_variant %in% sensitivity_parameters$variant) {
  stop(
    "test_variant is not present in sensitivity_parameters: ",
    test_variant
  )
}


# File paths ---------------------------------------------------------------

# Main directory containing the prepared historical sensitivity inputs
input_dir <- file.path(
  "C:/Users/terre/Documents/R/vaccinium",
  "connectivity_inputs",
  "sensitivity_analysis"
)


# SyncroSim library used for the connectivity analysis
library_path <- file.path(
  "C:/Users/terre/Documents/R/vaccinium",
  "connectivity_syncrosim",
  "vaccinium_connectivity.ssim"
)


# Directory used to store run logs and manifests
log_dir <- file.path(
  "C:/Users/terre/Documents/R/vaccinium",
  "connectivity_outputs",
  "sensitivity_run_logs"
)


# A stable manifest filename is used so that the script can be restarted.
#
# The manifest is overwritten after each completed or failed model, preserving
# the most recent status of the full analysis.

manifest_path <- file.path(
  log_dir,
  "omniscape_sensitivity_manifest.csv"
)


# Complete R object containing the latest run information
results_rds_path <- file.path(
  log_dir,
  "omniscape_sensitivity_results.rds"
)


# Confirm that the input directory exists
if (!dir.exists(input_dir)) {
  stop(
    "Sensitivity input directory does not exist:\n",
    input_dir
  )
}


# Create output and SyncroSim directories if needed
dir.create(
  path = dirname(library_path),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  path = log_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# Construct the historical sensitivity run table --------------------------

# Create every combination of species and sensitivity parameterization.
#
# With:
#
# 15 species × 8 sensitivity variants
#
# the table should contain 120 historical Omniscape runs.

sensitivity_runs <- tidyr::crossing(
  species = spp_codes,
  sensitivity_parameters
) |>
  mutate(
    climate = "hist",
    
    # Unique SyncroSim scenario name
    scenario_name = paste(
      species,
      climate,
      variant,
      sep = "_"
    ),
    
    # Expected source raster:
    #
    # sensitivity_analysis/
    #   {variant}/
    #     {species}/
    #       {species}_hist_source.tif
    
    source_path = file.path(
      input_dir,
      variant,
      species,
      paste0(
        species,
        "_hist_source.tif"
      )
    ),
    
    # Expected resistance raster:
    #
    # sensitivity_analysis/
    #   {variant}/
    #     {species}/
    #       {species}_hist_resistance.tif
    
    resistance_path = file.path(
      input_dir,
      variant,
      species,
      paste0(
        species,
        "_hist_resistance.tif"
      )
    )
  ) |>
  select(
    species,
    climate,
    variant,
    scenario_name,
    description,
    source_path,
    resistance_path,
    suitability_exponent,
    suitability_weight,
    land_weight,
    pa_multiplier,
    reduce_full_barriers
  )


# Confirm that the run table has the expected number of rows
expected_number_of_runs <-
  length(spp_codes) * nrow(sensitivity_parameters)

if (nrow(sensitivity_runs) != expected_number_of_runs) {
  stop(
    "The run table contains ",
    nrow(sensitivity_runs),
    " rows but ",
    expected_number_of_runs,
    " were expected."
  )
}


# Scenario names must be unique
if (anyDuplicated(sensitivity_runs$scenario_name)) {
  stop(
    "Duplicate SyncroSim scenario names were generated."
  )
}


message(
  "Historical sensitivity run table contains ",
  nrow(sensitivity_runs),
  " models."
)


# Check whether all expected files exist -----------------------------------

sensitivity_runs <- sensitivity_runs |>
  mutate(
    source_exists = file.exists(source_path),
    resistance_exists = file.exists(resistance_path),
    inputs_exist = source_exists & resistance_exists
  )


# Summarize input availability
input_file_summary <- sensitivity_runs |>
  summarise(
    total_runs = n(),
    source_files_found = sum(source_exists),
    resistance_files_found = sum(resistance_exists),
    complete_input_pairs = sum(inputs_exist)
  )

print(input_file_summary)


# List any missing source or resistance files
missing_inputs <- sensitivity_runs |>
  filter(!inputs_exist) |>
  select(
    species,
    variant,
    source_exists,
    resistance_exists,
    source_path,
    resistance_path
  )


# Stop before opening rasters if any input files are missing
if (nrow(missing_inputs) > 0) {
  
  print(
    missing_inputs,
    n = Inf,
    width = Inf
  )
  
  stop(
    nrow(missing_inputs),
    " sensitivity run(s) have missing source or resistance rasters."
  )
}


# Function: validate one source-resistance pair ----------------------------

validate_omniscape_inputs <- function(
    source_path,
    resistance_path
) {
  
  # Read the source and resistance rasters
  source <- terra::rast(source_path)
  resistance <- terra::rast(resistance_path)
  
  
  # Both Omniscape inputs should contain exactly one raster layer
  if (terra::nlyr(source) != 1) {
    stop(
      "Source raster must contain exactly one layer:\n",
      source_path
    )
  }
  
  if (terra::nlyr(resistance) != 1) {
    stop(
      "Resistance raster must contain exactly one layer:\n",
      resistance_path
    )
  }
  
  
  # The source and resistance rasters used in one Omniscape model must have
  # identical geometry.
  #
  # This checks:
  #
  # - coordinate reference system;
  # - extent;
  # - number of rows and columns;
  # - resolution;
  # - raster origin.
  
  geometry_matches <- terra::compareGeom(
    source,
    resistance,
    stopOnError = FALSE
  )
  
  if (!geometry_matches) {
    stop(
      "Source and resistance raster geometry do not match:\n",
      source_path,
      "\n",
      resistance_path
    )
  }
  
  
  # Obtain the minimum and maximum values without loading the complete
  # raster into an R vector.
  #
  # For a one-layer SpatRaster, terra::minmax() returns:
  #
  # row 1 = minimum
  # row 2 = maximum
  
  source_range <- terra::minmax(source)
  resistance_range <- terra::minmax(resistance)
  
  
  source_min <- source_range[1, 1]
  source_max <- source_range[2, 1]
  
  resistance_min <- resistance_range[1, 1]
  resistance_max <- resistance_range[2, 1]
  
  
  # Stop if the source raster has no finite values
  if (
    !is.finite(source_min) ||
    !is.finite(source_max)
  ) {
    stop(
      "Source raster contains no finite values:\n",
      source_path
    )
  }
  
  
  # Stop if the resistance raster has no finite values
  if (
    !is.finite(resistance_min) ||
    !is.finite(resistance_max)
  ) {
    stop(
      "Resistance raster contains no finite values:\n",
      resistance_path
    )
  }
  
  
  # Source values may equal zero outside suitable source habitat, but they
  # should not be negative.
  if (source_min < 0) {
    stop(
      "Source raster contains negative values:\n",
      source_path
    )
  }
  
  
  # The source raster must contain at least one positive source cell.
  #
  # A source raster containing only zeros would not produce a meaningful
  # current-flow model.
  
  if (source_max <= 0) {
    stop(
      "Source raster contains no positive source cells:\n",
      source_path
    )
  }
  
  
  # Omniscape resistance values must be greater than zero.
  #
  # A resistance value of zero would represent infinite conductance and can
  # cause numerical or conceptual problems.
  
  if (resistance_min <= 0) {
    stop(
      "Resistance raster contains values <= 0:\n",
      resistance_path
    )
  }
  
  
  # Confirm that source and resistance have the same NA pattern.
  #
  # This is not always strictly required by every workflow, but using a common
  # analysis domain prevents source cells from occurring where resistance is
  # undefined and vice versa.
  
  # Compare the NA pattern between the source and resistance rasters.
  
  
  source_na <- is.na(source)
  resistance_na <- is.na(resistance)
  
  different_na_pattern <- terra::global(
    source_na != resistance_na,
    fun = "sum",
    na.rm = TRUE
  )[1, 1]
  
  if (different_na_pattern > 0) {
    stop(
      "Source and resistance rasters have different NA patterns:\n",
      source_path,
      "\n",
      resistance_path,
      "\nDiffering cells: ",
      different_na_pattern
    )
  }
  
  
  # Return a concise validation record
  tibble(
    source_min = source_min,
    source_max = source_max,
    resistance_min = resistance_min,
    resistance_max = resistance_max,
    rows = terra::nrow(source),
    columns = terra::ncol(source),
    resolution_x = terra::res(source)[1],
    resolution_y = terra::res(source)[2],
    crs = terra::crs(source, proj = TRUE),
    na_pattern_matches = TRUE
  )
}


# Validate every source-resistance pair ------------------------------------

message(
  "Validating ",
  nrow(sensitivity_runs),
  " source-resistance raster pairs..."
)


input_validation <- sensitivity_runs |>
  mutate(
    validation = map2(
      source_path,
      resistance_path,
      validate_omniscape_inputs
    )
  ) |>
  unnest(validation)


# Summarize the validated inputs
validation_summary <- input_validation |>
  summarise(
    number_of_runs = n(),
    minimum_source = min(source_min),
    maximum_source = max(source_max),
    minimum_resistance = min(resistance_min),
    maximum_resistance = max(resistance_max),
    unique_row_counts = n_distinct(rows),
    unique_column_counts = n_distinct(columns),
    unique_x_resolutions = n_distinct(resolution_x),
    unique_y_resolutions = n_distinct(resolution_y),
    unique_coordinate_systems = n_distinct(crs)
  )

print(validation_summary)


# Different species may have different cropped extents or dimensions.
#
# That is acceptable as long as:
#
# 1. the source and resistance rasters match within each model;
# 2. all sensitivity outputs for a given species can later be aligned for
#    pairwise Spearman correlation.
#
# Ideally, all models should still share a consistent projection and
# resolution.

if (validation_summary$unique_coordinate_systems > 1) {
  warning(
    "More than one coordinate reference system was found among inputs."
  )
}

if (validation_summary$unique_x_resolutions > 1 ||
    validation_summary$unique_y_resolutions > 1) {
  warning(
    "More than one raster resolution was found among inputs."
  )
}


# Save input validation results
validation_path <- file.path(
  log_dir,
  "omniscape_input_validation.csv"
)

readr::write_csv(
  input_validation,
  validation_path
)


# Configure Conda and Julia ------------------------------------------------

# Conda must be added to the system PATH before starting the SyncroSim
# session.

Sys.setenv(
  PATH = paste(
    "C:/Users/terre/miniconda3",
    "C:/Users/terre/miniconda3/Scripts",
    "C:/Users/terre/miniconda3/Library/bin",
    Sys.getenv("PATH"),
    sep = ";"
  )
)


# Path to the Julia executable used by Omniscape
julia_path <- paste0(
  "C:/Users/terre/.julia/juliaup/",
  "julia-1.12.6+0.x64.w64.mingw32/bin/julia.exe"
)


# Locate Conda after updating PATH
conda_path <- Sys.which("conda")


# Stop if Conda cannot be found
if (!nzchar(conda_path)) {
  stop(
    "Conda could not be found. Check the Miniconda directories added to PATH."
  )
}


# Stop if the specified Julia executable does not exist
if (!file.exists(julia_path)) {
  stop(
    "Julia could not be found at:\n",
    julia_path
  )
}


# Print software versions for the analysis record
message("Conda version:")

system2(
  command = conda_path,
  args = "--version"
)


message("Julia version:")

system2(
  command = julia_path,
  args = "--version"
)


# Start the SyncroSim session ---------------------------------------------

ssim <- rsyncrosim::session()


# Display the SyncroSim packages available in the session
rsyncrosim::packages(ssim)


# Open or create the SyncroSim library using the Omniscape package
lib <- rsyncrosim::ssimLibrary(
  name = library_path,
  session = ssim,
  package = "omniscape"
)

print(lib)


# Configure Julia in SyncroSim --------------------------------------------

# Core SyncroSim Julia configuration
core_julia_config <- rsyncrosim::datasheet(
  lib,
  name = "core_JlConfig",
  empty = TRUE
)


# Create one configuration row
core_julia_config[1, ] <- NA


# Assign the Julia executable and disable separate Julia or VS Code windows
core_julia_config$ExePath <- julia_path
core_julia_config$RunInWindow <- FALSE
core_julia_config$ExePathVSCode <- NA
core_julia_config$UseVSCode <- FALSE


# Save the core Julia configuration
rsyncrosim::saveDatasheet(
  ssimObject = lib,
  data = core_julia_config,
  name = "core_JlConfig"
)


# Omniscape-specific Julia configuration
omniscape_julia_config <- rsyncrosim::datasheet(
  lib,
  name = "omniscape_juliaConfiguration",
  empty = TRUE
)


# Create one configuration row
omniscape_julia_config[1, ] <- NA


# Assign the same Julia executable
omniscape_julia_config$juliaPath <- julia_path


# Save the Omniscape-specific configuration
rsyncrosim::saveDatasheet(
  ssimObject = lib,
  data = omniscape_julia_config,
  name = "omniscape_juliaConfiguration"
)


# Confirm that the Julia paths were saved
print(
  rsyncrosim::datasheet(
    lib,
    name = "core_JlConfig"
  )
)

print(
  rsyncrosim::datasheet(
    lib,
    name = "omniscape_juliaConfiguration"
  )
)


# Open the SyncroSim project ----------------------------------------------

# This uses the project name that was previously used successfully in the
# test workflow.

proj <- rsyncrosim::project(
  ssimObject = lib,
  project = "Definitions"
)

print(proj)


# Fixed Omniscape settings -------------------------------------------------

# These settings remain constant among all resistance-layer sensitivity runs.
#
# Holding these values constant allows the sensitivity analysis to isolate
# differences caused by resistance-layer assumptions.
#
# Radius is measured in raster cells.
#
# IMPORTANT:
# radius = 5 is retained from the initial test workflow. Before publication,
# confirm that this value corresponds to the intended ecological movement
# distance at the raster resolution being used.

omniscape_settings <- list(
  radius = 5,
  calc_normalized_current = TRUE,
  calc_flow_potential = TRUE
)


# Function: configure one Omniscape scenario -------------------------------

configure_omniscape_scenario <- function(
    project,
    scenario_name,
    source_path,
    resistance_path,
    radius,
    calc_normalized_current = TRUE,
    calc_flow_potential = TRUE
) {
  
  # Open an existing named scenario or create it if it does not yet exist
  scn <- rsyncrosim::scenario(
    ssimObject = project,
    scenario = scenario_name
  )
  
  
  # Normalize Windows paths before saving them to SyncroSim.
  #
  # Forward slashes reduce problems caused by backslash escape characters.
  
  source_path_normalized <- normalizePath(
    source_path,
    winslash = "/",
    mustWork = TRUE
  )
  
  resistance_path_normalized <- normalizePath(
    resistance_path,
    winslash = "/",
    mustWork = TRUE
  )
  
  
  # Required Omniscape inputs ---------------------------------------------
  
  required_new <- data.frame(
    resistanceFile = resistance_path_normalized,
    radius = radius,
    sourceFile = source_path_normalized
  )
  
  
  rsyncrosim::saveDatasheet(
    ssimObject = scn,
    data = required_new,
    name = "omniscape_Required"
  )
  
  
  # General Omniscape options ---------------------------------------------
  
  # sourceFromResistance = FALSE:
  #   Use the separately supplied source raster.
  #
  # calcNormalizedCurrent = TRUE:
  #   Calculate normalized current in addition to cumulative current.
  #
  # calcFlowPotential = TRUE:
  #   Calculate flow-potential outputs.
  
  general_new <- data.frame(
    sourceFromResistance = FALSE,
    calcNormalizedCurrent = calc_normalized_current,
    calcFlowPotential = calc_flow_potential
  )
  
  
  rsyncrosim::saveDatasheet(
    ssimObject = scn,
    data = general_new,
    name = "omniscape_GeneralOptions"
  )
  
  
  # Define the SyncroSim pipeline -----------------------------------------
  
  # Read the existing pipeline template so that StageNameId uses the factor
  # levels expected by this SyncroSim installation.
  
  pipeline_template <- rsyncrosim::datasheet(
    scn,
    name = "core_Pipeline"
  )
  
  
  if (
    !"StageNameId" %in% names(pipeline_template) ||
    !"RunOrder" %in% names(pipeline_template)
  ) {
    stop(
      "The core_Pipeline datasheet does not contain the expected columns."
    )
  }
  
  
  stage_levels <- levels(
    pipeline_template$StageNameId
  )
  
  
  if (!"1 - Omniscape" %in% stage_levels) {
    stop(
      "'1 - Omniscape' was not found in the core_Pipeline StageNameId levels."
    )
  }
  
  
  pipeline_new <- data.frame(
    StageNameId = factor(
      "1 - Omniscape",
      levels = stage_levels
    ),
    RunOrder = 1
  )
  
  
  rsyncrosim::saveDatasheet(
    ssimObject = scn,
    data = pipeline_new,
    name = "core_Pipeline"
  )
  
  
  # Return the configured scenario object
  scn
}


# Function: inspect Omniscape output paths ---------------------------------

extract_omniscape_outputs <- function(
    ssim_object
) {
  
  # Try to read the spatial-output datasheet.
  #
  # If the output datasheet is unavailable, return NA values rather than
  # terminating the full batch.
  
  output_spatial <- tryCatch(
    rsyncrosim::datasheet(
      ssim_object,
      name = "omniscape_outputSpatial"
    ),
    error = function(e) {
      NULL
    }
  )
  
  
  if (
    is.null(output_spatial) ||
    nrow(output_spatial) == 0
  ) {
    return(
      tibble(
        cumulative_current_path = NA_character_,
        normalized_current_path = NA_character_,
        flow_potential_path = NA_character_,
        classified_resistance_path = NA_character_
      )
    )
  }
  
  
  # Helper for safely reading a possible column from the output datasheet
  get_output_column <- function(
    data,
    possible_names
  ) {
    
    matched_name <- intersect(
      possible_names,
      names(data)
    )
    
    if (length(matched_name) == 0) {
      return(NA_character_)
    }
    
    value <- data[[matched_name[1]]][1]
    
    if (
      length(value) == 0 ||
      is.na(value) ||
      !nzchar(as.character(value))
    ) {
      return(NA_character_)
    }
    
    as.character(value)
  }
  
  
  tibble(
    cumulative_current_path = get_output_column(
      output_spatial,
      c(
        "cumCurrmap",
        "cumCurrentMap",
        "cumulativeCurrent"
      )
    ),
    
    normalized_current_path = get_output_column(
      output_spatial,
      c(
        "normalizedCumCurrmap",
        "normalizedCurrentMap",
        "normalizedCurrent"
      )
    ),
    
    flow_potential_path = get_output_column(
      output_spatial,
      c(
        "flowPotential",
        "flowPotentialMap"
      )
    ),
    
    classified_resistance_path = get_output_column(
      output_spatial,
      c(
        "classifiedResistance",
        "classifiedResistanceMap"
      )
    )
  )
}


# Function: run one scenario safely ---------------------------------------

run_omniscape_scenario <- function(
    project,
    scenario_name,
    source_path,
    resistance_path,
    radius,
    calc_normalized_current = TRUE,
    calc_flow_potential = TRUE
) {
  
  start_time <- Sys.time()
  
  
  run_attempt <- tryCatch(
    {
      
      # Configure all required scenario datasheets
      scn <- configure_omniscape_scenario(
        project = project,
        scenario_name = scenario_name,
        source_path = source_path,
        resistance_path = resistance_path,
        radius = radius,
        calc_normalized_current = calc_normalized_current,
        calc_flow_potential = calc_flow_potential
      )
      
      
      # Run the configured scenario
      result <- rsyncrosim::run(
        scn,
        summary = FALSE
      )
      
      
      # First try to retrieve outputs from the returned result object
      output_paths <- extract_omniscape_outputs(
        result
      )
      
      
      # If the returned object does not expose the outputs, try the original
      # scenario object as a fallback.
      if (is.na(output_paths$cumulative_current_path[1])) {
        output_paths <- extract_omniscape_outputs(
          scn
        )
      }
      
      
      list(
        status = "success",
        error_message = NA_character_,
        output_paths = output_paths,
        result = result
      )
    },
    
    error = function(e) {
      
      list(
        status = "failed",
        error_message = conditionMessage(e),
        output_paths = tibble(
          cumulative_current_path = NA_character_,
          normalized_current_path = NA_character_,
          flow_potential_path = NA_character_,
          classified_resistance_path = NA_character_
        ),
        result = NULL
      )
    }
  )
  
  
  finish_time <- Sys.time()
  
  
  # Return one-row metadata and output tables plus the in-memory result object
  list(
    metadata = tibble(
      scenario_name = scenario_name,
      status = run_attempt$status,
      error_message = run_attempt$error_message,
      start_time = start_time,
      finish_time = finish_time,
      elapsed_minutes = as.numeric(
        difftime(
          finish_time,
          start_time,
          units = "mins"
        )
      )
    ),
    output_paths = run_attempt$output_paths,
    result = run_attempt$result
  )
}


# Prepare the initial run manifest ----------------------------------------

# Start with one row for every planned model
run_manifest <- sensitivity_runs |>
  mutate(
    radius = omniscape_settings$radius,
    status = "not_started",
    error_message = NA_character_,
    start_time = as.POSIXct(NA),
    finish_time = as.POSIXct(NA),
    elapsed_minutes = NA_real_,
    cumulative_current_path = NA_character_,
    normalized_current_path = NA_character_,
    flow_potential_path = NA_character_,
    classified_resistance_path = NA_character_
  )


# If a previous manifest exists, carry forward its run status and outputs.
#
# This allows the script to resume without rerunning successful models.

if (file.exists(manifest_path)) {
  
  previous_manifest <- readr::read_csv(
    manifest_path,
    show_col_types = FALSE
  )
  
  
  previous_columns <- c(
    "scenario_name",
    "status",
    "error_message",
    "start_time",
    "finish_time",
    "elapsed_minutes",
    "cumulative_current_path",
    "normalized_current_path",
    "flow_potential_path",
    "classified_resistance_path"
  )
  
  
  if (all(previous_columns %in% names(previous_manifest))) {
    
    previous_status <- previous_manifest |>
      select(
        all_of(previous_columns)
      )
    
    
    run_manifest <- run_manifest |>
      select(
        -all_of(
          setdiff(
            previous_columns,
            "scenario_name"
          )
        )
      ) |>
      left_join(
        previous_status,
        by = "scenario_name"
      )
    
    
    message(
      "Previous manifest loaded from:\n",
      manifest_path
    )
    
  } else {
    
    warning(
      "An existing manifest was found, but it did not contain all expected columns. ",
      "A new manifest will be used."
    )
  }
}


# Determine which models should be run ------------------------------------

if (run_test_only) {
  
  runs_to_execute <- run_manifest |>
    filter(
      species == test_species,
      variant == test_variant
    )
  
  if (nrow(runs_to_execute) != 1) {
    stop(
      "The test species and variant did not identify exactly one model."
    )
  }
  
  message(
    "TEST MODE: only ",
    runs_to_execute$scenario_name,
    " will be run."
  )
  
} else {
  
  runs_to_execute <- run_manifest
  
  if (skip_successful_runs) {
    
    runs_to_execute <- runs_to_execute |>
      filter(
        is.na(status) |
          status != "success"
      )
  }
  
  message(
    nrow(runs_to_execute),
    " model(s) are scheduled to run."
  )
}


# Stop if every requested model has already completed successfully
if (nrow(runs_to_execute) == 0) {
  message(
    "No models need to be run."
  )
}


# Run the selected Omniscape models ---------------------------------------

# Store in-memory SyncroSim result objects separately.
#
# These may be useful during the active session, but the CSV manifest and
# SyncroSim library remain the primary permanent records.

syncrosim_results <- vector(
  mode = "list",
  length = nrow(runs_to_execute)
)

names(syncrosim_results) <- runs_to_execute$scenario_name


if (nrow(runs_to_execute) > 0) {
  
  for (i in seq_len(nrow(runs_to_execute))) {
    
    current_run <- runs_to_execute[i, ]
    
    
    message(
      "\n------------------------------------------------------------\n",
      "Running model ",
      i,
      " of ",
      nrow(runs_to_execute),
      "\nScenario: ",
      current_run$scenario_name,
      "\nSpecies: ",
      current_run$species,
      "\nVariant: ",
      current_run$variant,
      "\n------------------------------------------------------------"
    )
    
    
    # Run one model and catch errors internally
    run_output <- run_omniscape_scenario(
      project = proj,
      scenario_name = current_run$scenario_name,
      source_path = current_run$source_path,
      resistance_path = current_run$resistance_path,
      radius = omniscape_settings$radius,
      calc_normalized_current =
        omniscape_settings$calc_normalized_current,
      calc_flow_potential =
        omniscape_settings$calc_flow_potential
    )
    
    
    # Retain the in-memory result object
    syncrosim_results[[current_run$scenario_name]] <-
      run_output$result
    
    
    # Combine run metadata and output paths
    completed_record <- bind_cols(
      run_output$metadata,
      run_output$output_paths
    )
    
    
    # Locate the corresponding row in the full manifest
    manifest_row <- match(
      current_run$scenario_name,
      run_manifest$scenario_name
    )
    
    
    if (is.na(manifest_row)) {
      stop(
        "Could not match the completed scenario to the run manifest: ",
        current_run$scenario_name
      )
    }
    
    
    # Update the full manifest with the completed model information
    run_manifest$status[manifest_row] <-
      completed_record$status
    
    run_manifest$error_message[manifest_row] <-
      completed_record$error_message
    
    run_manifest$start_time[manifest_row] <-
      completed_record$start_time
    
    run_manifest$finish_time[manifest_row] <-
      completed_record$finish_time
    
    run_manifest$elapsed_minutes[manifest_row] <-
      completed_record$elapsed_minutes
    
    run_manifest$cumulative_current_path[manifest_row] <-
      completed_record$cumulative_current_path
    
    run_manifest$normalized_current_path[manifest_row] <-
      completed_record$normalized_current_path
    
    run_manifest$flow_potential_path[manifest_row] <-
      completed_record$flow_potential_path
    
    run_manifest$classified_resistance_path[manifest_row] <-
      completed_record$classified_resistance_path
    
    
    # Save the CSV manifest after every model.
    #
    # If R, Julia, Omniscape, or the computer stops later, the completed-run
    # information up to this point is retained.
    
    readr::write_csv(
      run_manifest,
      manifest_path
    )
    
    
    # Save the current R run information after every model
    saveRDS(
      list(
        manifest = run_manifest,
        syncrosim_results = syncrosim_results
      ),
      results_rds_path
    )
    
    
    # Print the status of the completed run
    if (completed_record$status == "success") {
      
      message(
        "Completed successfully in ",
        round(
          completed_record$elapsed_minutes,
          2
        ),
        " minutes."
      )
      
      if (is.na(completed_record$cumulative_current_path)) {
        warning(
          "The model ran successfully, but the cumulative-current path ",
          "was not captured from omniscape_outputSpatial."
        )
      } else {
        message(
          "Cumulative-current output:\n",
          completed_record$cumulative_current_path
        )
      }
      
    } else {
      
      warning(
        "Model failed: ",
        current_run$scenario_name,
        "\n",
        completed_record$error_message
      )
    }
    
    
    # Remove temporary R objects and request garbage collection between runs
    rm(
      run_output,
      completed_record
    )
    
    invisible(
      gc()
    )
  }
}


# Final run summary --------------------------------------------------------

run_summary <- run_manifest |>
  count(
    status,
    name = "number_of_runs"
  ) |>
  arrange(status)

print(run_summary)


# Display failed runs
failed_runs <- run_manifest |>
  filter(status == "failed") |>
  select(
    species,
    variant,
    scenario_name,
    error_message
  )

if (nrow(failed_runs) > 0) {
  
  message(
    nrow(failed_runs),
    " model(s) failed."
  )
  
  print(
    failed_runs,
    n = Inf,
    width = Inf
  )
}


# Display successful runs lacking a captured cumulative-current path
missing_output_paths <- run_manifest |>
  filter(
    status == "success",
    is.na(cumulative_current_path) |
      !nzchar(cumulative_current_path)
  ) |>
  select(
    species,
    variant,
    scenario_name
  )

if (nrow(missing_output_paths) > 0) {
  
  warning(
    nrow(missing_output_paths),
    " successful model(s) do not have a recorded cumulative-current path. ",
    "Inspect omniscape_outputSpatial for these result scenarios."
  )
  
  print(
    missing_output_paths,
    n = Inf
  )
}


# Final save ---------------------------------------------------------------

readr::write_csv(
  run_manifest,
  manifest_path
)

saveRDS(
  list(
    manifest = run_manifest,
    syncrosim_results = syncrosim_results
  ),
  results_rds_path
)


message(
  "\nRun manifest saved to:\n",
  manifest_path
)

message(
  "\nComplete R results saved to:\n",
  results_rds_path
)


# Optional test-output inspection -----------------------------------------

# When run_test_only = TRUE and the test model succeeds, inspect its output.
#
# This section does not affect the model run. It simply checks whether the
# cumulative-current raster path was captured and whether the raster can be
# opened with terra.

if (run_test_only) {
  
  test_manifest_record <- run_manifest |>
    filter(
      species == test_species,
      variant == test_variant
    )
  
  
  if (
    nrow(test_manifest_record) == 1 &&
    test_manifest_record$status == "success"
  ) {
    
    message(
      "\nTest model completed successfully: ",
      test_manifest_record$scenario_name
    )
    
    
    if (
      !is.na(test_manifest_record$cumulative_current_path) &&
      nzchar(test_manifest_record$cumulative_current_path) &&
      file.exists(test_manifest_record$cumulative_current_path)
    ) {
      
      test_cumulative_current <- terra::rast(
        test_manifest_record$cumulative_current_path
      )
      
      
      print(test_cumulative_current)
      
      plot(
        test_cumulative_current,
        main = paste(
          "Cumulative current:",
          test_manifest_record$scenario_name
        )
      )
      
    } else {
      
      warning(
        "The test model succeeded, but the recorded cumulative-current ",
        "path is missing or does not exist."
      )
    }
  }
}