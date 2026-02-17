# Top ---------------------------------------------------------------------
# This is a script for producing thresholds of suitability based on 1st, 10th and 50th percentiles
# as low, moderate, and high suitability thresholds.
# Feb 11th 2026

# Libraries
library(tidyverse)
library(terra)


# Import occurrence data --------------------------------------------------
# Load occurrence data for main Vaccinium spp

# Main Vaccinium spp (use sp_codes1)
sp_codes1 <- c(
  "ang", "arb", "bor", "ces", "cor",
  "cra", "dar", "del", "ery", "gem",
  "hir", "mac", "mem", "mtu", "mys",
  "myr", "ova", "ovt", "oxy", "pal",
  "par", "sco", "sta", "ten", "uli",
  "vid", "sha"
)
# Corymbosum complex (use sp_codes2)
sp_codes2 <- c(
  "ash", "cae", "cor2", "cot", "ell",
  "for", "fus", "sim", "vir"
)

# Directories where thinned occurrence RDS live
occ_dir1 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/"
occ_dir2 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/corym_sub/"

# Build full file paths from species codes
occ_files1 <- file.path(occ_dir1, paste0("occ_", sp_codes1, "_thin.rds"))
occ_files2 <- file.path(occ_dir2, paste0("occ_", sp_codes2, "_thin.rds"))

names(occ_files1) <- sp_codes1
names(occ_files2) <- sp_codes2

# Helper: read + fail loudly with a helpful message
read_occ_rds <- function(path) {
  if (!file.exists(path)) stop("Missing occurrence file: ", path)
  readRDS(path)
}

# Load occurrence data as named lists (names = species codes)
occ_thin_list1 <- lapply(occ_files1, read_occ_rds)
occ_thin_list2 <- lapply(occ_files2, read_occ_rds)


# Create df of coordinates from occ pts -----------------------------------
occ_to_coords_df <- function(occ) {
  if (is.null(occ)) return(NULL)
  if (!inherits(occ, "SpatVector")) stop("Expected a terra SpatVector, got: ", class(occ)[1])
  
  as.data.frame(terra::geom(occ)[, 3:4, drop = FALSE])
}

# Lists of coordinate data frames (names preserved)
occ_coords_list1 <- lapply(occ_thin_list1, occ_to_coords_df)
occ_coords_list2 <- lapply(occ_thin_list2, occ_to_coords_df)

# Load suitability rasters for extracting qauntiles -----------------------
# make a file path to read each species as its code
pred_files1 <- file.path(
  "sdm_output", "sdm_output_feb_10_2026",
  sp_codes1,
  paste0(sp_codes1, "_pred_hist.rds")
)

pred_files2 <- file.path(
  "sdm_output", "sdm_output_feb_10_2026", "corym_sub",
  sp_codes2,
  paste0(sp_codes2, "_pred_hist.rds")
)

names(pred_files1) <- sp_codes1  # so I can keep track
names(pred_files2) <- sp_codes2  # so I can keep track

# Helper function for reading in rasters as RDS
read_pred_raster <- function(path) {
  obj <- readRDS(path)
  
  # If you saved the prediction directly as a SpatRaster
  if (inherits(obj, "SpatRaster")) {
    return(obj)
  }
  
  stop("Don't know how to extract a raster from: ", path)
}

# Load all Rasters using function
spp_hist_rasters1 <- lapply(pred_files1, read_pred_raster)
spp_hist_rasters2 <- lapply(pred_files2, read_pred_raster)

# Compute suitability thresholds for each spp -----------------------------
# This function take the historical suitability raster and the coordiantes from thinned occurrence points
calc_3_thresholds <- function(r, occ_coords) {
  
  if (is.null(r) || is.null(occ_coords)) return(NULL) # make sure those things exist...
  
  if (!inherits(r, "SpatRaster")) # check the the raster is a SpatRaster or naw
    stop("Expected SpatRaster, got: ", class(r)[1]) # tell me what it is if not SpatRaster
  
  vals <- terra::extract(r, occ_coords)[, 2]  # col 1 = ID, col 2 = raster values
  
  if (all(is.na(vals))) {
    return(c(low = NA_real_, mod = NA_real_, high = NA_real_)) # Catch NA values
  }
  
  c(
    low  = as.numeric(stats::quantile(vals, 0.01, na.rm = TRUE)),  # Low suitability
    mod  = as.numeric(stats::quantile(vals, 0.10, na.rm = TRUE)),  # Moderate suitability
    high = as.numeric(stats::quantile(vals, 0.50, na.rm = TRUE))   # High suitability
  )
}

# Function to help save rds files of thresholds for each spp
save_threshold <- function(sp, r, occ_coords, out_dir, suffix = "hist") { 

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE) # create directory

thr <- calc_3_thresholds(r, occ_coords)
if (is.null(thr)) return(invisible(NULL))

saveRDS(
  thr,
  file = file.path(out_dir, paste0(sp, "_thresholds_", suffix, ".rds"))
)

invisible(thr)
}

# Output directories
thresh_dir1 <- file.path("sdm_output", "sdm_output_feb_10_2026", "thresholds")
thresh_dir2 <- file.path("sdm_output", "sdm_output_feb_10_2026", "corym_sub", "thresholds")

# Save thresholds
# Main Vaccinium spp
for (sp in intersect(names(spp_hist_rasters1), names(occ_coords_list1))) {
  
  save_threshold(
    sp = sp,
    r = spp_hist_rasters1[[sp]],
    occ_coords = occ_coords_list1[[sp]],
    out_dir = thresh_dir1,
    suffix = "hist"
  )
}

# Corymbosum complex
for (sp in intersect(names(spp_hist_rasters2), names(occ_coords_list2))) {
  
  save_threshold(
    sp = sp,
    r = spp_hist_rasters2[[sp]],
    occ_coords = occ_coords_list2[[sp]],
    out_dir = thresh_dir2,
    suffix = "hist"
  )
}

