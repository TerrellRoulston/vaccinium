# Top ---------------------------------------------------------------------
# This is a script addapted from malus/scripts/scripts/malus_area_latshift.R
# It will calculate the area of masked suitability rasters which includes highly suitable areas
# It compares across time frames to the recent historical projection to calculate the amount
# of contration, expansion, and stability under climate change
# 
# It also calculates the lattitudinal shift for each species


# Libraries ---------------------------------------------------------------
library(terra)
library(dplyr)
library(tidyr)
library(purrr)
library(tibble)

# Roots ---------------------------------------------------------------
# Note that SDMs were reran for cor, mac and cae on Feb 25th, but the nessicary files were copied
# to the Feb 10th file for simplicity

sdm_root <- "C:/Users/terre/Documents/R/vaccinium/sdm_output/sdm_output_feb_10_2026"
masked_root <- file.path(sdm_root, "masked") # all masked rasters saved in same spot as .rds
threshold_root <- file.path(sdm_root, "thresholds") # all thresholds saved in same spot as .rds
out_dir <- file.path(sdm_root, "summ_area") # create an output dir for the outputting .csv summaries
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE) # create that output dir

# Species -------------------------------------------------------------
# Main vaccinium spp
sp_codes1 <- c(
  "ang", "arb", "bor", "ces", "cor",
  "cra", "dar", "del", "ery", "gem",
  "hir", "mac", "mem", "mtu", "mys",
  "myr", "ova", "ovt", "oxy", "pal",
  "par", "sco", "sta", "ten", "uli",
  "vid", "sha"
)

# Cormybosum complex spp
sp_codes2 <- c(
  "ash", "cae", "cor2", "cot", "ell",
  "for", "fus", "sim", "vir"
)

# Switch for differing file paths
is_corym_sub <- function(sp) sp %in% sp_codes2

# combine together
all_spp <- c(sp_codes1, sp_codes2)

# Times ---------------------------------------------------------------
# Timeslices (file names) for ssp245 and ssp585
times_245 <- c("ssp245_30","ssp245_50","ssp245_70")
times_585 <- c("ssp585_30","ssp585_50","ssp585_70")

# Paths ---------------------------------------------------------------
# Path to masked suitability rasters (.rds files)
masked_path <- function(sp, time) {
  file.path(masked_root, sp, paste0(sp, "_", time, "_mask.rds"))
}
# Path to threhold lists (.rds files)
threshold_path <- function(sp) {
  if (is_corym_sub(sp)) {
    file.path(sdm_root, "corym_sub", "thresholds", paste0(sp, "_thresholds_hist.rds")) # switch to corym sub dir
  } else {
    file.path(threshold_root, paste0(sp, "_thresholds_hist.rds"))
  }
}

# Loaders -------------------------------------------------------------
# Helper functions for loading suitability rasters and high suitability threshold
read_rds_rast <- function(path) {
  obj <- readRDS(path)
  if (inherits(obj, "SpatRaster")) return(obj)
  stop("RDS not a raster: ", path)
}

get_t50 <- function(sp) {
  th <- readRDS(threshold_path(sp))  # named numeric: low, mod, high
  if (is.numeric(th) && !is.null(names(th)) && "high" %in% names(th)) {
    return(as.numeric(th[["high"]])[1])  # high == t50 
  }
  stop("Threshold file for ", sp, " missing 'high': ", threshold_path(sp))
}

# Core comparison -----------------------------------------------------
# t0 is ALWAYS historical slice
# t1 = climate change slice across SSP245 and 585 for 2030 50 and 70

compare_suitability <- function(t0_rast, t1_rast, threshold) {
  
  #  they should be the same extend but forcing for safety
  ext_u <- terra::union(terra::ext(t0_rast), terra::ext(t1_rast))
  r0 <- terra::extend(t0_rast, ext_u)
  r1 <- terra::extend(t1_rast, ext_u)
  
  # threshold (bin) the suitability raster to high suitability
  b0 <- r0 >= threshold
  b1 <- r1 >= threshold
  
  # which cells are not NA values!
  valid <- !is.na(b0) | !is.na(b1)
  idx <- which(valid[])
  
  # NA treated as FALSE
  t0v <- as.logical(b0[])[idx]; t0v[is.na(t0v)] <- FALSE
  t1v <- as.logical(b1[])[idx]; t1v[is.na(t1v)] <- FALSE
  
  # calculate the area size for each of these rasters at the indexed positions
  area0 <- terra::cellSize(r0, unit = "km")[]
  area1 <- terra::cellSize(r1, unit = "km")[]
  area <- ifelse(!is.na(area0), area0, area1)[idx]
  
  # compare the two rasters to find the following:
  # stable -- cell is suitable in the past and future
  # contraction -- cell is suitable in past but not in future
  # expasion -- cell is not suitable in the past but suitable in future
  # and if the case is TRUE that means that cell is just plain unsuitable
  
  status <- dplyr::case_when(
    t0v &  t1v ~ "stable",
    t0v & !t1v ~ "contraction",
    !t0v & t1v ~ "expansion",
    TRUE       ~ "unsuitable" # catches the the remaining case for safety (!t0v & !t1v)
  )
  
  # Then calculate the area of cells for each category of status above
  # Change in area
  area_by_change <- tibble(change = status, area_km2 = area) %>%
    group_by(change) %>%
    summarise(area_km2 = sum(area_km2, na.rm = TRUE), .groups = "drop")
  
  # total area
  total_area_summary <- tibble(
    time = c("t0","t1"),
    total_area_km2 = c(sum(area[t0v], na.rm = TRUE),
                       sum(area[t1v], na.rm = TRUE))
  )
  
  # calculate the median, mean and sd of latitudinal shift
  # note that this uses the 'density' of suitability across its longitude to calculate the metrics
  coords <- terra::xyFromCell(r0, idx)
  lat_summary <- tibble(
    time = c("t0","t1"),
    median_latitude = c(if (any(t0v)) median(coords[t0v,2]) else NA_real_,
                        if (any(t1v)) median(coords[t1v,2]) else NA_real_),
    mean_latitude   = c(if (any(t0v)) mean(coords[t0v,2])   else NA_real_,
                        if (any(t1v)) mean(coords[t1v,2])   else NA_real_),
    sd_latitude     = c(if (any(t0v)) sd(coords[t0v,2])     else NA_real_,
                        if (any(t1v)) sd(coords[t1v,2])     else NA_real_)
  )
  
  list(area_by_change = area_by_change,
       total_area_summary = total_area_summary,
       lat_summary = lat_summary)
}

summarize_long_format <- function(taxon_code, hist, ssp30, ssp50, ssp70, threshold) {
  
  # baseline (t0)
  t0_vals <- compare_suitability(hist, hist, threshold)
  A_hist  <- t0_vals$total_area_summary %>% filter(time == "t0") %>% pull(total_area_km2) %>% .[1]
  t0_lat  <- t0_vals$lat_summary %>% filter(time == "t0") %>% slice(1)
  
  baseline_row <- tibble(
    taxon = taxon_code,
    timeseries = "t0",
    change = "total",
    area_km2 = A_hist,
    median_latitude = t0_lat$median_latitude,
    mean_latitude = t0_lat$mean_latitude,
    sd_latitude = t0_lat$sd_latitude,
    pct_retained = 100,
    pct_gained   = 0,
    pct_lost     = 0
  )
  
  future_layers <- list(ssp30 = ssp30, ssp50 = ssp50, ssp70 = ssp70)
  
  future_rows <- imap_dfr(future_layers, function(layer, label) {
    
    res <- compare_suitability(hist, layer, threshold)
    lat <- res$lat_summary %>% filter(time == "t1") %>% slice(1)
    
    # pull areas (missing -> 0)
    A_stable <- res$area_by_change %>% filter(change == "stable")      %>% pull(area_km2) %>% {if (length(.)==0) 0 else .[1]}
    A_gain   <- res$area_by_change %>% filter(change == "expansion")   %>% pull(area_km2) %>% {if (length(.)==0) 0 else .[1]}
    A_loss   <- res$area_by_change %>% filter(change == "contraction") %>% pull(area_km2) %>% {if (length(.)==0) 0 else .[1]}
    
    # safe divide (if A_hist is 0, percents are NA)
    pct_ret <- if (A_hist > 0) 100 * A_stable / A_hist else NA_real_
    pct_gain<- if (A_hist > 0) 100 * A_gain   / A_hist else NA_real_
    pct_loss<- if (A_hist > 0) 100 * A_loss   / A_hist else NA_real_
    
    # total future area (not a percent change metric, but keep for context)
    A_future <- res$total_area_summary %>% filter(time == "t1") %>% pull(total_area_km2) %>% .[1]
    
    # rows (keep your long format structure)
    changes <- res$area_by_change %>%
      filter(change %in% c("contraction", "expansion", "stable")) %>%
      mutate(
        taxon = taxon_code,
        timeseries = label,
        median_latitude = lat$median_latitude,
        mean_latitude = lat$mean_latitude,
        sd_latitude = lat$sd_latitude,
        pct_retained = pct_ret,
        pct_gained   = pct_gain,
        pct_lost     = pct_loss
      ) %>%
      select(taxon, timeseries, change, area_km2,
             median_latitude, mean_latitude, sd_latitude,
             pct_retained, pct_gained, pct_lost)
    
    total_future <- tibble(
      taxon = taxon_code,
      timeseries = label,
      change = "total",
      area_km2 = A_future,
      median_latitude = lat$median_latitude,
      mean_latitude = lat$mean_latitude,
      sd_latitude = lat$sd_latitude,
      pct_retained = pct_ret,
      pct_gained   = pct_gain,
      pct_lost     = pct_loss
    )
    
    bind_rows(changes, total_future)
  })
  
  bind_rows(baseline_row, future_rows)
}

make_wide <- function(long_df, ssp_label) {
  df_t0 <- long_df %>%
    filter(timeseries == "t0", change == "total") %>%
    select(taxon, area_km2, median_latitude, mean_latitude, sd_latitude) %>%
    rename(
      total_area_t0 = area_km2,
      median_latitude_t0 = median_latitude,
      mean_latitude_t0 = mean_latitude,
      sd_latitude_t0 = sd_latitude
    )
  
  df_changes <- long_df %>%
    filter(timeseries != "t0") %>%
    select(taxon, timeseries, change, area_km2) %>%
    pivot_wider(
      names_from = c(timeseries, change),
      values_from = area_km2,
      values_fill = 0
    )
  
  df_lats <- long_df %>%
    filter(timeseries != "t0") %>%
    group_by(taxon, timeseries) %>%
    slice(1) %>%
    ungroup() %>%
    select(taxon, timeseries, median_latitude, mean_latitude, sd_latitude) %>%
    pivot_wider(
      names_from = timeseries,
      values_from = c(median_latitude, mean_latitude, sd_latitude)
    )
  
  df_t0 %>%
    left_join(df_changes, by = "taxon") %>%
    left_join(df_lats, by = "taxon") %>%
    mutate(ssp = ssp_label)
}

# Run ---------------------------------------------------------------
run_one_ssp <- function(ssp = c("ssp245","ssp585")) {
  ssp <- match.arg(ssp)
  times <- if (ssp == "ssp245") times_245 else times_585
  
  pmap_dfr(
    list(
      taxon_code = all_spp,
      threshold  = map(all_spp, get_t50),
      hist       = map(all_spp, ~ read_rds_rast(masked_path(.x, "hist"))),
      ssp30      = map(all_spp, ~ read_rds_rast(masked_path(.x, times[1]))),
      ssp50      = map(all_spp, ~ read_rds_rast(masked_path(.x, times[2]))),
      ssp70      = map(all_spp, ~ read_rds_rast(masked_path(.x, times[3])))
    ),
    summarize_long_format
  ) %>% mutate(ssp = ssp)
}

summary_long_245 <- run_one_ssp("ssp245")
summary_long_585 <- run_one_ssp("ssp585")
combined_long_df <- bind_rows(summary_long_245, summary_long_585)

summary_wide_df <- bind_rows(
  make_wide(summary_long_245, "ssp245"),
  make_wide(summary_long_585, "ssp585")
)

write.csv(combined_long_df,
          file = file.path(out_dir, "vaccinium_area_summary_long_ssp245and585.csv"),
          row.names = FALSE)

write.csv(summary_wide_df,
          file = file.path(out_dir, "vaccinium_area_summary_wide_ssp245and585.csv"),
          row.names = FALSE)

message("Done. Outputs in: ", out_dir)