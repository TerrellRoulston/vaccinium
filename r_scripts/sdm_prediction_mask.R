# Top ---------------------------------------------------------------------
# This is a script to mask the SDM predictions to the ecoregions in which species occupy.
# For the historical projections the mask will be the ecoregion containing occurrence points, see vacc_bg_cec
# For the future predictions the mask will be the historical ecoregions, plus adjacent poleward ecoregions that contain suitability
# This avoids spurious predicted areas, for example sometimes suitable areas in the PNW are also suitable in Florida due to analogous
# climates. So will need to intersect the future suitability with the ecoregions and then select ones which are adajecnt some way...
# May need to do this manually for each species but I will see...

# Oh maybe make a graph of adjacent ecoregions?
# Adjacency matrix

# Terrell Roulston
# Feb 12th 2026

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

# Load CEC ecoregion data -------------------------------------------------
# Load ecoregion shape file from the CEC dataset
# Visit: https://www.epa.gov/eco-research/ecoregions-north-america
ecoNA <- vect(x = "maps/cec_eco/na_cec_eco_l2/NA_CEC_Eco_Level2.shp")
# gets reprojected below now
ecoNA <- project(ecoNA, 'WGS84') # project ecoregion vector to same coords ref as basemap

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

# Build adjacency list from ecoNA (touching polygons).
# Run once; reuse for all species/time.
build_eco_adjacency <- function(ecoNA, id_col = "NA_L2CODE") {
  
  stopifnot(inherits(ecoNA, "SpatVector"))
  if (!id_col %in% names(ecoNA)) stop("id_col not found in ecoNA: ", id_col)
  
  ids <- as.character(ecoNA[[id_col]])
  
  # Get touching polygon pairs as ROW INDICES (two-column matrix)
  # col 1 = polygon i, col 2 = polygon j, meaning i touches j
  pairs <- terra::relate(ecoNA, ecoNA, relation = "touches", pairs = TRUE)
  
  # Remove self-pairs
  pairs <- pairs[pairs[, 1] != pairs[, 2], , drop = FALSE]
  
  # Initialize adjacency list:
  # adj[["ECOCODE"]] = c("neighbor_code_1", "neighbor_code_2", ...)
  # (Use unique codes as keys to avoid weirdness if codes repeat)
  id_levels <- unique(ids)
  adj <- setNames(vector("list", length(id_levels)), id_levels)
  
  # Fill adjacency list using touching pairs
  for (k in seq_len(nrow(pairs))) {
    
    a <- ids[pairs[k, 1]]
    b <- ids[pairs[k, 2]]
    
    # Safety: skip any missing/blank codes
    if (is.na(a) || is.na(b) || !nzchar(a) || !nzchar(b)) next
    
    # Add each other as neighbors (undirected graph)
    adj[[a]] <- unique(c(adj[[a]], b))
    adj[[b]] <- unique(c(adj[[b]], a))
  }
  
  list(adj = adj, ecoNA = ecoNA)
}


  # Breadth-First Search (BFS) connectivity filter on adjacency graph, restricted to candidate set
  # This function keeps only the ecoregion polys that are connected to the historical ecoregion
  connected_to_hist <- function(hist_ids, candidate_ids, adj) {
    
    # ensure IDs exist the the adjaceny matrix
    hist_ids <- intersect(as.character(hist_ids), names(adj))
    candidate_ids <- intersect(as.character(candidate_ids), names(adj))
    
    # Safe empty catch
    if (length(hist_ids) == 0 || length(candidate_ids) == 0) return(character(0))
    
    # Keep track of what candidate nodes have been searched already
    visited <- setNames(rep(FALSE, length(candidate_ids)), candidate_ids)
    
    # Started the visited queue at the historical nodes that are also candidates
    queue <- hist_ids[hist_ids %in% candidate_ids]
    visited[queue] <- TRUE
    
    # Breadth-first search across the adjaceny matrix
    while (length(queue) > 0) {
      cur <- queue[1] # cur = current, the current node being searched
      queue <- queue[-1] # pop from queue
      
      # Neighboring ecoregions RESTRICTED to the candancy set
      nbrs <- adj[[cur]]
      nbrs <- nbrs[nbrs %in% candidate_ids]
      
      # Keep only neighbors not yet visited
      new <- nbrs[!visited[nbrs]]
      
      if (length(new)) {
        visited[new] <- TRUE
        queue <- c(queue, new) # add to queue for further exploration (keep seaching adjancy matrix until no new candidate adjacent ecoregions are available)
      }
    }
    
    # Return only the cadidate IDs reachable from the historical set of ecoregions
    names(visited)[visited]
  }

# Build mask polygons for a FUTURE raster:
# hist ecocodes + future-suitable ecocodes, but keep only those connected to hist
  # Build mask polygons for a FUTURE raster:
  # - Start set = historical ecoregions for the species
  # - Add ecoregions that contain future suitability >= suit_thr
  # - Keep only those candidate ecoregions connected to the historical set (adjacency graph)
  make_future_eco_mask <- function(r_future, eco_hist_sp, ecoNA, adj,
                                   suit_thr, id_col = "NA_L2CODE") {
    
    stopifnot(inherits(r_future, "SpatRaster"))
    stopifnot(inherits(eco_hist_sp, "SpatVector"))
    stopifnot(inherits(ecoNA, "SpatVector"))
    
    if (!id_col %in% names(eco_hist_sp)) stop("id_col not found in eco_hist_sp: ", id_col)
    if (!id_col %in% names(ecoNA)) stop("id_col not found in ecoNA: ", id_col)
    
    # ---- Historical ecoregion codes for this species
    hist_ids <- unique(as.character(eco_hist_sp[[id_col]]))
    hist_ids <- hist_ids[!is.na(hist_ids) & nzchar(hist_ids)]
    
    if (length(hist_ids) == 0) {
      stop("No historical ecoregion IDs found in eco_hist_sp for id_col = ", id_col)
    }
    
    # ---- Future-suitable ecoregions (polygon-wise max over raster)
    # NOTE: this function should already handle CRS/cropping safely if you used my updated version
    suit_ids <- future_suitable_ecos(
      r = r_future,
      ecoNA = ecoNA,
      suit_thr = suit_thr,
      id_col = id_col
    )
    suit_ids <- suit_ids[!is.na(suit_ids) & nzchar(suit_ids)]
    
    # ---- Candidate nodes = historical + future-suitable
    candidate <- union(hist_ids, suit_ids)
    
    # ---- Keep only candidate nodes reachable from historical nodes through candidate nodes
    keep_ids <- connected_to_hist(hist_ids, candidate, adj)
    keep_ids <- keep_ids[!is.na(keep_ids) & nzchar(keep_ids)]
    
    # If for some reason we lose everything, fall back to historical
    if (length(keep_ids) == 0) {
      keep_ids <- hist_ids
    }
    
    # ---- IMPORTANT: subset ecoNA BY ROWS using the ID column (NOT by columns!)
    eco_mask <- ecoNA[as.character(ecoNA[[id_col]]) %in% keep_ids, ]
    
    eco_mask
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

# Build adjacency graph once (ecoNA must exist as SpatVector of ALL L2 ecoregions)
# IMPORTANT: ecoNA is filtered to drop "0.0" inside this call

adj_out <- build_eco_adjacency(ecoNA, id_col = id_col)
adj   <- adj_out$adj
ecoNA2 <- adj_out$ecoNA   # filtered ecoNA (no "0.0")

# Loading all rasters at once is really really memory intensive (252 total rasters) so...
# Mask + save (process one raster at a time = memory safe)
# Inputs: sp code, prediction timeslice, path to predition, historical ecoregion for sp,
# path to threshold, path to output rds dir, path to output vector dir,
# ecoregion vector file, adjaceny matrix (candidate only)
# ecoregion ID level, and drop code (water)

mask_and_save_one <- function(sp, time, pred_path, eco_hist_sp,
                              thresholds_dir, out_rds_dir, out_poly_dir,
                              ecoNA, adj, id_col = "NA_L2CODE") {
  
  r <- read_pred_raster(pred_path)
  
  # Historical: mask = the historical ecoregions only (as provided by eco_hist_sp)
  if (time == "hist") {
    eco_mask <- eco_hist_sp
    # be safe: drop 0.0 if present
    eco_mask <- eco_mask[as.character(eco_mask[[id_col]]), ]
  } else {
    # Future: threshold based on historical 1st percentile ("low")
    suit_thr <- read_threshold_low(thresholds_dir, sp)
    
    eco_mask <- make_future_eco_mask(
      r_future   = r,
      eco_hist_sp = eco_hist_sp,
      ecoNA      = ecoNA,
      adj        = adj,
      suit_thr   = suit_thr,
      id_col     = id_col
    )
  }
  
  r_masked <- terra::mask(r, eco_mask)
  
  # Save masked raster as RDS (matches your existing storage style)
  dir.create(out_rds_dir, recursive = TRUE, showWarnings = FALSE)
  saveRDS(r_masked, file.path(out_rds_dir, paste0(sp, "_pred_", time, "_masked.rds")))
  
  # Save the mask polygons too (useful for QA / plotting)
  dir.create(out_poly_dir, recursive = TRUE, showWarnings = FALSE)
  terra::writeVector(eco_mask,
                     file.path(out_poly_dir, paste0(sp, "_eco_mask_", time, ".gpkg")),
                     overwrite = TRUE)
  
  # cleanup
  rm(r, r_masked, eco_mask)
  gc()
  invisible(TRUE)
}


# Run ecoregion search and mask -------------------------------------------
# ---- Run for main spp
for (sp in sp_codes1) {
  eco_hist_sp <- eco_vect_list1[[sp]]
  if (is.null(eco_hist_sp)) stop("Missing historical ecoregion vector for species: ", sp)
  
  for (time in time_codes) {
    mask_and_save_one(
      sp = sp,
      time = time,
      pred_path = pred_files1[[time]][[sp]],
      eco_hist_sp = eco_hist_sp,
      thresholds_dir = thresh_dir1,
      out_rds_dir = out_masked1_rds,
      out_poly_dir = out_maskpoly1,
      ecoNA = ecoNA2,
      adj = adj,
      id_col = id_col
    )
  }
}

# ---- Run for corym complex
for (sp in sp_codes2) {
  eco_hist_sp <- eco_vect_list2[[sp]]
  if (is.null(eco_hist_sp)) stop("Missing historical ecoregion vector for species: ", sp)
  
  for (time in time_codes) {
    mask_and_save_one(
      sp = sp,
      time = time,
      pred_path = pred_files2[[time]][[sp]],
      eco_hist_sp = eco_hist_sp,
      thresholds_dir = thresh_dir2,
      out_rds_dir = out_masked2_rds,
      out_poly_dir = out_maskpoly2,
      ecoNA = ecoNA2,
      adj = adj,
      id_col = id_col
    )
  }
}
