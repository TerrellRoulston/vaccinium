# Top ---------------------------------------------------------------------
# This script is for automating plotting of suitability maps to be used in internal reporting
# Terrell Roulston
# Feb 11th 2026
#
# UPDATED Feb 2026:
# - SDM outputs are stored in: sdm_output/sdm_output_feb_10_2026/masked/{sp}/
# - Corymbosum complex outputs in: sdm_output/sdm_output_feb_10_2026/masked/{sp}/
# - NOTE: THIS IS SAME DIRECTORY
# 
# - Thresholds are stored as one RDS per species:
#     sdm_output/sdm_output_feb_10_2026/thresholds/{sp}_thresholds_hist.rds
# - Occurrences are stored in:
#     occ_data/thin/ and occ_data/thin/corym_sub/

Start <- Sys.time() # Track runtime
# Libraries ---------------------------------------------------------------
library(tidyverse) # grammar + data management
library(terra)     # spatial data

# Species codes -----------------------------------------------------------

sp_codes1 <- c(
  "ang", "arb", "bor", "ces", "cor",
  "cra", "dar", "del", "ery", "gem",
  "hir", "mac", "mem", "mtu", "mys",
  "myr", "ova", "ovt", "oxy", "pal",
  "par", "sco", "sta", "ten", "uli",
  "vid", "sha"
)

sp_codes2 <- c(
  "ash", "cae", "cor2", "cot", "ell",
  "for", "fus", "sim", "vir"
)

is_corym <- function(sp) sp %in% sp_codes2 # switch for corym sub species

# Paths -------------------------------------------------------------------
masked_dir <- "C:/Users/terre/Documents/R/vaccinium/sdm_output/sdm_output_feb_10_2026/masked"
# Note that the updat

# Helper: safe RDS read (expects SpatRaster inside)
safe_read_rds <- function(path) {
  if (!file.exists(path)) return(NULL)
  readRDS(path)
}


# Assumes ocean is NA in the wclim raster; land has values.
make_land_bg_from_wclim <- function(pred_lcc, wclim_lcc, bbox) {
  pred_bb <- terra::crop(pred_lcc, bbox)
  wc_bb   <- terra::crop(wclim_lcc, bbox)
  wc_bb   <- terra::resample(wc_bb, pred_bb, method = "near")
  terra::ifel(!is.na(wc_bb), 1, NA)
}

# Load ONE WCLIM layer from your multi-layer SpatRaster .rds and project to LCC
load_wclim_layer <- function(rds_path, layer_name, crs_target) {
  if (!file.exists(rds_path)) return(NULL)
  
  wc_all <- terra::rast(rds_path)
  
  if (!layer_name %in% names(wc_all)) {
    stop("WCLIM layer not found: ", layer_name,
         "\nAvailable: ", paste(names(wc_all), collapse = ", "))
  }
  
  wc1 <- wc_all[[layer_name]]
  terra::project(wc1, crs_target)
}

# Example access:
# masked_main$ang$masked_pred_hist
# masked_corym$ash$masked_pred_ssp585_70

fig_root = "C:/Users/terre/Documents/R/vaccinium/figures/masked/"

paths <- list(
  # Occurrences
  occ_dir1  = "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/",
  occ_dir2  = "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/corym_sub/",
  
  # SDM bundle root (Feb 10 2026 export)
  sdm_root = "C:/Users/terre/Documents/R/vaccinium/sdm_output/sdm_output_feb_10_2026/",
  # Updated SDMs for cor, mac and cae saved in the same path
  
  # Output
 
  fig_root = fig_root,
  out_dir1 = file.path(fig_root, "main"),
  out_dir2 = file.path(fig_root, "corym_sub"),
  
  # Map assets
  border_path = "C:/Users/terre/Documents/Acadia/Vaccinium/map_data/can_us_mex_border/",
  lakes_path = "C:/Users/terre/Documents/Acadia/Vaccinium/map_data/great lakes/combined great lakes/",
  wclim_path = "C:/Users/terre/Documents/R/vaccinium/wclim_data/wclim_CA_US_MX/wclim_CA_US_MX.rds",
  wclim_layer_name = "wc2.1_2.5m_bio_1", # just pick any layer for plotting 'basemap'
  
  # masked paths
  masked_dir = masked_dir
  
)

dir.create(paths$out_dir1, recursive = TRUE, showWarnings = FALSE)
dir.create(paths$out_dir2, recursive = TRUE, showWarnings = FALSE)


# Projections -------------------------------------------------------------
projLam <- "+proj=lcc +lat_1=49 +lat_2=77 +lat_0=49 +lon_0=-95 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

great_lakes   <- try(vect(paths$lakes_path), silent = TRUE)
can_us_mx_border <- try(vect(paths$border_path), silent = TRUE)

if (!inherits(can_us_mx_border, "try-error")) {
  can_us_mx_border <- project(can_us_mx_border, projLam)
}

if (!inherits(great_lakes, "try-error")) {
  great_lakes <- project(great_lakes, projLam)
}

wclim_bio1_lcc <- try(
  load_wclim_layer(paths$wclim_path, paths$wclim_layer_name, projLam),
  silent = TRUE
)

if (inherits(wclim_bio1_lcc, "try-error")) {
  message("WARNING: WCLIM load failed: ", conditionMessage(attr(wclim_bio1_lcc, "condition")))
  wclim_bio1_lcc <- NULL
}



# Plot aesthetics --------------------------------------------------------
fill_cols <- c("#FFF7BC", "#FEC44F", "#D95F0E")  # low/mod/high
bg_col    <- "lightskyblue1"
na_col    <- "#E8E8E8"
pt_col    <- "black"


# Helper functions --------------------------------------------------------
# Safe reprojections
proj_if <- function(x, crs) if (is.null(x)) NULL else project(x, crs)

# Calculate padding
pad_extent <- function(e, pad_frac = 0.04) {
  w <- (e$xmax - e$xmin); h <- (e$ymax - e$ymin)
  ext(e$xmin - w * pad_frac, e$xmax + w * pad_frac,
      e$ymin - h * pad_frac, e$ymax + h * pad_frac)
}

# Setup bounding box for the plot using padding calculation
get_bbox_lcc <- function(pred_hist_lcc, occ_lcc, pad_frac = 0.004) {
  if (!is.null(pred_hist_lcc)) return(pad_extent(ext(pred_hist_lcc), pad_frac))
  if (!is.null(occ_lcc))       return(pad_extent(ext(occ_lcc), pad_frac))
  NULL
}


# Data loading ------------------------------------------------------------

# Occurrence loader:
# - main spp: occ_dir1
# - corym complex: occ_dir2
load_occ <- function(sp, occ_dir1, occ_dir2) {
  dir <- if (is_corym(sp)) occ_dir2 else occ_dir1
  
  candidates <- c(
    file.path(dir, paste0("occ_", sp, "_thin.rds"))
  )
  
  for (p in candidates) {
    x <- safe_read_rds(p)
    if (!is.null(x)) return(x)
  }
  NULL
}

# Prediction loader (MASKED):
# masked_dir_main/{sp}/{sp}_pred_{key}_masked.rds
# 
#
# Returns a list with names: hist, ssp245_30, ssp245_50, ssp245_70, ssp585_30, ssp585_50, ssp585_70
load_preds <- function(sp, masked_dir) {
  
  key_paths <- list(
    hist      = file.path(masked_dir, sp, paste0(sp, "_hist_mask.rds")),
    ssp245_30 = file.path(masked_dir, sp, paste0(sp, "_ssp245_30_mask.rds")),
    ssp245_50 = file.path(masked_dir, sp, paste0(sp, "_ssp245_50_mask.rds")),
    ssp245_70 = file.path(masked_dir, sp, paste0(sp, "_ssp245_70_mask.rds")),
    ssp585_30 = file.path(masked_dir, sp, paste0(sp, "_ssp585_30_mask.rds")),
    ssp585_50 = file.path(masked_dir, sp, paste0(sp, "_ssp585_50_mask.rds")),
    ssp585_70 = file.path(masked_dir, sp, paste0(sp, "_ssp585_70_mask.rds"))
  )
  
  preds <- lapply(key_paths, safe_read_rds)
  attr(preds, "paths") <- key_paths
  preds
}

# Threshold loader:
# {sdm_root}/thresholds/{sp}_thresholds_hist.rds

# Returns list(t1, t10, t50) where:
#   t1  = low
#   t10 = mod
#   t50 = high
load_thresholds <- function(sp, sdm_root) {
  
  # Try main thresholds first, then corym_sub thresholds
  thr_path1 <- file.path(sdm_root, "thresholds",  paste0(sp, "_thresholds_hist.rds"))
  thr_path2 <- file.path(sdm_root, "corym_sub", "thresholds", paste0(sp, "_thresholds_hist.rds"))
  
  thr_obj <- safe_read_rds(thr_path1)
  thr_path <- thr_path1
  
  if (is.null(thr_obj)) {
    thr_obj <- safe_read_rds(thr_path2)
    thr_path <- thr_path2
  }
  
  if (is.null(thr_obj)) {
    return(list(t1 = NULL, t10 = NULL, t50 = NULL,
                thr_path = paste0("Tried: ", thr_path1, " | ", thr_path2)))
  }
  
  # Expect a numeric vector like: c(low=..., mod=..., high=...)
  if (!is.numeric(thr_obj)) {
    stop("Threshold object is not numeric for ", sp, ": ", thr_path)
  }
  
  nms <- names(thr_obj)
  
  # Preferred: named low/mod/high (or low/moderate/high)
  if (!is.null(nms) && all(c("low", "high") %in% nms) && (("mod" %in% nms) || ("moderate" %in% nms))) {
    mod_name <- if ("mod" %in% nms) "mod" else "moderate"
    return(list(
      t1 = unname(thr_obj[["low"]]),
      t10 = unname(thr_obj[[mod_name]]),
      t50 = unname(thr_obj[["high"]]),
      thr_path = thr_path
    ))
  }
  
  # Fallback: if names are missing but length==3, assume order low/mod/high
  if (is.null(nms) && length(thr_obj) == 3) {
    return(list(
      t1 = unname(thr_obj[[1]]),
      t10 = unname(thr_obj[[2]]),
      t50 = unname(thr_obj[[3]]),
      thr_path = thr_path
    ))
  }
  
  # Otherwise fail loudly so you notice a structure change
  stop(
    "Unexpected threshold format for ", sp, " at: ", thr_path,
    "\nExpected numeric named c(low, mod, high) or unnamed length 3."
  )
}


# Plotter functions -------------------------------------------------------

plot_occ_map <- function(sp, pred_hist_lcc, occ_lcc, bbox, out_dir, wclim_bg_lcc = NULL) {
  if (is.null(pred_hist_lcc) || is.null(bbox)) return(invisible(NULL))
  
  png(file.path(out_dir, paste0(sp, "_occ.png")), width = 2400, height = 1600, res = 200)
  
  base_plotted <- FALSE
  
  if (!is.null(wclim_bg_lcc)) {
    land <- make_land_bg_from_wclim(pred_hist_lcc, wclim_bg_lcc, bbox)
    
    terra::plot(
      land,
      col = na_col,
      colNA = NA,
      background = bg_col,
      legend = FALSE,
      xlim = c(bbox$xmin, bbox$xmax),
      ylim = c(bbox$ymin, bbox$ymax),
      main = paste0(sp, " occurrences"),
      axes = FALSE,
      box = TRUE,
      mar = c(2, 2, 4, 2),
      cex.main = 1.6
    )
    
    base_plotted <- TRUE
  }
  
  if (!is.null(great_lakes) && !inherits(great_lakes, "try-error"))
    terra::plot(great_lakes, add = TRUE)
  
  if (!is.null(can_us_mx_border) && !inherits(can_us_mx_border, "try-error"))
    terra::plot(can_us_mx_border, add = TRUE)
  
  if (!is.null(occ_lcc))
    terra::points(occ_lcc, col = pt_col, pch = 16, cex = 0.7)
  
  dev.off()
}

plot_suitability_map <- function(sp, title, pred_lcc, thr, bbox, out_file, wclim_bg_lcc = NULL) {
  if (is.null(pred_lcc) || is.null(bbox)) return(invisible(NULL))
  if (is.null(thr$t1) || is.null(thr$t10) || is.null(thr$t50)) return(invisible(NULL))
  
  if (terra::nlyr(pred_lcc) > 1) pred_lcc <- pred_lcc[[1]]
  
  png(out_file, width = 2400, height = 1600, res = 200)
  
  base_plotted <- FALSE
  if (!is.null(wclim_bg_lcc)) {
    land <- make_land_bg_from_wclim(pred_lcc, wclim_bg_lcc, bbox)
    
    terra::plot(
      land,
      col = na_col,
      colNA = NA,          # ocean transparent -> bg_col shows
      background = bg_col,
      legend = FALSE,
      xlim = c(bbox$xmin, bbox$xmax),
      ylim = c(bbox$ymin, bbox$ymax),
      main = title,
      cex.main = 1.6,
      axes = FALSE,
      box = TRUE,
      mar = c(2, 2, 4, 2)
    )
    
    base_plotted <- TRUE
  }
  
  # Base (0/1 numeric)
  # Low suitability only; leave everything else transparent so WCLIM grey shows through
  b1  <- terra::ifel(pred_lcc > thr$t1, 1, NA)
  
  terra::plot(
    b1,
    col = fill_cols[1],  # only plotting 1's
    colNA = NA,          # NA = transparent
    legend = FALSE,
    xlim = c(bbox$xmin, bbox$xmax),
    ylim = c(bbox$ymin, bbox$ymax),
    main = if (!base_plotted) title else "",
    cex.main = 1.6,
    axes = FALSE,
    box = TRUE,
    mar = c(2, 2, 4, 2),
    add = base_plotted
  )
  
  # Overlays: FALSE -> NA so only TRUE pixels draw
  b10 <- terra::ifel(pred_lcc > thr$t10, 1, NA)
  b50 <- terra::ifel(pred_lcc > thr$t50, 1, NA)
  
  terra::plot(b10, col = fill_cols[2], colNA = NA, add = TRUE, legend = FALSE)
  terra::plot(b50, col = fill_cols[3], colNA = NA, add = TRUE, legend = FALSE)
  
  if (!is.null(great_lakes) && !inherits(great_lakes, "try-error")) terra::plot(great_lakes, add = TRUE)
  if (!is.null(can_us_mx_border) && !inherits(can_us_mx_border, "try-error")) terra::plot(can_us_mx_border, add = TRUE)
  
  dev.off()
}


save_legend_png <- function(out_dir) {
  png(file.path(out_dir, "legend_suitability.png"), width = 2400, height = 700, res = 200)
  par(mar = c(0, 0, 0, 0))
  plot.new()
  legend("center", horiz = TRUE, bty = "n",
         title = "Habitat suitability",
         legend = c("Low", "Moderate", "High"),
         fill = fill_cols, cex = 2)
  dev.off()
}


# Main runner for one species

run_species_plots <- function(sp, paths) {
  message("Plotting: ", sp)
  
  # Decide output base dir + make species subfolder
  out_base <- if (is_corym(sp)) paths$out_dir2 else paths$out_dir1
  out_sp_dir <- file.path(out_base, sp)
  dir.create(out_sp_dir, recursive = TRUE, showWarnings = FALSE)
  
  # Load
  occ   <- load_occ(sp, paths$occ_dir1, paths$occ_dir2)
  preds <- load_preds(sp, paths$masked_dir)
  thrs  <- load_thresholds(sp, paths$sdm_root)
  
  # Checks
  if (is.null(occ)) {
    message("  - missing occ for ", sp)
    return(invisible(FALSE))
  }
  if (is.null(preds$hist)) {
    message("  - missing hist pred: ", attr(preds, "paths")$hist)
    return(invisible(FALSE))
  }
  if (is.null(thrs$t1) || is.null(thrs$t10) || is.null(thrs$t50)) {
    message("  - missing/failed to parse thresholds: ", thrs$thr_path)
    return(invisible(FALSE))
  }
  
  # Project
  occ_lcc       <- proj_if(occ, projLam)
  pred_hist_lcc <- proj_if(preds$hist, projLam)
  
  bbox <- get_bbox_lcc(pred_hist_lcc, occ_lcc)
  if (is.null(bbox)) {
    message("  - skipping (no bbox)")
    return(invisible(FALSE))
  }
  
  # Occurrence map
  plot_occ_map(
    sp,
    pred_hist_lcc,
    occ_lcc,
    bbox,
    out_sp_dir,
    wclim_bg_lcc = wclim_bio1_lcc
  )
  
  # Historical
  plot_suitability_map(
    sp = sp,
    title = paste0(sp, " historical"),
    pred_lcc = pred_hist_lcc,
    thr = thrs,
    bbox = bbox,
    out_file = file.path(out_sp_dir, paste0(sp, "_hist.png")),
    wclim_bg_lcc = wclim_bio1_lcc
  )
  
  # Futures (only plot if raster exists)
  future_keys <- c("ssp245_30","ssp245_50","ssp245_70","ssp585_30","ssp585_50","ssp585_70")
  for (k in future_keys) {
    r <- preds[[k]]
    if (is.null(r)) {
      message("  - missing future pred: ", attr(preds, "paths")[[k]])
      next
    }
    r_lcc <- proj_if(r, projLam)
    title <- paste(
      sp,
      gsub("^ssp", "SSP",
           gsub("_([0-9]{2})$", " 20\\1",
                gsub("_", " ", k)))
    )
    out_file <- file.path(out_sp_dir, paste0(sp, "_", k, ".png"))

    plot_suitability_map(sp, title, r_lcc, thrs, bbox, out_file, wclim_bg_lcc = wclim_bio1_lcc)
  }
  
  invisible(TRUE)
}



# Run plotting for all spp ------------------------------------------------

save_legend_png(paths$out_dir1)
save_legend_png(paths$out_dir2)

all_spp <- c(sp_codes1, sp_codes2)
ok <- vapply(all_spp, function(sp) {
  tryCatch(run_species_plots(sp, paths), error = function(e) {
    message("ERROR for ", sp, ": ", conditionMessage(e))
    FALSE
  })
}, logical(1))

message("Done. PNGs in:")
message("  Main:  ", normalizePath(paths$out_dir1))
message("  Corym: ", normalizePath(paths$out_dir2))
message("Plotted: ", sum(ok), " / ", length(ok), " species")

# Mark end time
Stop <- Sys.time()
message(Stop - Start) # Return elasped runtime