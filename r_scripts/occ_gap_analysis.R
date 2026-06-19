# Top ---------------------------------------------------------------------
# This script is for doing a in situ conservation gap analysis for occurrence overlap with protected suitable areas 
# under climate change
# Inputs: Masked suitability rasters, species occurrence data, protected area dataset

# Protected area data from the WDPA
# This is more straight forward then getting the data from the Canadian and US databases
# And allows for easier filtering of Marine PAs

# NOTE: I expand into Mexico bc there is a handful of species that are also located in MX

library(tidyverse)
library(terra)
library(wdpar)


# Protected area prep -----------------------------------------------------
# RUN THIS ONE TIME

# create dir to hold shape files
#dir.create('./maps/wdpa_prot_area', showWarnings = FALSE)

# Fetch WDPA Data
# # Canada
# wdpa_fetch("Canada", download_dir = "./maps/wdpa_prot_area/", wait = TRUE, page_wait = 10, datatype = 'shp')
# # US
# wdpa_fetch("United States of America", download_dir = "./maps/wdpa_prot_area/", wait = TRUE, page_wait = 10, datatype = 'shp')
# # Mexico
# wdpa_fetch("Mexico", download_dir = "./maps/wdpa_prot_area/", wait = TRUE, page_wait = 10, datatype = 'shp')

# Unzip folders and load to combine and filter
# Load and combine Canadian WDPA shapefiles
# ca1 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_CAN-shapefile/WDPA_WDOECM_Feb2026_Public_CAN_shp_0/WDPA_WDOECM_Feb2026_Public_CAN_shp-polygons.shp")
# ca2 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_CAN-shapefile/WDPA_WDOECM_Feb2026_Public_CAN_shp_1/WDPA_WDOECM_Feb2026_Public_CAN_shp-polygons.shp")
# ca3 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_CAN-shapefile/WDPA_WDOECM_Feb2026_Public_CAN_shp_2/WDPA_WDOECM_Feb2026_Public_CAN_shp-polygons.shp")
# ca_all <- rbind(ca1, ca2, ca3)
# ca_all_filt <- ca_all[ca_all$REALM %in% c("Terrestrial"), ] # filter only terrestrial parks
# 
# # Lots of memory clean enviro
# rm(list = c('ca1', 'ca2', 'ca3', 'ca_all'))
# gc()
# 
# # Load and filter US WDPA shapefile
# us1 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_USA-shapefile/WDPA_WDOECM_Feb2026_Public_USA_shp_0/WDPA_WDOECM_Feb2026_Public_USA_shp-polygons.shp")
# us2 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_USA-shapefile/WDPA_WDOECM_Feb2026_Public_USA_shp_1/WDPA_WDOECM_Feb2026_Public_USA_shp-polygons.shp")
# us3 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_USA-shapefile/WDPA_WDOECM_Feb2026_Public_USA_shp_2/WDPA_WDOECM_Feb2026_Public_USA_shp-polygons.shp")
# us_all <- rbind(us1, us2, us3)
# us_all_filt <- us_all[us_all$REALM %in% c("Terrestrial"), ]
# 
# # Lots of memory clean enviro
# rm(list = c('us1', 'us2', 'us3', 'us_all'))
# gc()
# 
# # Load and filter Mexico WDPA shapefile
# mx1 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_MEX-shapefile/WDPA_WDOECM_Feb2026_Public_MEX_shp_0/WDPA_WDOECM_Feb2026_Public_MEX_shp-polygons.shp")
# mx2 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_MEX-shapefile/WDPA_WDOECM_Feb2026_Public_MEX_shp_1/WDPA_WDOECM_Feb2026_Public_MEX_shp-polygons.shp")
# mx3 <- vect("./maps/wdpa_prot_area/WDPA_Feb2026_MEX-shapefile/WDPA_WDOECM_Feb2026_Public_MEX_shp_2/WDPA_WDOECM_Feb2026_Public_MEX_shp-polygons.shp")
# mx_all <- rbind(mx1, mx2, mx3)
# mx_all_filt <- mx_all[mx_all$REALM %in% c("Terrestrial"), ]
# 
# # Lots of memory clean enviro
# rm(list = c('mx1', 'mx2', 'mx3', 'mx_all'))
# gc()
# 
# # Combine US + Canada + Mexico and reproject (for saftey cause should be good...)
# pa_vect <- rbind(ca_all_filt, us_all_filt, mx_all_filt)
# pa_vect <- project(pa_vect, "EPSG:4326")
# 
# # Save as polygon for gap analysis
# writeVector(pa_vect, "./maps/wdpa_prot_area/wdpa_ca_us_mx.gpkg", overwrite = TRUE)
# 
# # clean environment bc big files...
# rm(list = c("ca_all_filt", "us_all_filt", "mx_all_filt"))
# gc()

# Rasterize protected area to speed up analysis ---------------------------

# Define 2.5 arc-min raster template
# template <- rast(
#   xmin = -180, xmax = -50,
#   ymin = 15, ymax = 85,
#   resolution = c(2.5 / 60, 2.5 / 60),
#   crs = "EPSG:4326"
# )

# Rasterize vector into template
# pa_raster <- terra::rasterize(pa_vect, template, field = 1, background = NA)
# 
# rm(list = c("pa_vect"))
# gc()
# 
# # Save output
# writeRaster(pa_raster, "./maps/wdpa_prot_area/wdpa_raster_ca_us_mx.tif", overwrite = TRUE, datatype = "INT1U", gdal = c("COMPRESS=DEFLATE"))


# Helper functions --------------------------------------------------------

# The protected area raster has a much bigger extent then all (or most) of the masked prediction 
# rasters. This function aligns and then crops the PA raster to the prediction raster

align_pa_to_pred <- function(pa_raster, pred_raster) {
  pa <- pa_raster
  
  # check CRS are the same (should be)
  if (!terra::same.crs(pa, pred_raster)) {
    pa <- terra::project(pa, terra::crs(pred_raster), method = "near")
  }
  
  # Resolution/origin/grid
  # (forces exact alignment to the prediction grid)
  pa <- terra::resample(pa, pred_raster, method = "near")
  
  # Get Extent
  # Crop to prediction extent to keep it light.
  # If pred extends beyond PA after project/resample, those areas will remain NA (correct).
  pa <- terra::crop(pa, pred_raster)
  
  pa
}

# Build the path to each species occurrence data
occ_path_one <- function(occ_dir, sp) {
  f <- file.path(occ_dir, paste0("occ_", sp, "_thin.rds"))
  if (!file.exists(f)) stop("Missing occurrence file: ", f)
  f
}

# Read the .rds file for each species
# Going to implement this so only once species is loaded at a time
read_occ_one <- function(occ_dir, sp) {
  readRDS(occ_path_one(occ_dir, sp))
}

# Load the high suitability thresholds for each species
# Careful catches but should be fine...
read_thr_high <- function(thresholds_dir, sp) {
  f <- file.path(thresholds_dir, paste0(sp, "_thresholds_hist.rds"))
  if (!file.exists(f)) stop("Missing thresholds file: ", f)
  thr <- readRDS(f)
  if (!("high" %in% names(thr))) stop("Threshold object missing 'high' for: ", sp)
  as.numeric(thr[["high"]])
}

read_spatraster_rds <- function(path) {
  if (!file.exists(path)) stop("Missing prediction file: ", path)
  r <- readRDS(path)
  if (!inherits(r, "SpatRaster")) stop("RDS did not contain a SpatRaster: ", path)
  r
}

# IMPORTANT: update filename pattern here to match your actual masked outputs
pred_path_one <- function(sdm_root, sp, tc) {
  # expected: {sdm_root}/masked/{sp}/{sp}_{tc}_mask.rds
  f <- file.path(sdm_root, "masked", sp, paste0(sp, "_", tc, "_mask.rds"))
  if (!file.exists(f)) stop("Missing masked prediction: ", f)
  f
}

load_pred_stack_one_species <- function(sdm_root, sp, time_codes) {
  paths <- vapply(time_codes, \(tc) pred_path_one(sdm_root, sp, tc), character(1))
  rasters <- lapply(paths, read_spatraster_rds)
  
  # Combine SpatRasters into a multi-layer SpatRaster
  r <- Reduce(function(a, b) c(a, b), rasters)
  
  if (!inherits(r, "SpatRaster")) {
    stop("Stacking failed for ", sp, ". Got: ", paste(class(r), collapse = ", "))
  }
  
  names(r) <- time_codes
  r
}


# HELPER FOR COMPUTING GAP ANALYSIS PER SPECIES

calc_gap_one_species_all_times <- function(sp,
                                           occ_dir,
                                           thresholds_dir,
                                           sdm_root,
                                           pa_raster,
                                           time_codes) {
  
  # --- load occurrences
  pts <- read_occ_one(occ_dir, sp)
  
  if (!inherits(pts, "SpatVector")) {
    stop("Occurrence file for ", sp, " is not a SpatVector.")
  }
  if (terra::geomtype(pts) != "points") {
    stop("Occurrence object for ", sp, " is not POINT geometry.")
  }
  
  # --- load threshold
  thr_high <- read_thr_high(thresholds_dir, sp)
  
  # --- load all prediction rasters for this species
  pred_stack <- load_pred_stack_one_species(sdm_root, sp, time_codes)
  
  # --- align points CRS to predictions
  if (!terra::same.crs(pts, pred_stack)) {
    pts <- terra::project(pts, terra::crs(pred_stack))
  }
  
  # --- align PA to predictions (CRS + grid + crop-to-pred extent)
  pa_use <- align_pa_to_pred(pa_raster, pred_stack)
  
  # --- extract: predictions (ID + 7 cols)
  pred_vals <- terra::extract(pred_stack, pts)
  pred_mat <- as.matrix(pred_vals[, -1, drop = FALSE])
  
  # --- extract: PA (NA/1)
  pa_vals <- terra::extract(pa_use, pts)[, 2]
  protected <- !is.na(pa_vals) & (pa_vals == 1)
  
  # --- compute per time slice
  n_total <- terra::nrow(pts)
  
  out <- lapply(seq_along(time_codes), function(j) {
    tc <- time_codes[j]
    v <- pred_mat[, j]
    
    suitable_high <- !is.na(v) & (v >= thr_high)
    
    n_suitable <- sum(suitable_high, na.rm = TRUE)
    n_prot_suitable <- sum(suitable_high & protected, na.rm = TRUE)
    
    # % of total occurrences (rounded)
    prop_suitable_pct  <- if (n_total == 0) NA_real_ 
    else round((n_suitable / n_total) * 100, 2)
    
    prop_protected_pct <- if (n_total == 0) NA_real_ 
    else round((n_prot_suitable / n_total) * 100, 2)
    
    tibble(
      sp = sp,
      time_code = tc,
      thr_high = thr_high,
      n_occ_total = n_total,
      n_suitable_occ_high = n_suitable,
      n_protected_occ_high = n_prot_suitable,
      proportion_suitable = prop_suitable_pct,
      proportion_protected = prop_protected_pct
    )
  })
  
  bind_rows(out)
}

# HELPER FOR RUNNING ACROSS ALL SPECIES
run_group_all_times <- function(sp_codes,
                                occ_dir,
                                thresholds_dir,
                                sdm_root,
                                pa_raster,
                                time_codes) {
  
  res <- vector("list", length(sp_codes))
  
  for (i in seq_along(sp_codes)) {
    sp <- sp_codes[i]
    message("Species ", i, "/", length(sp_codes), ": ", sp)
    
    res[[i]] <- calc_gap_one_species_all_times(
      sp = sp,
      occ_dir = occ_dir,
      thresholds_dir = thresholds_dir,
      sdm_root = sdm_root,
      pa_raster = pa_raster,
      time_codes = time_codes
    )
    
    # memory hygiene between species
    gc()
  }
  
  bind_rows(res)
}

# RUN GAP ANALYSIS --------------------------------------------------------
sp_codes1 <- c(
  "ang","arb","bor","ces","cor",
  "cra","dar","del","ery","gem",
  "hir","mac","mem","mtu","mys",
  "myr","ova","ovt","oxy","pal",
  "par","sco","sta","ten","uli",
  "vid","sha"
)

sp_codes2 <- c(
  "ash","cae","cor2","cot","ell",
  "for","fus","sim","vir"
)

# Inputs
# PA raster created above
pa_raster <- rast("./maps/wdpa_prot_area/wdpa_raster_ca_us_mx.tif")

time_codes <- c(
  "hist",
  "ssp245_30", "ssp245_50", "ssp245_70",
  "ssp585_30", "ssp585_50", "ssp585_70"
)

# dirs (use consistent absolute paths if possible)
occ_dir1 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/"
occ_dir2 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/corym_sub/"

sdm_root <- "C:/Users/terre/Documents/R/vaccinium/sdm_output/sdm_output_feb_10_2026"
thresh_dir1 <- file.path(sdm_root, "thresholds")
thresh_dir2 <- file.path(sdm_root, "corym_sub", "thresholds")

# Run both groups
res1 <- run_group_all_times(sp_codes1, occ_dir1, thresh_dir1, sdm_root, pa_raster, time_codes)
res2 <- run_group_all_times(sp_codes2, occ_dir2, thresh_dir2, sdm_root, pa_raster, time_codes)

gap_table <- bind_rows(res1, res2)

write.csv(gap_table, "./gap_analysis/gap_occ_pa_high_suitability.csv", row.names = FALSE)


