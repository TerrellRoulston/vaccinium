##############################################################
# Omniscape resistance sensitivity analysis ##################
##############################################################
#
# Terrell Roulston
#
# This script performs a one-at-a-time sensitivity analysis of
# the resistance-layer assumptions used in the main Omniscape
# input-preparation workflow (see resistance_prep.R).
#
# The source layer is held constant among sensitivity variants:
#
#   - Historical suitability is always used.
#   - Historical suitability is retained as source strength where
#     it is greater than or equal to the species-specific historical
#     moderate threshold.
#   - Source strength is zero elsewhere.
#
# Resistance-model parameters are calibrated using the historical
# resistance surface because the objective is to evaluate uncertainty
# in the resistance model itself, not its interaction with future
# climate change.
#
# The resistance layer is varied by changing:
#
#   1. The exponent controlling the suitability-resistance curve.
#   2. The relative weights assigned to suitability and land cover.
#   3. The protected-area resistance multiplier.
#   4. Whether protected areas modify full land-cover barriers.
#
# The baseline model matches the main workflow:
#
#   suitability resistance = 10^(3 * (1 - suitability))
#
#   base resistance =
#     0.50 * suitability resistance +
#     0.50 * land-cover resistance
#
#   protected cells:
#     resistance multiplied by 0.75
#
#   cells with land-cover resistance = 1000:
#     not modified by protected-area status
#
# The analysis uses a one-at-a-time flow. Each alternative
# model differs from the baseline in only one assumption. 
#

# Libraries ---------------------------------------------------------------

library(tidyverse)
library(terra)


# Main-workflow requirements ---------------------------------------------
#
# Run the main preparation script before running this script.
#
# The following objects and functions must already exist:
#
#   spp_codes
#   all_preds
#   all_thresholds
#   land_resistance_coarse
#   pa_binary_template
#   input_dir
#   align_continuous()
#   align_binary()
#
# Alternatively, source the main workflow here, provided the source file
#
# source("r_scripts/resistance_prep.R")


# Confirm that required objects and functions exist -----------------------

required_objects <- c(
  "spp_codes",
  "scenario_keys",
  "all_preds",
  "all_thresholds",
  "land_resistance_coarse",
  "pa_binary_template",
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
    "The following required objects are missing: ",
    paste(
      missing_objects,
      collapse = ", "
    ),
    ". Run the main Omniscape preparation workflow first."
  )
}


required_functions <- c(
  "align_continuous",
  "align_binary"
)

missing_functions <- required_functions[
  !vapply(
    required_functions,
    exists,
    logical(1),
    mode = "function",
    inherits = TRUE
  )
]

if (length(missing_functions) > 0) {
  stop(
    "The following required functions are missing: ",
    paste(
      missing_functions,
      collapse = ", "
    ),
    ". Run the main Omniscape preparation workflow first."
  )
}


# User settings -----------------------------------------------------------

# Species included in the sensitivity analysis.


sensitivity_spp_codes <- spp_codes


# Climate scenarios included in the sensitivity analysis.

sensitivity_scenario_keys <- c("hist")


# Output directory for sensitivity-analysis inputs

sensitivity_output_dir <- file.path(
  input_dir,
  "sensitivity_analysis"
)

dir.create(
  sensitivity_output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# Sensitivity-analysis design ---------------------------------------------
#
# Baseline:
#
#   suitability exponent = 3
#   suitability weight   = 0.50
#   land-cover weight    = 0.50
#   PA multiplier        = 0.75
#   full barriers reduced by PA status = FALSE
#
# Each alternative changes only one baseline assumption.
#
# The suitability exponent controls the steepness of the transformation:
#
#   exponent = 2:
#     shallower contrast between high and low suitability
#
#   exponent = 3:
#     baseline transformation from 1 to 1000
#
#   exponent = 4:
#     stronger penalty for lower suitability
#
# The component weights must sum to 1.
#
# A PA multiplier of 1 means protected areas have no effect.
#
# A PA multiplier of 0.50 gives protected cells a 50% reduction
# in resistance.
#
# When reduce_full_barriers = TRUE, protected-area status may reduce
# resistance even where land-cover resistance equals 1000.

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


# Validate the sensitivity parameter table --------------------------------

if (anyDuplicated(sensitivity_parameters$variant)) {
  stop(
    "Every sensitivity variant must have a unique name."
  )
}


if (
  any(sensitivity_parameters$suitability_exponent <= 0) ||
  anyNA(sensitivity_parameters$suitability_exponent)
) {
  stop(
    "All suitability exponents must be positive and non-missing."
  )
}


if (
  any(sensitivity_parameters$suitability_weight < 0) ||
  any(sensitivity_parameters$land_weight < 0) ||
  anyNA(sensitivity_parameters$suitability_weight) ||
  anyNA(sensitivity_parameters$land_weight)
) {
  stop(
    "Suitability and land-cover weights must be non-negative."
  )
}


weight_sums <- (
  sensitivity_parameters$suitability_weight +
    sensitivity_parameters$land_weight
)

if (any(abs(weight_sums - 1) > 1e-10)) {
  stop(
    "Suitability and land-cover weights must sum to 1 for every variant."
  )
}


if (
  any(sensitivity_parameters$pa_multiplier <= 0) ||
  any(sensitivity_parameters$pa_multiplier > 1) ||
  anyNA(sensitivity_parameters$pa_multiplier)
) {
  stop(
    "Protected-area multipliers must be greater than 0 and no greater than 1."
  )
}


# Export the parameter table so every output can be traced back
# to the assumptions used to create it.

write_csv(
  sensitivity_parameters,
  file.path(
    sensitivity_output_dir,
    "sensitivity_parameter_table.csv"
  )
)


# Suitability-resistance function -----------------------------------------

# Convert continuous cloglog suitability to continuous resistance.
#
# The exponent determines the maximum resistance:
#
#   exponent = 2:
#     suitability 0 -> resistance 100
#
#   exponent = 3:
#     suitability 0 -> resistance 1000
#
#   exponent = 4:
#     suitability 0 -> resistance 10000
#
# Resistance is later bounded to the range used by the selected model.
#
# IMPORTANT:
#
# Masked suitability cells within the valid land-cover domain are converted
# to suitability zero before this function is called. They therefore receive
# the maximum suitability resistance rather than remaining NA.

suitability_to_resistance_sensitivity <- function(
    suitability,
    suitability_exponent
) {
  
  if (
    length(suitability_exponent) != 1 ||
    is.na(suitability_exponent) ||
    suitability_exponent <= 0
  ) {
    stop(
      "suitability_exponent must be one positive, non-missing value."
    )
  }
  
  suitability <- clamp(
    suitability,
    lower = 0,
    upper = 1
  )
  
  resistance <- 10^(
    suitability_exponent *
      (1 - suitability)
  )
  
  names(resistance) <- "suitability_resistance"
  
  resistance
}


# Sensitivity resistance-layer function -----------------------------------

make_omniscape_sensitivity_layers <- function(
    source_suitability,
    resistance_suitability,
    land_resistance,
    protected_binary,
    source_threshold,
    suitability_exponent,
    suitability_weight,
    land_weight,
    pa_multiplier,
    reduce_full_barriers
) {
  
  if (
    is.null(source_suitability) ||
    is.null(resistance_suitability)
  ) {
    return(NULL)
  }
  
  
  # Validate source threshold.
  
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
  
  
  # Validate suitability exponent.
  
  if (
    length(suitability_exponent) != 1 ||
    is.na(suitability_exponent) ||
    suitability_exponent <= 0
  ) {
    stop(
      "suitability_exponent must be one positive, non-missing value."
    )
  }
  
  
  # Validate component weights.
  
  if (
    length(suitability_weight) != 1 ||
    length(land_weight) != 1 ||
    is.na(suitability_weight) ||
    is.na(land_weight) ||
    suitability_weight < 0 ||
    land_weight < 0 ||
    abs(
      suitability_weight +
      land_weight -
      1
    ) > 1e-10
  ) {
    stop(
      "Suitability and land-cover weights must be non-negative and sum to 1."
    )
  }
  
  
  # Validate protected-area multiplier.
  
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
  
  
  # Use the first raster layer if an input contains multiple layers.
  
  source_suitability <- source_suitability[[1]]
  resistance_suitability <- resistance_suitability[[1]]
  land_resistance <- land_resistance[[1]]
  protected_binary <- protected_binary[[1]]
  
  
  # Bound suitability to the valid cloglog range.
  
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
  
  
  # -----------------------------------------------------------------------
  # Complete North American analysis template
  # -----------------------------------------------------------------------
  
  # The complete coarse-resolution land-cover resistance raster defines
  # the spatial extent, resolution, origin, CRS, and valid land domain
  # used by all Omniscape input layers.
  #
  # Species-specific suitability masks must not define or crop the
  # connectivity-analysis domain.
  
  analysis_template <- land_resistance
  
  
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
  
  
  # Land-cover resistance already defines the complete analysis grid.
  
  land_aligned <- analysis_template
  
  
  # Align protected areas to the complete North American template.
  
  pa_aligned <- align_binary(
    protected_binary,
    analysis_template
  )
  
  
  # Confirm that all aligned rasters have identical geometry.
  
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
    land_aligned,
    stopOnError = TRUE
  )
  
  compareGeom(
    analysis_template,
    pa_aligned,
    stopOnError = TRUE
  )
  
  # -----------------------------------------------------------------------
  # Valid analysis domain
  # -----------------------------------------------------------------------
  
  # Land-cover data define the valid North American analysis domain.
  #
  # Suitability rasters may have narrower ecological masks. Within the
  # valid land-cover domain, masked suitability cells are assigned zero.
  # They therefore receive maximum suitability resistance rather than
  # becoming absent cells in the final resistance raster.
  
  valid_domain <- !is.na(land_aligned)
  
  
  # Historical suitability may have a smaller mask than future suitability.
  # Assign zero source strength in valid-domain cells that were outside the
  # historical suitability mask.
  
  source_suitability <- ifel(
    valid_domain & is.na(source_suitability),
    0,
    source_suitability
  )
  
  
  # Preserve NA outside the valid land-cover domain.
  
  source_suitability <- ifel(
    valid_domain,
    source_suitability,
    NA
  )
  
  
  # Assign zero suitability to masked resistance-suitability cells within
  # the valid land-cover domain. These cells will receive maximum climate
  # resistance.
  
  resistance_suitability <- ifel(
    valid_domain & is.na(resistance_suitability),
    0,
    resistance_suitability
  )
  
  
  # Preserve NA outside the valid land-cover domain.
  
  resistance_suitability <- ifel(
    valid_domain,
    resistance_suitability,
    NA
  )
  
  land_aligned <- ifel(
    valid_domain,
    land_aligned,
    NA
  )
  
  pa_aligned <- ifel(
    valid_domain,
    pa_aligned,
    NA
  )
  
  
  # -----------------------------------------------------------------------
  # Fixed historical source
  # -----------------------------------------------------------------------
  
  # Source strength is always based on historical suitability and the
  # species-specific historical moderate threshold.
  
  source <- ifel(
    source_suitability >= source_threshold,
    source_suitability,
    0
  )
  
  source <- mask(
    source,
    land_aligned
  )
  
  names(source) <- "source_strength"
  
  
  # -----------------------------------------------------------------------
  # Scenario-specific suitability resistance
  # -----------------------------------------------------------------------
  
  suitability_resistance <-
    suitability_to_resistance_sensitivity(
      suitability = resistance_suitability,
      suitability_exponent = suitability_exponent
    )
  
  
  # -----------------------------------------------------------------------
  # Weighted combination of suitability and land-cover resistance
  # -----------------------------------------------------------------------
  
  # The baseline gives equal weight to both components:
  #
  #   0.50 * suitability resistance +
  #   0.50 * land-cover resistance
  #
  # Sensitivity variants change these weights while keeping their sum at 1.
  
  base_resistance <- (
    suitability_weight *
      suitability_resistance
  ) + (
    land_weight *
      land_aligned
  )
  
  names(base_resistance) <- "base_resistance"
  
  
  # -----------------------------------------------------------------------
  # Protected-area modifier
  # -----------------------------------------------------------------------
  
  if (reduce_full_barriers) {
    
    # All protected cells are eligible for the PA multiplier.
    
    pa_eligible <- pa_aligned == 1
    
  } else {
    
    # Protected status does not modify cells whose land-cover
    # resistance equals 1000.
    
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
  
  
  # Omniscape requires positive resistance.
  #
  # The upper resistance limit is determined by the larger maximum of:
  #
  #   - the land-cover scale, which reaches 1000; and
  #   - the selected suitability-resistance scale, which reaches
  #     10^suitability_exponent.
  #
  # This allows the steep-suitability sensitivity model to retain
  # resistance values above 1000 rather than truncating them.
  
  maximum_resistance <- max(
    1000,
    10^suitability_exponent
  )
  
  
  final_resistance <- clamp(
    final_resistance,
    lower = 1,
    upper = maximum_resistance
  )
  
  final_resistance <- mask(
    final_resistance,
    land_aligned
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


# Run the sensitivity analysis --------------------------------------------

# Create a list to retain the generated layers in the current R session.


sensitivity_layers <- setNames(
  vector(
    mode = "list",
    length = nrow(sensitivity_parameters)
  ),
  sensitivity_parameters$variant
)


# Create an empty list for summary records.

sensitivity_summary_records <- list()

summary_index <- 1L


for (variant_index in seq_len(
  nrow(sensitivity_parameters)
)) {
  
  parameters <- sensitivity_parameters[
    variant_index,
  ]
  
  variant <- parameters$variant
  
  message(
    "\nSensitivity variant: ",
    variant
  )
  
  message(
    "  ",
    parameters$description
  )
  
  
  # Create a directory for this sensitivity variant.
  
  variant_output_dir <- file.path(
    sensitivity_output_dir,
    variant
  )
  
  dir.create(
    variant_output_dir,
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  
  # Initialize species-level storage.
  
  sensitivity_layers[[variant]] <- setNames(
    vector(
      mode = "list",
      length = length(sensitivity_spp_codes)
    ),
    sensitivity_spp_codes
  )
  
  
  for (sp in sensitivity_spp_codes) {
    
    message(
      "  Species: ",
      sp
    )
    
    
    species_preds <- all_preds[[sp]]
    
    if (is.null(species_preds)) {
      warning(
        "No predictions found for species: ",
        sp
      )
      next
    }
    
    
    historical_suitability <-
      species_preds[["hist"]]
    
    if (is.null(historical_suitability)) {
      warning(
        "Historical suitability is missing for species: ",
        sp
      )
      next
    }
    
    
    species_thresholds <-
      all_thresholds[[sp]]
    
    if (is.null(species_thresholds)) {
      warning(
        "Thresholds are missing for species: ",
        sp
      )
      next
    }
    
    
    moderate_threshold <- unname(
      species_thresholds[["mod"]]
    )
    
    
    species_output_dir <- file.path(
      variant_output_dir,
      sp
    )
    
    dir.create(
      species_output_dir,
      recursive = TRUE,
      showWarnings = FALSE
    )
    
    
    sensitivity_layers[[variant]][[sp]] <-
      setNames(
        vector(
          mode = "list",
          length = length(
            sensitivity_scenario_keys
          )
        ),
        sensitivity_scenario_keys
      )
    
    
    for (scenario in sensitivity_scenario_keys) {
      
      message(
        "    Scenario: ",
        scenario
      )
      
      
      scenario_suitability <-
        species_preds[[scenario]]
      
      
      if (is.null(scenario_suitability)) {
        warning(
          "Skipping missing prediction: ",
          sp,
          " / ",
          scenario
        )
        next
      }
      
      
      layers <-
        make_omniscape_sensitivity_layers(
          source_suitability =
            historical_suitability,
          
          resistance_suitability =
            scenario_suitability,
          
          land_resistance =
            land_resistance_coarse,
          
          protected_binary =
            pa_binary_template,
          
          source_threshold =
            moderate_threshold,
          
          suitability_exponent =
            parameters$suitability_exponent,
          
          suitability_weight =
            parameters$suitability_weight,
          
          land_weight =
            parameters$land_weight,
          
          pa_multiplier =
            parameters$pa_multiplier,
          
          reduce_full_barriers =
            parameters$reduce_full_barriers
        )
      
      
      if (is.null(layers)) {
        next
      }
      
      
      sensitivity_layers[[variant]][[sp]][[scenario]] <-
        layers
      
      
      # -------------------------------------------------------------------
      # Validate generated layers
      # -------------------------------------------------------------------
      
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
        c("min", "mean", "max"),
        na.rm = TRUE
      )
      
      
      n_source_cells <- global(
        layers$source > 0,
        "sum",
        na.rm = TRUE
      )[1, 1]
      
      
      n_resistance_cells <- global(
        !is.na(layers$resistance),
        "sum",
        na.rm = TRUE
      )[1, 1]
      
      
      if (
        source_minmax[1, "min"] < 0 ||
        source_minmax[1, "max"] > 1
      ) {
        stop(
          "Invalid source values for ",
          variant,
          " / ",
          sp,
          " / ",
          scenario
        )
      }
      
      
      if (
        is.na(n_source_cells) ||
        n_source_cells == 0
      ) {
        stop(
          "No source cells were produced for ",
          variant,
          " / ",
          sp,
          " / ",
          scenario
        )
      }
      
      
      if (
        is.na(n_resistance_cells) ||
        n_resistance_cells == 0
      ) {
        stop(
          "No resistance cells were produced for ",
          variant,
          " / ",
          sp,
          " / ",
          scenario
        )
      }
      
      
      # -------------------------------------------------------------------
      # Export Omniscape input rasters
      # -------------------------------------------------------------------
      
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
      
      
      writeRaster(
        layers$source,
        source_path,
        overwrite = TRUE,
        datatype = "FLT4S",
        NAflag = 9999, # set NA flag as positive number of Omniscape fails
        gdal = c(
          "COMPRESS=LZW"
        )
      )
      
      
      writeRaster(
        layers$resistance,
        resistance_path,
        overwrite = TRUE,
        datatype = "FLT4S",
        NAflag = 9999, # set NA flag as positive number of Omniscape fails
        gdal = c(
          "COMPRESS=LZW"
        )
      )
      
      
      # -------------------------------------------------------------------
      # Save summary information
      # -------------------------------------------------------------------
      
      sensitivity_summary_records[[
        summary_index
      ]] <- tibble(
        variant = variant,
        description = parameters$description,
        species = sp,
        scenario = scenario,
        moderate_source_threshold =
          moderate_threshold,
        suitability_exponent =
          parameters$suitability_exponent,
        suitability_weight =
          parameters$suitability_weight,
        land_weight =
          parameters$land_weight,
        pa_multiplier =
          parameters$pa_multiplier,
        reduce_full_barriers =
          parameters$reduce_full_barriers,
        n_source_cells =
          n_source_cells,
        n_resistance_cells =
          n_resistance_cells,
        minimum_resistance =
          resistance_minmax[1, "min"],
        mean_resistance =
          resistance_minmax[1, "mean"],
        maximum_resistance =
          resistance_minmax[1, "max"],
        source_path =
          source_path,
        resistance_path =
          resistance_path
      )
      
      
      summary_index <- summary_index + 1L
    }
  }
}


# Combine and export the sensitivity summary ------------------------------

sensitivity_summary <- bind_rows(
  sensitivity_summary_records
)


sensitivity_summary_path <- file.path(
  sensitivity_output_dir,
  "sensitivity_input_summary.csv"
)


write_csv(
  sensitivity_summary,
  sensitivity_summary_path
)


message(
  "\nSensitivity analysis complete."
)

message(
  "Parameter table: ",
  file.path(
    sensitivity_output_dir,
    "sensitivity_parameter_table.csv"
  )
)

message(
  "Input summary: ",
  sensitivity_summary_path
)

message(
  "Raster directory: ",
  sensitivity_output_dir
)