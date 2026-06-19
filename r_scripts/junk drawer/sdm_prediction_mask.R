# Top ---------------------------------------------------------------------
# This is a script to mask the SDM predictions to the ecoregions in which species occupy.
# For the historical projections the mask will be the ecoregion containing occurrence points, see vacc_bg_cec
# For the future predictions the mask will be the historical ecoregions, plus adjacent poleward ecoregions that contain suitability
# This avoids spurious predicted areas, for example sometimes suitable areas in the PNW are also suitable in Florida due to analogous
# climates. So will need to intersect the future suitability with the ecoregions and then select ones which are adajecnt some way...

# Terrell Roulston
# Feb 19th 2026

# Libraries
library(tidyverse)
library(terra)
library(geodata)


# Setup spp codes for loading downstream ----------------------------------
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


# DEBUGGING HELP
options(stringsAsFactors = FALSE)
terraOptions(progress = 1)

# Load CEC ecoregion data -------------------------------------------------
# Load ecoregion shape file from the CEC dataset
# Visit: https://www.epa.gov/eco-research/ecoregions-north-america
ecoNA <- vect(x = "maps/cec_eco/na_cec_eco_l2/NA_CEC_Eco_Level2.shp")
# gets reprojected below now
# ecoNA <- project(ecoNA, 'WGS84') # project ecoregion vector to same coords ref as basemap

# Load the spp historical ecoregions from bg script -----------------------
# First need to import the ecoregion shape files from the background script

eco_dir1 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_shp"
eco_dir2 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_shp/corym_sub"

# build species historical ecoregions file paths as inputs
eco_files1 <- file.path(
  eco_dir1,
  paste0("eco_occ_", sp_codes1, "_thin_vect.gpkg")
)
names(eco_files1) <- sp_codes1

eco_files2 <- file.path(
  eco_dir2,
  paste0("eco_occ_", sp_codes2, "_thin_vect.gpkg")
)
names(eco_files2) <- sp_codes2


# load ecoregion vectors
eco_vect_list1 <- lapply(eco_files1, function(f) {
  if (!file.exists(f)) {
    stop("Missing ecoregion file: ", f)
  }
  vect(f)
})

eco_vect_list2 <- lapply(eco_files2, function(f) {
  if (!file.exists(f)) {
    stop("Missing ecoregion file: ", f)
  }
  vect(f)
})

# Load predicted suitability rasters --------------------------------------
# Now need to load the SDM predicted suitability rasters for each species
# And intersect <ecoNA> with the rasters to extract what ecoregions contain suitability
# Then somehow filter out ecoregions that are not adjacent from historical ecoregions

# Settings
# ecoregion level 2 codes
id_col <- "NA_L2CODE"

# Setup the suffixs for each timeslice x SSP prediction
time_codes <- c(
  "hist",
  "ssp245_30", "ssp245_50", "ssp245_70",
  "ssp585_30", "ssp585_50", "ssp585_70"
)

# Where your per-species thresholds live (one RDS per species; contains low/mod/high)
thresh_dir1 <- file.path("sdm_output", "sdm_output_feb_10_2026", "thresholds")
thresh_dir2 <- file.path("sdm_output", "sdm_output_feb_10_2026", "corym_sub", "thresholds")

# Output dirs for masked rasters + mask polygons
out_masked1_rds <- file.path("sdm_output", "sdm_output_feb_10_2026", "masked_rds")
out_masked2_rds <- file.path("sdm_output", "sdm_output_feb_10_2026", "corym_sub", "masked_rds")
out_maskpoly1   <- file.path("sdm_output", "sdm_output_feb_10_2026", "masked_ecos")
out_maskpoly2   <- file.path("sdm_output", "sdm_output_feb_10_2026", "corym_sub", "masked_ecos")

dir.create(out_masked1_rds, recursive = TRUE, showWarnings = FALSE)
dir.create(out_masked2_rds, recursive = TRUE, showWarnings = FALSE)
dir.create(out_maskpoly1,   recursive = TRUE, showWarnings = FALSE)
dir.create(out_maskpoly2,   recursive = TRUE, showWarnings = FALSE)


# DEBUGGING
eco_hist_sp <- eco_vect_list1[[sp]]
peek(eco_hist_sp)

stopifnot(id_col %in% names(eco_hist_sp))
hist_ids <- unique(as.character(eco_hist_sp[[id_col]][,1]))
hist_ids <- hist_ids[!is.na(hist_ids)]
length(hist_ids)
head(hist_ids, 20)


# Helper functions for loading predictions and thresholds -----------------

# Load SDM prediction SpatRasters
read_pred_raster <- function(path) {
  if (!file.exists(path)) stop("Missing prediction file: ", path)
  obj <- readRDS(path)
  if (inherits(obj, "SpatRaster")) return(obj)
  stop("Don't know how to extract a raster from: ", path)
}

# Load suitability threshold
# Picking low suitability (1st percentile), as it contains the limits of moderate and high within
read_threshold_low <- function(thresholds_dir, sp) {
  f <- file.path(thresholds_dir, paste0(sp, "_thresholds_hist.rds"))
  if (!file.exists(f)) stop("Missing thresholds file: ", f)
  thr <- readRDS(f)
  as.numeric(thr[["low"]])
}

# Convert a raster into ecoregion polygons where max(r) >= thr
ecos_from_raster <- function(r, ecoNA, thr, id_col = "NA_L2CODE") {
  stopifnot(inherits(r, "SpatRaster"), inherits(ecoNA, "SpatVector"))
  if (!id_col %in% names(ecoNA)) stop("id_col not found in ecoNA: ", id_col)
  
  eco_use <- if (!terra::same.crs(r, ecoNA)) terra::project(ecoNA, terra::crs(r)) else ecoNA
  ids <- as.character(eco_use[[id_col]][,1])
  
  ex <- terra::extract(r, eco_use, fun = max, na.rm = TRUE)
  mx <- ex[[2]]
  
  keep_ids <- unique(ids[!is.na(mx) & mx >= thr])
  keep_ids <- keep_ids[!is.na(keep_ids) & nzchar(keep_ids) & keep_ids != "0.0"]
  
  eco_use[as.character(eco_use[[id_col]][,1]) %in% keep_ids, ]
}

# Keep only FUTURE suitable patches that are continuously connected (via suitable cells)
# to the HISTORICAL suitable "seed" (historical suitability >= thr) within historical ecoregions.
keep_future_connected_to_hist_suit <- function(r_hist, r_future, thr, eco_hist_sp,
                                               directions = 8) {
  stopifnot(inherits(r_hist, "SpatRaster"),
            inherits(r_future, "SpatRaster"),
            inherits(eco_hist_sp, "SpatVector"))
  
  # Work in future CRS
  if (!terra::same.crs(r_hist, r_future)) r_hist <- terra::project(r_hist, terra::crs(r_future))
  eco_use <- if (terra::same.crs(eco_hist_sp, r_future)) eco_hist_sp else terra::project(eco_hist_sp, terra::crs(r_future))
  
  # Historical seed: (hist >= thr) masked to historical ecoregions
  hist_bin <- r_hist >= thr
  hist_bin[is.na(r_hist)] <- NA
  hist_seed <- terra::mask(hist_bin, eco_use)  # TRUE/NA
  
  # Future suitable + label contiguous patches
  fut_bin <- r_future >= thr
  fut_bin[is.na(r_future)] <- NA
  fut_lab <- terra::patches(fut_bin, directions = directions)
  
  # Which future patch IDs overlap the historical seed?
  lab_vals  <- terra::values(fut_lab,  mat = FALSE)
  seed_vals <- terra::values(hist_seed, mat = FALSE)
  
  seed_patch_ids <- unique(lab_vals[!is.na(seed_vals) & seed_vals == 1])
  seed_patch_ids <- seed_patch_ids[!is.na(seed_patch_ids)]
  
  if (length(seed_patch_ids) == 0) {
    r_keep <- r_future
    r_keep[] <- NA
    return(list(r_keep = r_keep, kept_patch_ids = integer(0)))
  }
  
  keep_mask <- fut_lab %in% seed_patch_ids
  r_keep <- terra::mask(r_future, keep_mask, maskvalues = 0)
  
  list(r_keep = r_keep, kept_patch_ids = seed_patch_ids)
}


# Build file-path index for predictions (paths only, NO heavy loading)
pred_files1 <- setNames(lapply(time_codes, function(tc) {
  paths <- file.path("sdm_output", "sdm_output_feb_10_2026",
                     sp_codes1,
                     paste0(sp_codes1, "_pred_", tc, ".rds"))
  names(paths) <- sp_codes1
  paths
}), time_codes)

pred_files2 <- setNames(lapply(time_codes, function(tc) {
  paths <- file.path("sdm_output", "sdm_output_feb_10_2026", "corym_sub",
                     sp_codes2,
                     paste0(sp_codes2, "_pred_", tc, ".rds"))
  names(paths) <- sp_codes2
  paths
}), time_codes)

# Loading all rasters at once is really really memory intensive (252 total rasters) so...
# Mask + save (process one raster at a time = memory safe)
# Inputs: sp code, prediction timeslice, path to predition, historical ecoregion for sp,
# path to threshold, path to output rds dir, path to output vector dir,
# ecoregion vector file, adjaceny matrix (candidate only)
# ecoregion ID level, and drop code (water)

mask_and_save_one <- function(sp, time, pred_path, hist_pred_path, eco_hist_sp,
                              thresholds_dir, out_rds_dir, out_poly_dir,
                              ecoNA, id_col = "NA_L2CODE") {
  
  r <- read_pred_raster(pred_path)
  
  if (time == "hist") {
    eco_mask <- eco_hist_sp
    eco_ids <- as.character(eco_mask[[id_col]][,1])
    eco_mask <- eco_mask[!is.na(eco_ids) & nzchar(eco_ids) & eco_ids != "0.0", ]
  } else {
    thr <- read_threshold_low(thresholds_dir, sp)
    
    # Load historical raster too (seed)
    r_hist <- read_pred_raster(hist_pred_path)
    
    pruned <- keep_future_connected_to_hist_suit(
      r_hist      = r_hist,
      r_future    = r,
      thr         = thr,
      eco_hist_sp = eco_hist_sp,
      directions  = 8
    )
    
    # Fallback: if no connected future patch overlaps the historical seed,
    # use historical ecoregions only (conservative)
    if (length(pruned$kept_patch_ids) == 0) {
      eco_mask <- eco_hist_sp
    } else {
      # Turn pruned raster footprint into ecoregion polygon mask
      eco_mask <- ecos_from_raster(
        r      = pruned$r_keep,
        ecoNA  = ecoNA,
        thr    = thr,
        id_col = id_col
      )
    }
    
    rm(r_hist, pruned)
  }
  
  # Make CRS-safe
  eco_mask_use <- if (terra::same.crs(r, eco_mask)) eco_mask else terra::project(eco_mask, terra::crs(r))
  
  r_masked <- terra::mask(r, eco_mask_use)
  
  dir.create(out_rds_dir, recursive = TRUE, showWarnings = FALSE)
  saveRDS(r_masked, file.path(out_rds_dir, paste0(sp, "_pred_", time, "_masked.rds")))
  
  dir.create(out_poly_dir, recursive = TRUE, showWarnings = FALSE)
  terra::writeVector(
    eco_mask_use,
    file.path(out_poly_dir, paste0(sp, "_eco_mask_", time, ".gpkg")),
    overwrite = TRUE
  )
  
  rm(r, r_masked, eco_mask, eco_mask_use)
  gc()
  invisible(TRUE)
}


# Run ecoregion search and mask -------------------------------------------
# ---- Run for main spp
for (sp in sp_codes1) {
  eco_hist_sp <- eco_vect_list1[[sp]]
  if (is.null(eco_hist_sp)) stop("Missing historical ecoregion vector for species: ", sp)
  
  hist_path <- pred_files1[["hist"]][[sp]]
  
  for (time in time_codes) {
    mask_and_save_one(
      sp = sp,
      time = time,
      pred_path = pred_files1[[time]][[sp]],
      hist_pred_path = hist_path,
      eco_hist_sp = eco_hist_sp,
      thresholds_dir = thresh_dir1,
      out_rds_dir = out_masked1_rds,
      out_poly_dir = out_maskpoly1,
      ecoNA = ecoNA,
      id_col = id_col
    )
  }
}

# ---- Run for corym complex
for (sp in sp_codes2) {
  eco_hist_sp <- eco_vect_list2[[sp]]
  if (is.null(eco_hist_sp)) stop("Missing historical ecoregion vector for species: ", sp)
  
  hist_path <- pred_files2[["hist"]][[sp]]
  
  for (time in time_codes) {
    mask_and_save_one(
      sp = sp,
      time = time,
      pred_path = pred_files2[[time]][[sp]],
      hist_pred_path = hist_path,
      eco_hist_sp = eco_hist_sp,
      thresholds_dir = thresh_dir2,
      out_rds_dir = out_masked2_rds,
      out_poly_dir = out_maskpoly2,
      ecoNA = ecoNA,
      id_col = id_col
    )
  }
}
