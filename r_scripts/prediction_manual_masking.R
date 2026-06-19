# Top ---------------------------------------------------------------------
# Things I need
# 
# Historical suitability rasters
# Intersected with Future rasters
# 
# Need to somehow calculate where suitability is continous 
# and how that continous suitability touches the historical suitability 
# in any one place
# 
# Then use that continous peice of suitability as a mask

# Libraries
library(tidyverse)
library(terra)


# Import ecoregion shapefile
ecoNA <- vect(x = "maps/cec_eco/na_cec_eco_l2/NA_CEC_Eco_Level2.shp")
ecoNA <- project(ecoNA, 'WGS84') # project ecoregion vector to same coords ref as basemap

# Create directory for outputed masked rasters
out_dir <- c('./sdm_output/sdm_output_feb_10_2026/masked')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

##### MAIN SPECIES #####
# V. angustifolium masking ------------------------------------------------
# What codes did it exist in historically?
ang_codes <- readRDS('./bg_data/eco_code/eco_ occ_ang_thin _code.rds')

# Subset historical ecoregions
ang_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ang_codes)

# Import suitability rasters
ang_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/ang/ang_pred_hist.rds')
ang_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ang/ang_pred_ssp245_30.rds')
ang_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ang/ang_pred_ssp245_50.rds')
ang_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ang/ang_pred_ssp245_70.rds')
ang_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ang/ang_pred_ssp585_30.rds')
ang_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ang/ang_pred_ssp585_50.rds')
ang_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ang/ang_pred_ssp585_70.rds')

# Import thresholds
ang_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/ang_thresholds_hist.rds')
ang_low <- ang_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ang_pred_hist_low <- ifel(ang_pred_hist >= ang_low, 1, NA)
ang_ssp245_30_low <- ifel(ang_pred_ssp245_30 >= ang_low, 1, NA)
ang_ssp245_50_low <- ifel(ang_pred_ssp245_50 >= ang_low, 1, NA)
ang_ssp245_70_low <- ifel(ang_pred_ssp245_70 >= ang_low, 1, NA)
ang_ssp585_30_low <- ifel(ang_pred_ssp585_30 >= ang_low, 1, NA)
ang_ssp585_50_low <- ifel(ang_pred_ssp585_50 >= ang_low, 1, NA)
ang_ssp585_70_low <- ifel(ang_pred_ssp585_70 >= ang_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(ang_pred_hist_low, main = 'historical')
plot(
  ang_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ang_ssp585_70_low, main = 'ssp585 2070')
plot(
  ang_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(ang_codes)
ang_fut_codes <- c("1.1", "2.4", "2.1")
ang_codes_mask <- c(ang_codes, ang_fut_codes) # combine together

# Build ecoregion mask
ang_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ang_codes_mask)

# Mask all suitability rasters
ang_hist_mask <- terra::crop(ang_pred_hist, ang_eco_mask, mask = T)
ang_ssp245_30_mask <- terra::crop(ang_pred_ssp245_30, ang_eco_mask, mask = T)
ang_ssp245_50_mask <- terra::crop(ang_pred_ssp245_50, ang_eco_mask, mask = T)
ang_ssp245_70_mask <- terra::crop(ang_pred_ssp245_70, ang_eco_mask, mask = T)
ang_ssp585_30_mask <- terra::crop(ang_pred_ssp585_30, ang_eco_mask, mask = T)
ang_ssp585_50_mask <- terra::crop(ang_pred_ssp585_50, ang_eco_mask, mask = T)
ang_ssp585_70_mask <- terra::crop(ang_pred_ssp585_70, ang_eco_mask, mask = T)

# Save all masked rasters
ang_out_dir <- paste0(out_dir, '/ang/')
dir.create(ang_out_dir, showWarnings = FALSE)
saveRDS(ang_hist_mask, paste0(ang_out_dir, 'ang_hist_mask.rds'))
saveRDS(ang_ssp245_30_mask, paste0(ang_out_dir, 'ang_ssp245_30_mask.rds'))
saveRDS(ang_ssp245_50_mask, paste0(ang_out_dir, 'ang_ssp245_50_mask.rds'))
saveRDS(ang_ssp245_70_mask, paste0(ang_out_dir, 'ang_ssp245_70_mask.rds'))
saveRDS(ang_ssp585_30_mask, paste0(ang_out_dir, 'ang_ssp585_30_mask.rds'))
saveRDS(ang_ssp585_50_mask, paste0(ang_out_dir, 'ang_ssp585_50_mask.rds'))
saveRDS(ang_ssp585_70_mask, paste0(ang_out_dir, 'ang_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ang_codes", "ang_eco_hist",
  "ang_pred_hist", "ang_pred_ssp245_30", "ang_pred_ssp245_50", "ang_pred_ssp245_70",
  "ang_pred_ssp585_30", "ang_pred_ssp585_50", "ang_pred_ssp585_70",
  "ang_thresholds", "ang_low",
  "ang_pred_hist_low", "ang_ssp245_30_low", "ang_ssp245_50_low", "ang_ssp245_70_low",
  "ang_ssp585_30_low", "ang_ssp585_50_low", "ang_ssp585_70_low",
  "ang_fut_codes", "ang_codes_mask", "ang_eco_mask",
  "ang_hist_mask", "ang_ssp245_30_mask", "ang_ssp245_50_mask", "ang_ssp245_70_mask",
  "ang_ssp585_30_mask", "ang_ssp585_50_mask", "ang_ssp585_70_mask",
  "ang_out_dir"
))
gc()

# V. arboreum masking -----------------------------------------------------
# What codes did it exist in historically?
arb_codes <- readRDS('./bg_data/eco_code/eco_ occ_arb_thin _code.rds')
print(arb_codes)
# codes: "8.3" "9.4" "8.4" "9.5" "8.5" "9.2"
# Subset historical ecoregions
arb_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% arb_codes)

# Import suitability rasters
arb_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/arb/arb_pred_hist.rds')
arb_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/arb/arb_pred_ssp245_30.rds')
arb_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/arb/arb_pred_ssp245_50.rds')
arb_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/arb/arb_pred_ssp245_70.rds')
arb_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/arb/arb_pred_ssp585_30.rds')
arb_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/arb/arb_pred_ssp585_50.rds')
arb_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/arb/arb_pred_ssp585_70.rds')

# Import thresholds
arb_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/arb_thresholds_hist.rds')
arb_low <- arb_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
arb_pred_hist_low <- ifel(arb_pred_hist >= arb_low, 1, NA)
arb_ssp245_30_low <- ifel(arb_pred_ssp245_30 >= arb_low, 1, NA)
arb_ssp245_50_low <- ifel(arb_pred_ssp245_50 >= arb_low, 1, NA)
arb_ssp245_70_low <- ifel(arb_pred_ssp245_70 >= arb_low, 1, NA)
arb_ssp585_30_low <- ifel(arb_pred_ssp585_30 >= arb_low, 1, NA)
arb_ssp585_50_low <- ifel(arb_pred_ssp585_50 >= arb_low, 1, NA)
arb_ssp585_70_low <- ifel(arb_pred_ssp585_70 >= arb_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(arb_pred_hist_low, main = 'historical')
plot(
  arb_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(arb_ssp585_70_low, main = 'ssp585 2070')
plot(
  arb_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(arb_codes)
arb_fut_codes <- c("5.3", "8.1", "8.2", "5.1")
arb_codes_mask <- c(arb_codes, arb_fut_codes) # combine together

# Build ecoregion mask
arb_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% arb_codes_mask)

# Mask all suitability rasters
arb_hist_mask <- terra::crop(arb_pred_hist, arb_eco_mask, mask = T)
arb_ssp245_30_mask <- terra::crop(arb_pred_ssp245_30, arb_eco_mask, mask = T)
arb_ssp245_50_mask <- terra::crop(arb_pred_ssp245_50, arb_eco_mask, mask = T)
arb_ssp245_70_mask <- terra::crop(arb_pred_ssp245_70, arb_eco_mask, mask = T)
arb_ssp585_30_mask <- terra::crop(arb_pred_ssp585_30, arb_eco_mask, mask = T)
arb_ssp585_50_mask <- terra::crop(arb_pred_ssp585_50, arb_eco_mask, mask = T)
arb_ssp585_70_mask <- terra::crop(arb_pred_ssp585_70, arb_eco_mask, mask = T)

# Save all masked rasters
arb_out_dir <- paste0(out_dir, '/arb/')
dir.create(arb_out_dir, showWarnings = FALSE)
saveRDS(arb_hist_mask, paste0(arb_out_dir, 'arb_hist_mask.rds'))
saveRDS(arb_ssp245_30_mask, paste0(arb_out_dir, 'arb_ssp245_30_mask.rds'))
saveRDS(arb_ssp245_50_mask, paste0(arb_out_dir, 'arb_ssp245_50_mask.rds'))
saveRDS(arb_ssp245_70_mask, paste0(arb_out_dir, 'arb_ssp245_70_mask.rds'))
saveRDS(arb_ssp585_30_mask, paste0(arb_out_dir, 'arb_ssp585_30_mask.rds'))
saveRDS(arb_ssp585_50_mask, paste0(arb_out_dir, 'arb_ssp585_50_mask.rds'))
saveRDS(arb_ssp585_70_mask, paste0(arb_out_dir, 'arb_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "arb_codes", "arb_eco_hist",
  "arb_pred_hist", "arb_pred_ssp245_30", "arb_pred_ssp245_50", "arb_pred_ssp245_70",
  "arb_pred_ssp585_30", "arb_pred_ssp585_50", "arb_pred_ssp585_70",
  "arb_thresholds", "arb_low",
  "arb_pred_hist_low", "arb_ssp245_30_low", "arb_ssp245_50_low", "arb_ssp245_70_low",
  "arb_ssp585_30_low", "arb_ssp585_50_low", "arb_ssp585_70_low",
  "arb_fut_codes", "arb_codes_mask", "arb_eco_mask",
  "arb_hist_mask", "arb_ssp245_30_mask", "arb_ssp245_50_mask", "arb_ssp245_70_mask",
  "arb_ssp585_30_mask", "arb_ssp585_50_mask", "arb_ssp585_70_mask",
  "arb_out_dir"
))
gc()

# V. boreale masking ------------------------------------------------------
# What codes did it exist in historically?
bor_codes <- readRDS('./bg_data/eco_code/eco_ occ_bor_thin _code.rds')

# Subset historical ecoregions
bor_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% bor_codes)

# Import suitability rasters
bor_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/bor/bor_pred_hist.rds')
bor_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/bor/bor_pred_ssp245_30.rds')
bor_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/bor/bor_pred_ssp245_50.rds')
bor_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/bor/bor_pred_ssp245_70.rds')
bor_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/bor/bor_pred_ssp585_30.rds')
bor_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/bor/bor_pred_ssp585_50.rds')
bor_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/bor/bor_pred_ssp585_70.rds')

# Import thresholds
bor_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/bor_thresholds_hist.rds')
bor_low <- bor_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
bor_pred_hist_low <- ifel(bor_pred_hist >= bor_low, 1, NA)
bor_ssp245_30_low <- ifel(bor_pred_ssp245_30 >= bor_low, 1, NA)
bor_ssp245_50_low <- ifel(bor_pred_ssp245_50 >= bor_low, 1, NA)
bor_ssp245_70_low <- ifel(bor_pred_ssp245_70 >= bor_low, 1, NA)
bor_ssp585_30_low <- ifel(bor_pred_ssp585_30 >= bor_low, 1, NA)
bor_ssp585_50_low <- ifel(bor_pred_ssp585_50 >= bor_low, 1, NA)
bor_ssp585_70_low <- ifel(bor_pred_ssp585_70 >= bor_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(bor_pred_hist_low, main = 'historical')
plot(
  bor_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(bor_ssp585_70_low, main = 'ssp585 2070')
plot(
  bor_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(bor_codes)
bor_fut_codes <- c("1.1", "2.4", "2.1", "4.1") # NOTE: added 4.1 as it overlaps under historical suitability
bor_codes_mask <- c(bor_codes, bor_fut_codes) # combine together

# Build ecoregion mask
bor_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% bor_codes_mask)

# Mask all suitability rasters
bor_hist_mask <- terra::crop(bor_pred_hist, bor_eco_mask, mask = T)
bor_ssp245_30_mask <- terra::crop(bor_pred_ssp245_30, bor_eco_mask, mask = T)
bor_ssp245_50_mask <- terra::crop(bor_pred_ssp245_50, bor_eco_mask, mask = T)
bor_ssp245_70_mask <- terra::crop(bor_pred_ssp245_70, bor_eco_mask, mask = T)
bor_ssp585_30_mask <- terra::crop(bor_pred_ssp585_30, bor_eco_mask, mask = T)
bor_ssp585_50_mask <- terra::crop(bor_pred_ssp585_50, bor_eco_mask, mask = T)
bor_ssp585_70_mask <- terra::crop(bor_pred_ssp585_70, bor_eco_mask, mask = T)

# Save all masked rasters
bor_out_dir <- paste0(out_dir, '/bor/')
dir.create(bor_out_dir, showWarnings = FALSE)
saveRDS(bor_hist_mask, paste0(bor_out_dir, 'bor_hist_mask.rds'))
saveRDS(bor_ssp245_30_mask, paste0(bor_out_dir, 'bor_ssp245_30_mask.rds'))
saveRDS(bor_ssp245_50_mask, paste0(bor_out_dir, 'bor_ssp245_50_mask.rds'))
saveRDS(bor_ssp245_70_mask, paste0(bor_out_dir, 'bor_ssp245_70_mask.rds'))
saveRDS(bor_ssp585_30_mask, paste0(bor_out_dir, 'bor_ssp585_30_mask.rds'))
saveRDS(bor_ssp585_50_mask, paste0(bor_out_dir, 'bor_ssp585_50_mask.rds'))
saveRDS(bor_ssp585_70_mask, paste0(bor_out_dir, 'bor_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "bor_codes", "bor_eco_hist",
  "bor_pred_hist", "bor_pred_ssp245_30", "bor_pred_ssp245_50", "bor_pred_ssp245_70",
  "bor_pred_ssp585_30", "bor_pred_ssp585_50", "bor_pred_ssp585_70",
  "bor_thresholds", "bor_low",
  "bor_pred_hist_low", "bor_ssp245_30_low", "bor_ssp245_50_low", "bor_ssp245_70_low",
  "bor_ssp585_30_low", "bor_ssp585_50_low", "bor_ssp585_70_low",
  "bor_fut_codes", "bor_codes_mask", "bor_eco_mask",
  "bor_hist_mask", "bor_ssp245_30_mask", "bor_ssp245_50_mask", "bor_ssp245_70_mask",
  "bor_ssp585_30_mask", "bor_ssp585_50_mask", "bor_ssp585_70_mask",
  "bor_out_dir"
))
gc()

# V. cespitosum masking ---------------------------------------------------
# What codes did it exist in historically?
ces_codes <- readRDS('./bg_data/eco_code/eco_ occ_ces_thin _code.rds')

# Subset historical ecoregions
ces_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ces_codes)

# Import suitability rasters
ces_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/ces/ces_pred_hist.rds')
ces_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ces/ces_pred_ssp245_30.rds')
ces_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ces/ces_pred_ssp245_50.rds')
ces_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ces/ces_pred_ssp245_70.rds')
ces_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ces/ces_pred_ssp585_30.rds')
ces_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ces/ces_pred_ssp585_50.rds')
ces_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ces/ces_pred_ssp585_70.rds')

# Import thresholds
ces_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/ces_thresholds_hist.rds')
ces_low <- ces_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ces_pred_hist_low <- ifel(ces_pred_hist >= ces_low, 1, NA)
ces_ssp245_30_low <- ifel(ces_pred_ssp245_30 >= ces_low, 1, NA)
ces_ssp245_50_low <- ifel(ces_pred_ssp245_50 >= ces_low, 1, NA)
ces_ssp245_70_low <- ifel(ces_pred_ssp245_70 >= ces_low, 1, NA)
ces_ssp585_30_low <- ifel(ces_pred_ssp585_30 >= ces_low, 1, NA)
ces_ssp585_50_low <- ifel(ces_pred_ssp585_50 >= ces_low, 1, NA)
ces_ssp585_70_low <- ifel(ces_pred_ssp585_70 >= ces_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(ces_pred_hist_low, main = 'historical')
plot(
  ces_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ces_ssp585_70_low, main = 'ssp585 2070')
plot(
  ces_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(ces_codes)
ces_fut_codes <- c("8.4", "2.2", "2.3", "3.1", "2.1") # NOTE: 8.4 + 2.2 + 2.3 are also historical
ces_codes_mask <- c(ces_codes, ces_fut_codes) # combine together

# Build ecoregion mask
ces_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ces_codes_mask)

# Mask all suitability rasters
ces_hist_mask <- terra::crop(ces_pred_hist, ces_eco_mask, mask = T)
ces_ssp245_30_mask <- terra::crop(ces_pred_ssp245_30, ces_eco_mask, mask = T)
ces_ssp245_50_mask <- terra::crop(ces_pred_ssp245_50, ces_eco_mask, mask = T)
ces_ssp245_70_mask <- terra::crop(ces_pred_ssp245_70, ces_eco_mask, mask = T)
ces_ssp585_30_mask <- terra::crop(ces_pred_ssp585_30, ces_eco_mask, mask = T)
ces_ssp585_50_mask <- terra::crop(ces_pred_ssp585_50, ces_eco_mask, mask = T)
ces_ssp585_70_mask <- terra::crop(ces_pred_ssp585_70, ces_eco_mask, mask = T)

# Save all masked rasters
ces_out_dir <- paste0(out_dir, '/ces/')
dir.create(ces_out_dir, showWarnings = FALSE)
saveRDS(ces_hist_mask, paste0(ces_out_dir, 'ces_hist_mask.rds'))
saveRDS(ces_ssp245_30_mask, paste0(ces_out_dir, 'ces_ssp245_30_mask.rds'))
saveRDS(ces_ssp245_50_mask, paste0(ces_out_dir, 'ces_ssp245_50_mask.rds'))
saveRDS(ces_ssp245_70_mask, paste0(ces_out_dir, 'ces_ssp245_70_mask.rds'))
saveRDS(ces_ssp585_30_mask, paste0(ces_out_dir, 'ces_ssp585_30_mask.rds'))
saveRDS(ces_ssp585_50_mask, paste0(ces_out_dir, 'ces_ssp585_50_mask.rds'))
saveRDS(ces_ssp585_70_mask, paste0(ces_out_dir, 'ces_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ces_codes", "ces_eco_hist",
  "ces_pred_hist", "ces_pred_ssp245_30", "ces_pred_ssp245_50", "ces_pred_ssp245_70",
  "ces_pred_ssp585_30", "ces_pred_ssp585_50", "ces_pred_ssp585_70",
  "ces_thresholds", "ces_low",
  "ces_pred_hist_low", "ces_ssp245_30_low", "ces_ssp245_50_low", "ces_ssp245_70_low",
  "ces_ssp585_30_low", "ces_ssp585_50_low", "ces_ssp585_70_low",
  "ces_fut_codes", "ces_codes_mask", "ces_eco_mask",
  "ces_hist_mask", "ces_ssp245_30_mask", "ces_ssp245_50_mask", "ces_ssp245_70_mask",
  "ces_ssp585_30_mask", "ces_ssp585_50_mask", "ces_ssp585_70_mask",
  "ces_out_dir"
))
gc()

# V. corymbosum masking ---------------------------------------------------
# What codes did it exist in historically?
cor_codes <- readRDS('./bg_data/eco_code/eco_ occ_cor_thin _code.rds')

# Subset historical ecoregions
cor_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cor_codes)

# Import suitability rasters
cor_pred_hist <- readRDS('./sdm_output/sdm_output_feb_25_2026/cor/cor_pred_hist.rds')
cor_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_25_2026/cor/cor_pred_ssp245_30.rds')
cor_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_25_2026/cor/cor_pred_ssp245_50.rds')
cor_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_25_2026/cor/cor_pred_ssp245_70.rds')
cor_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_25_2026/cor/cor_pred_ssp585_30.rds')
cor_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_25_2026/cor/cor_pred_ssp585_50.rds')
cor_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_25_2026/cor/cor_pred_ssp585_70.rds')

# Import thresholds
cor_thresholds <- readRDS('./sdm_output/sdm_output_feb_25_2026/thresholds/cor_thresholds_hist.rds')
cor_low <- cor_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
cor_pred_hist_low <- ifel(cor_pred_hist >= cor_low, 1, NA)
cor_ssp245_30_low <- ifel(cor_pred_ssp245_30 >= cor_low, 1, NA)
cor_ssp245_50_low <- ifel(cor_pred_ssp245_50 >= cor_low, 1, NA)
cor_ssp245_70_low <- ifel(cor_pred_ssp245_70 >= cor_low, 1, NA)
cor_ssp585_30_low <- ifel(cor_pred_ssp585_30 >= cor_low, 1, NA)
cor_ssp585_50_low <- ifel(cor_pred_ssp585_50 >= cor_low, 1, NA)
cor_ssp585_70_low <- ifel(cor_pred_ssp585_70 >= cor_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(cor_pred_hist_low, main = 'historical')
plot(
  cor_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(cor_ssp585_70_low, main = 'ssp585 2070')
plot(
  cor_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(cor_codes)
cor_fut_codes <- c("4.1", "3.4", "2.4", "1.1") # these codes are good to go!!
cor_codes_mask <- c(cor_codes, cor_fut_codes) # combine together

# Build ecoregion mask
cor_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cor_codes_mask)

# Mask all suitability rasters
cor_hist_mask <- terra::crop(cor_pred_hist, cor_eco_mask, mask = T)
cor_ssp245_30_mask <- terra::crop(cor_pred_ssp245_30, cor_eco_mask, mask = T)
cor_ssp245_50_mask <- terra::crop(cor_pred_ssp245_50, cor_eco_mask, mask = T)
cor_ssp245_70_mask <- terra::crop(cor_pred_ssp245_70, cor_eco_mask, mask = T)
cor_ssp585_30_mask <- terra::crop(cor_pred_ssp585_30, cor_eco_mask, mask = T)
cor_ssp585_50_mask <- terra::crop(cor_pred_ssp585_50, cor_eco_mask, mask = T)
cor_ssp585_70_mask <- terra::crop(cor_pred_ssp585_70, cor_eco_mask, mask = T)

# Save all masked rasters
cor_out_dir <- paste0(out_dir, '/cor/')
dir.create(cor_out_dir, showWarnings = FALSE)
saveRDS(cor_hist_mask, paste0(cor_out_dir, 'cor_hist_mask.rds'))
saveRDS(cor_ssp245_30_mask, paste0(cor_out_dir, 'cor_ssp245_30_mask.rds'))
saveRDS(cor_ssp245_50_mask, paste0(cor_out_dir, 'cor_ssp245_50_mask.rds'))
saveRDS(cor_ssp245_70_mask, paste0(cor_out_dir, 'cor_ssp245_70_mask.rds'))
saveRDS(cor_ssp585_30_mask, paste0(cor_out_dir, 'cor_ssp585_30_mask.rds'))
saveRDS(cor_ssp585_50_mask, paste0(cor_out_dir, 'cor_ssp585_50_mask.rds'))
saveRDS(cor_ssp585_70_mask, paste0(cor_out_dir, 'cor_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "cor_codes", "cor_eco_hist",
  "cor_pred_hist", "cor_pred_ssp245_30", "cor_pred_ssp245_50", "cor_pred_ssp245_70",
  "cor_pred_ssp585_30", "cor_pred_ssp585_50", "cor_pred_ssp585_70",
  "cor_thresholds", "cor_low",
  "cor_pred_hist_low", "cor_ssp245_30_low", "cor_ssp245_50_low", "cor_ssp245_70_low",
  "cor_ssp585_30_low", "cor_ssp585_50_low", "cor_ssp585_70_low",
  "cor_fut_codes", "cor_codes_mask", "cor_eco_mask",
  "cor_hist_mask", "cor_ssp245_30_mask", "cor_ssp245_50_mask", "cor_ssp245_70_mask",
  "cor_ssp585_30_mask", "cor_ssp585_50_mask", "cor_ssp585_70_mask",
  "cor_out_dir"
))
gc()

# V. crassifolium masking -------------------------------------------------
# What codes did it exist in historically?
cra_codes <- readRDS('./bg_data/eco_code/eco_ occ_cra_thin _code.rds')

# Subset historical ecoregions
cra_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cra_codes)

# Import suitability rasters
cra_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/cra/cra_pred_hist.rds')
cra_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/cra/cra_pred_ssp245_30.rds')
cra_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/cra/cra_pred_ssp245_50.rds')
cra_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/cra/cra_pred_ssp245_70.rds')
cra_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/cra/cra_pred_ssp585_30.rds')
cra_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/cra/cra_pred_ssp585_50.rds')
cra_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/cra/cra_pred_ssp585_70.rds')

# Import thresholds
cra_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/cra_thresholds_hist.rds')
cra_low <- cra_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
cra_pred_hist_low <- ifel(cra_pred_hist >= cra_low, 1, NA)
cra_ssp245_30_low <- ifel(cra_pred_ssp245_30 >= cra_low, 1, NA)
cra_ssp245_50_low <- ifel(cra_pred_ssp245_50 >= cra_low, 1, NA)
cra_ssp245_70_low <- ifel(cra_pred_ssp245_70 >= cra_low, 1, NA)
cra_ssp585_30_low <- ifel(cra_pred_ssp585_30 >= cra_low, 1, NA)
cra_ssp585_50_low <- ifel(cra_pred_ssp585_50 >= cra_low, 1, NA)
cra_ssp585_70_low <- ifel(cra_pred_ssp585_70 >= cra_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(cra_pred_hist_low, main = 'historical')
plot(
  cra_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(cra_ssp585_70_low, main = 'ssp585 2070')
plot(
  cra_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(cra_codes)
cra_fut_codes <- c("8.4") # NOTE: Crassifolium's prediction is really strange, 8.4 also historical
cra_codes_mask <- c(cra_codes, cra_fut_codes) # combine together

# Build ecoregion mask
cra_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cra_codes_mask)

# Mask all suitability rasters
cra_hist_mask <- terra::crop(cra_pred_hist, cra_eco_mask, mask = T)
cra_ssp245_30_mask <- terra::crop(cra_pred_ssp245_30, cra_eco_mask, mask = T)
cra_ssp245_50_mask <- terra::crop(cra_pred_ssp245_50, cra_eco_mask, mask = T)
cra_ssp245_70_mask <- terra::crop(cra_pred_ssp245_70, cra_eco_mask, mask = T)
cra_ssp585_30_mask <- terra::crop(cra_pred_ssp585_30, cra_eco_mask, mask = T)
cra_ssp585_50_mask <- terra::crop(cra_pred_ssp585_50, cra_eco_mask, mask = T)
cra_ssp585_70_mask <- terra::crop(cra_pred_ssp585_70, cra_eco_mask, mask = T)

# Save all masked rasters
cra_out_dir <- paste0(out_dir, '/cra/')
dir.create(cra_out_dir, showWarnings = FALSE)
saveRDS(cra_hist_mask, paste0(cra_out_dir, 'cra_hist_mask.rds'))
saveRDS(cra_ssp245_30_mask, paste0(cra_out_dir, 'cra_ssp245_30_mask.rds'))
saveRDS(cra_ssp245_50_mask, paste0(cra_out_dir, 'cra_ssp245_50_mask.rds'))
saveRDS(cra_ssp245_70_mask, paste0(cra_out_dir, 'cra_ssp245_70_mask.rds'))
saveRDS(cra_ssp585_30_mask, paste0(cra_out_dir, 'cra_ssp585_30_mask.rds'))
saveRDS(cra_ssp585_50_mask, paste0(cra_out_dir, 'cra_ssp585_50_mask.rds'))
saveRDS(cra_ssp585_70_mask, paste0(cra_out_dir, 'cra_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "cra_codes", "cra_eco_hist",
  "cra_pred_hist", "cra_pred_ssp245_30", "cra_pred_ssp245_50", "cra_pred_ssp245_70",
  "cra_pred_ssp585_30", "cra_pred_ssp585_50", "cra_pred_ssp585_70",
  "cra_thresholds", "cra_low",
  "cra_pred_hist_low", "cra_ssp245_30_low", "cra_ssp245_50_low", "cra_ssp245_70_low",
  "cra_ssp585_30_low", "cra_ssp585_50_low", "cra_ssp585_70_low",
  "cra_fut_codes", "cra_codes_mask", "cra_eco_mask",
  "cra_hist_mask", "cra_ssp245_30_mask", "cra_ssp245_50_mask", "cra_ssp245_70_mask",
  "cra_ssp585_30_mask", "cra_ssp585_50_mask", "cra_ssp585_70_mask",
  "cra_out_dir"
))
gc()

# V. darrowii masking -----------------------------------------------------
# What codes did it exist in historically?
dar_codes <- readRDS('./bg_data/eco_code/eco_ occ_dar_thin _code.rds')

# Subset historical ecoregions
dar_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% dar_codes)

# Import suitability rasters
dar_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/dar/dar_pred_hist.rds')
dar_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/dar/dar_pred_ssp245_30.rds')
dar_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/dar/dar_pred_ssp245_50.rds')
dar_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/dar/dar_pred_ssp245_70.rds')
dar_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/dar/dar_pred_ssp585_30.rds')
dar_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/dar/dar_pred_ssp585_50.rds')
dar_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/dar/dar_pred_ssp585_70.rds')

# Import thresholds
dar_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/dar_thresholds_hist.rds')
dar_low <- dar_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
dar_pred_hist_low <- ifel(dar_pred_hist >= dar_low, 1, NA)
dar_ssp245_30_low <- ifel(dar_pred_ssp245_30 >= dar_low, 1, NA)
dar_ssp245_50_low <- ifel(dar_pred_ssp245_50 >= dar_low, 1, NA)
dar_ssp245_70_low <- ifel(dar_pred_ssp245_70 >= dar_low, 1, NA)
dar_ssp585_30_low <- ifel(dar_pred_ssp585_30 >= dar_low, 1, NA)
dar_ssp585_50_low <- ifel(dar_pred_ssp585_50 >= dar_low, 1, NA)
dar_ssp585_70_low <- ifel(dar_pred_ssp585_70 >= dar_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(dar_pred_hist_low, main = 'historical')
plot(
  dar_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(dar_ssp585_70_low, main = 'ssp585 2070')
plot(
  dar_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(dar_codes)
dar_fut_codes <- c("9.5", "8.4") # 9.5 + 8.4 also historical
dar_codes_mask <- c(dar_codes, dar_fut_codes) # combine together

# Build ecoregion mask
dar_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% dar_codes_mask)

# Mask all suitability rasters
dar_hist_mask <- terra::crop(dar_pred_hist, dar_eco_mask, mask = T)
dar_ssp245_30_mask <- terra::crop(dar_pred_ssp245_30, dar_eco_mask, mask = T)
dar_ssp245_50_mask <- terra::crop(dar_pred_ssp245_50, dar_eco_mask, mask = T)
dar_ssp245_70_mask <- terra::crop(dar_pred_ssp245_70, dar_eco_mask, mask = T)
dar_ssp585_30_mask <- terra::crop(dar_pred_ssp585_30, dar_eco_mask, mask = T)
dar_ssp585_50_mask <- terra::crop(dar_pred_ssp585_50, dar_eco_mask, mask = T)
dar_ssp585_70_mask <- terra::crop(dar_pred_ssp585_70, dar_eco_mask, mask = T)

# Save all masked rasters
dar_out_dir <- paste0(out_dir, '/dar/')
dir.create(dar_out_dir, showWarnings = FALSE)
saveRDS(dar_hist_mask, paste0(dar_out_dir, 'dar_hist_mask.rds'))
saveRDS(dar_ssp245_30_mask, paste0(dar_out_dir, 'dar_ssp245_30_mask.rds'))
saveRDS(dar_ssp245_50_mask, paste0(dar_out_dir, 'dar_ssp245_50_mask.rds'))
saveRDS(dar_ssp245_70_mask, paste0(dar_out_dir, 'dar_ssp245_70_mask.rds'))
saveRDS(dar_ssp585_30_mask, paste0(dar_out_dir, 'dar_ssp585_30_mask.rds'))
saveRDS(dar_ssp585_50_mask, paste0(dar_out_dir, 'dar_ssp585_50_mask.rds'))
saveRDS(dar_ssp585_70_mask, paste0(dar_out_dir, 'dar_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "dar_codes", "dar_eco_hist",
  "dar_pred_hist", "dar_pred_ssp245_30", "dar_pred_ssp245_50", "dar_pred_ssp245_70",
  "dar_pred_ssp585_30", "dar_pred_ssp585_50", "dar_pred_ssp585_70",
  "dar_thresholds", "dar_low",
  "dar_pred_hist_low", "dar_ssp245_30_low", "dar_ssp245_50_low", "dar_ssp245_70_low",
  "dar_ssp585_30_low", "dar_ssp585_50_low", "dar_ssp585_70_low",
  "dar_fut_codes", "dar_codes_mask", "dar_eco_mask",
  "dar_hist_mask", "dar_ssp245_30_mask", "dar_ssp245_50_mask", "dar_ssp245_70_mask",
  "dar_ssp585_30_mask", "dar_ssp585_50_mask", "dar_ssp585_70_mask",
  "dar_out_dir"
))
gc()

# V. deliciosum masking ---------------------------------------------------
# What codes did it exist in historically?
del_codes <- readRDS('./bg_data/eco_code/eco_ occ_del_thin _code.rds')

# Subset historical ecoregions
del_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% del_codes)

# Import suitability rasters
del_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/del/del_pred_hist.rds')
del_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/del/del_pred_ssp245_30.rds')
del_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/del/del_pred_ssp245_50.rds')
del_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/del/del_pred_ssp245_70.rds')
del_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/del/del_pred_ssp585_30.rds')
del_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/del/del_pred_ssp585_50.rds')
del_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/del/del_pred_ssp585_70.rds')

# Import thresholds
del_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/del_thresholds_hist.rds')
del_low <- del_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
del_pred_hist_low <- ifel(del_pred_hist >= del_low, 1, NA)
del_ssp245_30_low <- ifel(del_pred_ssp245_30 >= del_low, 1, NA)
del_ssp245_50_low <- ifel(del_pred_ssp245_50 >= del_low, 1, NA)
del_ssp245_70_low <- ifel(del_pred_ssp245_70 >= del_low, 1, NA)
del_ssp585_30_low <- ifel(del_pred_ssp585_30 >= del_low, 1, NA)
del_ssp585_50_low <- ifel(del_pred_ssp585_50 >= del_low, 1, NA)
del_ssp585_70_low <- ifel(del_pred_ssp585_70 >= del_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(del_pred_hist_low, main = 'historical')
plot(
  del_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(del_ssp585_70_low, main = 'ssp585 2070')
plot(
  del_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(del_codes)
del_fut_codes <- c("13.1", "9.4", "2.2", "5.4", "6.1", "3.1") # all also historical, except 3.1
del_codes_mask <- c(del_codes, del_fut_codes) # combine together

# Build ecoregion mask
del_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% del_codes_mask)

# Mask all suitability rasters
del_hist_mask <- terra::crop(del_pred_hist, del_eco_mask, mask = T)
del_ssp245_30_mask <- terra::crop(del_pred_ssp245_30, del_eco_mask, mask = T)
del_ssp245_50_mask <- terra::crop(del_pred_ssp245_50, del_eco_mask, mask = T)
del_ssp245_70_mask <- terra::crop(del_pred_ssp245_70, del_eco_mask, mask = T)
del_ssp585_30_mask <- terra::crop(del_pred_ssp585_30, del_eco_mask, mask = T)
del_ssp585_50_mask <- terra::crop(del_pred_ssp585_50, del_eco_mask, mask = T)
del_ssp585_70_mask <- terra::crop(del_pred_ssp585_70, del_eco_mask, mask = T)

# Save all masked rasters
del_out_dir <- paste0(out_dir, '/del/')
dir.create(del_out_dir, showWarnings = FALSE)
saveRDS(del_hist_mask, paste0(del_out_dir, 'del_hist_mask.rds'))
saveRDS(del_ssp245_30_mask, paste0(del_out_dir, 'del_ssp245_30_mask.rds'))
saveRDS(del_ssp245_50_mask, paste0(del_out_dir, 'del_ssp245_50_mask.rds'))
saveRDS(del_ssp245_70_mask, paste0(del_out_dir, 'del_ssp245_70_mask.rds'))
saveRDS(del_ssp585_30_mask, paste0(del_out_dir, 'del_ssp585_30_mask.rds'))
saveRDS(del_ssp585_50_mask, paste0(del_out_dir, 'del_ssp585_50_mask.rds'))
saveRDS(del_ssp585_70_mask, paste0(del_out_dir, 'del_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "del_codes", "del_eco_hist",
  "del_pred_hist", "del_pred_ssp245_30", "del_pred_ssp245_50", "del_pred_ssp245_70",
  "del_pred_ssp585_30", "del_pred_ssp585_50", "del_pred_ssp585_70",
  "del_thresholds", "del_low",
  "del_pred_hist_low", "del_ssp245_30_low", "del_ssp245_50_low", "del_ssp245_70_low",
  "del_ssp585_30_low", "del_ssp585_50_low", "del_ssp585_70_low",
  "del_fut_codes", "del_codes_mask", "del_eco_mask",
  "del_hist_mask", "del_ssp245_30_mask", "del_ssp245_50_mask", "del_ssp245_70_mask",
  "del_ssp585_30_mask", "del_ssp585_50_mask", "del_ssp585_70_mask",
  "del_out_dir"
))
gc()

# V. erythrocarpum masking ------------------------------------------------
# What codes did it exist in historically?
ery_codes <- readRDS('./bg_data/eco_code/eco_ occ_ery_thin _code.rds')

# Subset historical ecoregions
ery_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ery_codes)

# Import suitability rasters
ery_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/ery/ery_pred_hist.rds')
ery_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ery/ery_pred_ssp245_30.rds')
ery_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ery/ery_pred_ssp245_50.rds')
ery_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ery/ery_pred_ssp245_70.rds')
ery_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ery/ery_pred_ssp585_30.rds')
ery_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ery/ery_pred_ssp585_50.rds')
ery_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ery/ery_pred_ssp585_70.rds')

# Import thresholds
ery_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/ery_thresholds_hist.rds')
ery_low <- ery_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ery_pred_hist_low <- ifel(ery_pred_hist >= ery_low, 1, NA)
ery_ssp245_30_low <- ifel(ery_pred_ssp245_30 >= ery_low, 1, NA)
ery_ssp245_50_low <- ifel(ery_pred_ssp245_50 >= ery_low, 1, NA)
ery_ssp245_70_low <- ifel(ery_pred_ssp245_70 >= ery_low, 1, NA)
ery_ssp585_30_low <- ifel(ery_pred_ssp585_30 >= ery_low, 1, NA)
ery_ssp585_50_low <- ifel(ery_pred_ssp585_50 >= ery_low, 1, NA)
ery_ssp585_70_low <- ifel(ery_pred_ssp585_70 >= ery_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) # reset default par
terra::plot(ery_pred_hist_low, main = 'historical')
plot(
  ery_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ery_ssp585_70_low, main = 'ssp585 2070')
plot(
  ery_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)


# Codes to add to historical
print(ery_codes)
ery_fut_codes <- c() # no ecoregions added! There is only suitability up in the northeast coast of NU
ery_codes_mask <- c(ery_codes, ery_fut_codes) # combine together

# Build ecoregion mask
ery_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ery_codes_mask)

# Mask all suitability rasters
ery_hist_mask <- terra::crop(ery_pred_hist, ery_eco_mask, mask = T)
ery_ssp245_30_mask <- terra::crop(ery_pred_ssp245_30, ery_eco_mask, mask = T)
ery_ssp245_50_mask <- terra::crop(ery_pred_ssp245_50, ery_eco_mask, mask = T)
ery_ssp245_70_mask <- terra::crop(ery_pred_ssp245_70, ery_eco_mask, mask = T)
ery_ssp585_30_mask <- terra::crop(ery_pred_ssp585_30, ery_eco_mask, mask = T)
ery_ssp585_50_mask <- terra::crop(ery_pred_ssp585_50, ery_eco_mask, mask = T)
ery_ssp585_70_mask <- terra::crop(ery_pred_ssp585_70, ery_eco_mask, mask = T)

# Save all masked rasters
ery_out_dir <- paste0(out_dir, '/ery/')
dir.create(ery_out_dir, showWarnings = FALSE)
saveRDS(ery_hist_mask, paste0(ery_out_dir, 'ery_hist_mask.rds'))
saveRDS(ery_ssp245_30_mask, paste0(ery_out_dir, 'ery_ssp245_30_mask.rds'))
saveRDS(ery_ssp245_50_mask, paste0(ery_out_dir, 'ery_ssp245_50_mask.rds'))
saveRDS(ery_ssp245_70_mask, paste0(ery_out_dir, 'ery_ssp245_70_mask.rds'))
saveRDS(ery_ssp585_30_mask, paste0(ery_out_dir, 'ery_ssp585_30_mask.rds'))
saveRDS(ery_ssp585_50_mask, paste0(ery_out_dir, 'ery_ssp585_50_mask.rds'))
saveRDS(ery_ssp585_70_mask, paste0(ery_out_dir, 'ery_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ery_codes", "ery_eco_hist",
  "ery_pred_hist", "ery_pred_ssp245_30", "ery_pred_ssp245_50", "ery_pred_ssp245_70",
  "ery_pred_ssp585_30", "ery_pred_ssp585_50", "ery_pred_ssp585_70",
  "ery_thresholds", "ery_low",
  "ery_pred_hist_low", "ery_ssp245_30_low", "ery_ssp245_50_low", "ery_ssp245_70_low",
  "ery_ssp585_30_low", "ery_ssp585_50_low", "ery_ssp585_70_low",
  "ery_fut_codes", "ery_codes_mask", "ery_eco_mask",
  "ery_hist_mask", "ery_ssp245_30_mask", "ery_ssp245_50_mask", "ery_ssp245_70_mask",
  "ery_ssp585_30_mask", "ery_ssp585_50_mask", "ery_ssp585_70_mask",
  "ery_out_dir"
))
gc()

# V. geminiflorum masking -------------------------------------------------
# What codes did it exist in historically?
gem_codes <- readRDS('./bg_data/eco_code/eco_ occ_gem_thin _code.rds')

# Subset historical ecoregions
gem_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% gem_codes)

# Import suitability rasters
gem_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/gem/gem_pred_hist.rds')
gem_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/gem/gem_pred_ssp245_30.rds')
gem_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/gem/gem_pred_ssp245_50.rds')
gem_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/gem/gem_pred_ssp245_70.rds')
gem_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/gem/gem_pred_ssp585_30.rds')
gem_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/gem/gem_pred_ssp585_50.rds')
gem_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/gem/gem_pred_ssp585_70.rds')

# Import thresholds
gem_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/gem_thresholds_hist.rds')
gem_low <- gem_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
gem_pred_hist_low <- ifel(gem_pred_hist >= gem_low, 1, NA)
gem_ssp245_30_low <- ifel(gem_pred_ssp245_30 >= gem_low, 1, NA)
gem_ssp245_50_low <- ifel(gem_pred_ssp245_50 >= gem_low, 1, NA)
gem_ssp245_70_low <- ifel(gem_pred_ssp245_70 >= gem_low, 1, NA)
gem_ssp585_30_low <- ifel(gem_pred_ssp585_30 >= gem_low, 1, NA)
gem_ssp585_50_low <- ifel(gem_pred_ssp585_50 >= gem_low, 1, NA)
gem_ssp585_70_low <- ifel(gem_pred_ssp585_70 >= gem_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(gem_pred_hist_low, main = 'historical')
plot(
  gem_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(gem_ssp585_70_low, main = 'ssp585 2070')
plot(
  gem_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(gem_codes)
gem_fut_codes <- c() # No new ecoregions to add. Note that there is other patches just north of its historical region but it looks suprious to add to historical mask
gem_codes_mask <- c(gem_codes, gem_fut_codes) # combine together

# Build ecoregion mask
gem_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% gem_codes_mask)

# Mask all suitability rasters
gem_hist_mask <- terra::crop(gem_pred_hist, gem_eco_mask, mask = T)
gem_ssp245_30_mask <- terra::crop(gem_pred_ssp245_30, gem_eco_mask, mask = T)
gem_ssp245_50_mask <- terra::crop(gem_pred_ssp245_50, gem_eco_mask, mask = T)
gem_ssp245_70_mask <- terra::crop(gem_pred_ssp245_70, gem_eco_mask, mask = T)
gem_ssp585_30_mask <- terra::crop(gem_pred_ssp585_30, gem_eco_mask, mask = T)
gem_ssp585_50_mask <- terra::crop(gem_pred_ssp585_50, gem_eco_mask, mask = T)
gem_ssp585_70_mask <- terra::crop(gem_pred_ssp585_70, gem_eco_mask, mask = T)

# Save all masked rasters
gem_out_dir <- paste0(out_dir, '/gem/')
dir.create(gem_out_dir, showWarnings = FALSE)
saveRDS(gem_hist_mask, paste0(gem_out_dir, 'gem_hist_mask.rds'))
saveRDS(gem_ssp245_30_mask, paste0(gem_out_dir, 'gem_ssp245_30_mask.rds'))
saveRDS(gem_ssp245_50_mask, paste0(gem_out_dir, 'gem_ssp245_50_mask.rds'))
saveRDS(gem_ssp245_70_mask, paste0(gem_out_dir, 'gem_ssp245_70_mask.rds'))
saveRDS(gem_ssp585_30_mask, paste0(gem_out_dir, 'gem_ssp585_30_mask.rds'))
saveRDS(gem_ssp585_50_mask, paste0(gem_out_dir, 'gem_ssp585_50_mask.rds'))
saveRDS(gem_ssp585_70_mask, paste0(gem_out_dir, 'gem_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "gem_codes", "gem_eco_hist",
  "gem_pred_hist", "gem_pred_ssp245_30", "gem_pred_ssp245_50", "gem_pred_ssp245_70",
  "gem_pred_ssp585_30", "gem_pred_ssp585_50", "gem_pred_ssp585_70",
  "gem_thresholds", "gem_low",
  "gem_pred_hist_low", "gem_ssp245_30_low", "gem_ssp245_50_low", "gem_ssp245_70_low",
  "gem_ssp585_30_low", "gem_ssp585_50_low", "gem_ssp585_70_low",
  "gem_fut_codes", "gem_codes_mask", "gem_eco_mask",
  "gem_hist_mask", "gem_ssp245_30_mask", "gem_ssp245_50_mask", "gem_ssp245_70_mask",
  "gem_ssp585_30_mask", "gem_ssp585_50_mask", "gem_ssp585_70_mask",
  "gem_out_dir"
))
gc()

# V. hirsutum masking -----------------------------------------------------
# What codes did it exist in historically?
hir_codes <- readRDS('./bg_data/eco_code/eco_ occ_hir_thin _code.rds')

# Subset historical ecoregions
hir_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% hir_codes)

# Import suitability rasters
hir_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/hir/hir_pred_hist.rds')
hir_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/hir/hir_pred_ssp245_30.rds')
hir_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/hir/hir_pred_ssp245_50.rds')
hir_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/hir/hir_pred_ssp245_70.rds')
hir_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/hir/hir_pred_ssp585_30.rds')
hir_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/hir/hir_pred_ssp585_50.rds')
hir_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/hir/hir_pred_ssp585_70.rds')

# Import thresholds
hir_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/hir_thresholds_hist.rds')
hir_low <- hir_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
hir_pred_hist_low <- ifel(hir_pred_hist >= hir_low, 1, NA)
hir_ssp245_30_low <- ifel(hir_pred_ssp245_30 >= hir_low, 1, NA)
hir_ssp245_50_low <- ifel(hir_pred_ssp245_50 >= hir_low, 1, NA)
hir_ssp245_70_low <- ifel(hir_pred_ssp245_70 >= hir_low, 1, NA)
hir_ssp585_30_low <- ifel(hir_pred_ssp585_30 >= hir_low, 1, NA)
hir_ssp585_50_low <- ifel(hir_pred_ssp585_50 >= hir_low, 1, NA)
hir_ssp585_70_low <- ifel(hir_pred_ssp585_70 >= hir_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(hir_pred_hist_low, main = 'historical')
plot(
  hir_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(hir_ssp585_70_low, main = 'ssp585 2070')
plot(
  hir_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(hir_codes)
hir_fut_codes <- c() # no codes to add... no hope for this sp
hir_codes_mask <- c(hir_codes, hir_fut_codes) # combine together

# Build ecoregion mask
hir_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% hir_codes_mask)

# Mask all suitability rasters
hir_hist_mask <- terra::crop(hir_pred_hist, hir_eco_mask, mask = T)
hir_ssp245_30_mask <- terra::crop(hir_pred_ssp245_30, hir_eco_mask, mask = T)
hir_ssp245_50_mask <- terra::crop(hir_pred_ssp245_50, hir_eco_mask, mask = T)
hir_ssp245_70_mask <- terra::crop(hir_pred_ssp245_70, hir_eco_mask, mask = T)
hir_ssp585_30_mask <- terra::crop(hir_pred_ssp585_30, hir_eco_mask, mask = T)
hir_ssp585_50_mask <- terra::crop(hir_pred_ssp585_50, hir_eco_mask, mask = T)
hir_ssp585_70_mask <- terra::crop(hir_pred_ssp585_70, hir_eco_mask, mask = T)

# Save all masked rasters
hir_out_dir <- paste0(out_dir, '/hir/')
dir.create(hir_out_dir, showWarnings = FALSE)
saveRDS(hir_hist_mask, paste0(hir_out_dir, 'hir_hist_mask.rds'))
saveRDS(hir_ssp245_30_mask, paste0(hir_out_dir, 'hir_ssp245_30_mask.rds'))
saveRDS(hir_ssp245_50_mask, paste0(hir_out_dir, 'hir_ssp245_50_mask.rds'))
saveRDS(hir_ssp245_70_mask, paste0(hir_out_dir, 'hir_ssp245_70_mask.rds'))
saveRDS(hir_ssp585_30_mask, paste0(hir_out_dir, 'hir_ssp585_30_mask.rds'))
saveRDS(hir_ssp585_50_mask, paste0(hir_out_dir, 'hir_ssp585_50_mask.rds'))
saveRDS(hir_ssp585_70_mask, paste0(hir_out_dir, 'hir_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "hir_codes", "hir_eco_hist",
  "hir_pred_hist", "hir_pred_ssp245_30", "hir_pred_ssp245_50", "hir_pred_ssp245_70",
  "hir_pred_ssp585_30", "hir_pred_ssp585_50", "hir_pred_ssp585_70",
  "hir_thresholds", "hir_low",
  "hir_pred_hist_low", "hir_ssp245_30_low", "hir_ssp245_50_low", "hir_ssp245_70_low",
  "hir_ssp585_30_low", "hir_ssp585_50_low", "hir_ssp585_70_low",
  "hir_fut_codes", "hir_codes_mask", "hir_eco_mask",
  "hir_hist_mask", "hir_ssp245_30_mask", "hir_ssp245_50_mask", "hir_ssp245_70_mask",
  "hir_ssp585_30_mask", "hir_ssp585_50_mask", "hir_ssp585_70_mask",
  "hir_out_dir"
))
gc()

# V. macrocarpon ----------------------------------------------------------
# Need to rerun macrocarpon model without west coast occ!!
# What codes did it exist in historically?
mac_codes <- readRDS('./bg_data/eco_code/eco_ occ_mac_thin _code.rds')

# Subset historical ecoregions
mac_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mac_codes)

# Import suitability rasters
mac_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/mac/mac_pred_hist.rds')
mac_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mac/mac_pred_ssp245_30.rds')
mac_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mac/mac_pred_ssp245_50.rds')
mac_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mac/mac_pred_ssp245_70.rds')
mac_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mac/mac_pred_ssp585_30.rds')
mac_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mac/mac_pred_ssp585_50.rds')
mac_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mac/mac_pred_ssp585_70.rds')

# Import thresholds
mac_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/mac_thresholds_hist.rds')
mac_low <- mac_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
mac_pred_hist_low <- ifel(mac_pred_hist >= mac_low, 1, NA)
mac_ssp245_30_low <- ifel(mac_pred_ssp245_30 >= mac_low, 1, NA)
mac_ssp245_50_low <- ifel(mac_pred_ssp245_50 >= mac_low, 1, NA)
mac_ssp245_70_low <- ifel(mac_pred_ssp245_70 >= mac_low, 1, NA)
mac_ssp585_30_low <- ifel(mac_pred_ssp585_30 >= mac_low, 1, NA)
mac_ssp585_50_low <- ifel(mac_pred_ssp585_50 >= mac_low, 1, NA)
mac_ssp585_70_low <- ifel(mac_pred_ssp585_70 >= mac_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(mac_pred_hist_low, main = 'historical')
plot(
  mac_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(mac_ssp585_70_low, main = 'ssp585 2070')
plot(
  mac_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(mac_codes)
mac_fut_codes <- c("1.1", "2.4", "2.1")
mac_codes_mask <- c(mac_codes, mac_fut_codes) # combine together

# Build ecoregion mask
mac_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mac_codes_mask)

# Mask all suitability rasters
mac_hist_mask <- terra::crop(mac_pred_hist, mac_eco_mask, mask = T)
mac_ssp245_30_mask <- terra::crop(mac_pred_ssp245_30, mac_eco_mask, mask = T)
mac_ssp245_50_mask <- terra::crop(mac_pred_ssp245_50, mac_eco_mask, mask = T)
mac_ssp245_70_mask <- terra::crop(mac_pred_ssp245_70, mac_eco_mask, mask = T)
mac_ssp585_30_mask <- terra::crop(mac_pred_ssp585_30, mac_eco_mask, mask = T)
mac_ssp585_50_mask <- terra::crop(mac_pred_ssp585_50, mac_eco_mask, mask = T)
mac_ssp585_70_mask <- terra::crop(mac_pred_ssp585_70, mac_eco_mask, mask = T)

# Save all masked rasters
mac_out_dir <- paste0(out_dir, '/mac/')
dir.create(mac_out_dir, showWarnings = FALSE)
saveRDS(mac_hist_mask, paste0(mac_out_dir, 'mac_hist_mask.rds'))
saveRDS(mac_ssp245_30_mask, paste0(mac_out_dir, 'mac_ssp245_30_mask.rds'))
saveRDS(mac_ssp245_50_mask, paste0(mac_out_dir, 'mac_ssp245_50_mask.rds'))
saveRDS(mac_ssp245_70_mask, paste0(mac_out_dir, 'mac_ssp245_70_mask.rds'))
saveRDS(mac_ssp585_30_mask, paste0(mac_out_dir, 'mac_ssp585_30_mask.rds'))
saveRDS(mac_ssp585_50_mask, paste0(mac_out_dir, 'mac_ssp585_50_mask.rds'))
saveRDS(mac_ssp585_70_mask, paste0(mac_out_dir, 'mac_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "mac_codes", "mac_eco_hist",
  "mac_pred_hist", "mac_pred_ssp245_30", "mac_pred_ssp245_50", "mac_pred_ssp245_70",
  "mac_pred_ssp585_30", "mac_pred_ssp585_50", "mac_pred_ssp585_70",
  "mac_thresholds", "mac_low",
  "mac_pred_hist_low", "mac_ssp245_30_low", "mac_ssp245_50_low", "mac_ssp245_70_low",
  "mac_ssp585_30_low", "mac_ssp585_50_low", "mac_ssp585_70_low",
  "mac_fut_codes", "mac_codes_mask", "mac_eco_mask",
  "mac_hist_mask", "mac_ssp245_30_mask", "mac_ssp245_50_mask", "mac_ssp245_70_mask",
  "mac_ssp585_30_mask", "mac_ssp585_50_mask", "mac_ssp585_70_mask",
  "mac_out_dir"
))
gc()

# V. membranaceum masking -------------------------------------------------
# What codes did it exist in historically?
mem_codes <- readRDS('./bg_data/eco_code/eco_ occ_mem_thin _code.rds')

# Subset historical ecoregions
mem_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mem_codes)

# Import suitability rasters
mem_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/mem/mem_pred_hist.rds')
mem_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mem/mem_pred_ssp245_30.rds')
mem_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mem/mem_pred_ssp245_50.rds')
mem_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mem/mem_pred_ssp245_70.rds')
mem_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mem/mem_pred_ssp585_30.rds')
mem_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mem/mem_pred_ssp585_50.rds')
mem_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mem/mem_pred_ssp585_70.rds')

# Import thresholds
mem_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/mem_thresholds_hist.rds')
mem_low <- mem_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
mem_pred_hist_low <- ifel(mem_pred_hist >= mem_low, 1, NA)
mem_ssp245_30_low <- ifel(mem_pred_ssp245_30 >= mem_low, 1, NA)
mem_ssp245_50_low <- ifel(mem_pred_ssp245_50 >= mem_low, 1, NA)
mem_ssp245_70_low <- ifel(mem_pred_ssp245_70 >= mem_low, 1, NA)
mem_ssp585_30_low <- ifel(mem_pred_ssp585_30 >= mem_low, 1, NA)
mem_ssp585_50_low <- ifel(mem_pred_ssp585_50 >= mem_low, 1, NA)
mem_ssp585_70_low <- ifel(mem_pred_ssp585_70 >= mem_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(mem_pred_hist_low, main = 'historical')
plot(
  mem_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(mem_ssp585_70_low, main = 'ssp585 2070')
plot(
  mem_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(mem_codes)
mem_fut_codes <- c("2.2", "3.1")
mem_codes_mask <- c(mem_codes, mem_fut_codes) # combine together
# NOTE: nask eco 5.1! This ecoregion contains occurrences on the north shore of Lake Supperior of North Ontario
# suitability is predicted there in the <=1st percentile, but trimming it from the species raster,
# due to the fact this ecoregion spans a large span across the Canadian Sheild which also contains 
# Newfoundland and spurious suitability predicted there and in the Canadian North
mem_codes_drop5.1 <- gsub("5.1", "", mem_codes_mask)

# Build ecoregion mask
mem_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mem_codes_drop5.1)

# Mask all suitability rasters
mem_hist_mask <- terra::crop(mem_pred_hist, mem_eco_mask, mask = T)
mem_ssp245_30_mask <- terra::crop(mem_pred_ssp245_30, mem_eco_mask, mask = T)
mem_ssp245_50_mask <- terra::crop(mem_pred_ssp245_50, mem_eco_mask, mask = T)
mem_ssp245_70_mask <- terra::crop(mem_pred_ssp245_70, mem_eco_mask, mask = T)
mem_ssp585_30_mask <- terra::crop(mem_pred_ssp585_30, mem_eco_mask, mask = T)
mem_ssp585_50_mask <- terra::crop(mem_pred_ssp585_50, mem_eco_mask, mask = T)
mem_ssp585_70_mask <- terra::crop(mem_pred_ssp585_70, mem_eco_mask, mask = T)

# Save all masked rasters
mem_out_dir <- paste0(out_dir, '/mem/')
dir.create(mem_out_dir, showWarnings = FALSE)
saveRDS(mem_hist_mask, paste0(mem_out_dir, 'mem_hist_mask.rds'))
saveRDS(mem_ssp245_30_mask, paste0(mem_out_dir, 'mem_ssp245_30_mask.rds'))
saveRDS(mem_ssp245_50_mask, paste0(mem_out_dir, 'mem_ssp245_50_mask.rds'))
saveRDS(mem_ssp245_70_mask, paste0(mem_out_dir, 'mem_ssp245_70_mask.rds'))
saveRDS(mem_ssp585_30_mask, paste0(mem_out_dir, 'mem_ssp585_30_mask.rds'))
saveRDS(mem_ssp585_50_mask, paste0(mem_out_dir, 'mem_ssp585_50_mask.rds'))
saveRDS(mem_ssp585_70_mask, paste0(mem_out_dir, 'mem_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "mem_codes", "mem_eco_hist",
  "mem_pred_hist", "mem_pred_ssp245_30", "mem_pred_ssp245_50", "mem_pred_ssp245_70",
  "mem_pred_ssp585_30", "mem_pred_ssp585_50", "mem_pred_ssp585_70",
  "mem_thresholds", "mem_low",
  "mem_pred_hist_low", "mem_ssp245_30_low", "mem_ssp245_50_low", "mem_ssp245_70_low",
  "mem_ssp585_30_low", "mem_ssp585_50_low", "mem_ssp585_70_low",
  "mem_fut_codes", "mem_codes_mask", "mem_eco_mask",
  "mem_hist_mask", "mem_ssp245_30_mask", "mem_ssp245_50_mask", "mem_ssp245_70_mask",
  "mem_ssp585_30_mask", "mem_ssp585_50_mask", "mem_ssp585_70_mask",
  "mem_out_dir"
))
gc()

# V. myrtillus masking ----------------------------------------------------
# What codes did it exist in historically?
mtu_codes <- readRDS('./bg_data/eco_code/eco_ occ_mtu_thin _code.rds')

# Subset historical ecoregions
mtu_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mtu_codes)

# Import suitability rasters
mtu_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/mtu/mtu_pred_hist.rds')
mtu_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mtu/mtu_pred_ssp245_30.rds')
mtu_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mtu/mtu_pred_ssp245_50.rds')
mtu_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mtu/mtu_pred_ssp245_70.rds')
mtu_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mtu/mtu_pred_ssp585_30.rds')
mtu_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mtu/mtu_pred_ssp585_50.rds')
mtu_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mtu/mtu_pred_ssp585_70.rds')

# Import thresholds
mtu_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/mtu_thresholds_hist.rds')
mtu_low <- mtu_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
mtu_pred_hist_low <- ifel(mtu_pred_hist >= mtu_low, 1, NA)
mtu_ssp245_30_low <- ifel(mtu_pred_ssp245_30 >= mtu_low, 1, NA)
mtu_ssp245_50_low <- ifel(mtu_pred_ssp245_50 >= mtu_low, 1, NA)
mtu_ssp245_70_low <- ifel(mtu_pred_ssp245_70 >= mtu_low, 1, NA)
mtu_ssp585_30_low <- ifel(mtu_pred_ssp585_30 >= mtu_low, 1, NA)
mtu_ssp585_50_low <- ifel(mtu_pred_ssp585_50 >= mtu_low, 1, NA)
mtu_ssp585_70_low <- ifel(mtu_pred_ssp585_70 >= mtu_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(mtu_pred_hist_low, main = 'historical')
plot(
  mtu_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(mtu_ssp585_70_low, main = 'ssp585 2070')
plot(
  mtu_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(mtu_codes)
mtu_fut_codes <- c("6.1", "2.2", "2.3", "3.1") # also contains historical suitability
mtu_codes_mask <- c(mtu_codes, mtu_fut_codes) # combine together

# Build ecoregion mask
mtu_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mtu_codes_mask)

# Mask all suitability rasters
mtu_hist_mask <- terra::crop(mtu_pred_hist, mtu_eco_mask, mask = T)
mtu_ssp245_30_mask <- terra::crop(mtu_pred_ssp245_30, mtu_eco_mask, mask = T)
mtu_ssp245_50_mask <- terra::crop(mtu_pred_ssp245_50, mtu_eco_mask, mask = T)
mtu_ssp245_70_mask <- terra::crop(mtu_pred_ssp245_70, mtu_eco_mask, mask = T)
mtu_ssp585_30_mask <- terra::crop(mtu_pred_ssp585_30, mtu_eco_mask, mask = T)
mtu_ssp585_50_mask <- terra::crop(mtu_pred_ssp585_50, mtu_eco_mask, mask = T)
mtu_ssp585_70_mask <- terra::crop(mtu_pred_ssp585_70, mtu_eco_mask, mask = T)

# Save all masked rasters
mtu_out_dir <- paste0(out_dir, '/mtu/')
dir.create(mtu_out_dir, showWarnings = FALSE)
saveRDS(mtu_hist_mask, paste0(mtu_out_dir, 'mtu_hist_mask.rds'))
saveRDS(mtu_ssp245_30_mask, paste0(mtu_out_dir, 'mtu_ssp245_30_mask.rds'))
saveRDS(mtu_ssp245_50_mask, paste0(mtu_out_dir, 'mtu_ssp245_50_mask.rds'))
saveRDS(mtu_ssp245_70_mask, paste0(mtu_out_dir, 'mtu_ssp245_70_mask.rds'))
saveRDS(mtu_ssp585_30_mask, paste0(mtu_out_dir, 'mtu_ssp585_30_mask.rds'))
saveRDS(mtu_ssp585_50_mask, paste0(mtu_out_dir, 'mtu_ssp585_50_mask.rds'))
saveRDS(mtu_ssp585_70_mask, paste0(mtu_out_dir, 'mtu_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "mtu_codes", "mtu_eco_hist",
  "mtu_pred_hist", "mtu_pred_ssp245_30", "mtu_pred_ssp245_50", "mtu_pred_ssp245_70",
  "mtu_pred_ssp585_30", "mtu_pred_ssp585_50", "mtu_pred_ssp585_70",
  "mtu_thresholds", "mtu_low",
  "mtu_pred_hist_low", "mtu_ssp245_30_low", "mtu_ssp245_50_low", "mtu_ssp245_70_low",
  "mtu_ssp585_30_low", "mtu_ssp585_50_low", "mtu_ssp585_70_low",
  "mtu_fut_codes", "mtu_codes_mask", "mtu_eco_mask",
  "mtu_hist_mask", "mtu_ssp245_30_mask", "mtu_ssp245_50_mask", "mtu_ssp245_70_mask",
  "mtu_ssp585_30_mask", "mtu_ssp585_50_mask", "mtu_ssp585_70_mask",
  "mtu_out_dir"
))
gc()

# V. myrtilloides masking -------------------------------------------------
# What codes did it exist in historically?
myr_codes <- readRDS('./bg_data/eco_code/eco_ occ_myr_thin _code.rds')

# Subset historical ecoregions
myr_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% myr_codes)

# Import suitability rasters
myr_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/myr/myr_pred_hist.rds')
myr_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/myr/myr_pred_ssp245_30.rds')
myr_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/myr/myr_pred_ssp245_50.rds')
myr_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/myr/myr_pred_ssp245_70.rds')
myr_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/myr/myr_pred_ssp585_30.rds')
myr_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/myr/myr_pred_ssp585_50.rds')
myr_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/myr/myr_pred_ssp585_70.rds')

# Import thresholds
myr_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/myr_thresholds_hist.rds')
myr_low <- myr_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
myr_pred_hist_low <- ifel(myr_pred_hist >= myr_low, 1, NA)
myr_ssp245_30_low <- ifel(myr_pred_ssp245_30 >= myr_low, 1, NA)
myr_ssp245_50_low <- ifel(myr_pred_ssp245_50 >= myr_low, 1, NA)
myr_ssp245_70_low <- ifel(myr_pred_ssp245_70 >= myr_low, 1, NA)
myr_ssp585_30_low <- ifel(myr_pred_ssp585_30 >= myr_low, 1, NA)
myr_ssp585_50_low <- ifel(myr_pred_ssp585_50 >= myr_low, 1, NA)
myr_ssp585_70_low <- ifel(myr_pred_ssp585_70 >= myr_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(myr_pred_hist_low, main = 'historical')
plot(
  myr_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(myr_ssp585_70_low, main = 'ssp585 2070')
plot(
  myr_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(myr_codes)
myr_fut_codes <- c("2.2", "3.1", "2.3", "3.3", "3.2", "6.1", "2.1", "1.1")
myr_codes_mask <- c(myr_codes, myr_fut_codes) # combine together

# Build ecoregion mask
myr_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% myr_codes_mask)

# Mask all suitability rasters
myr_hist_mask <- terra::crop(myr_pred_hist, myr_eco_mask, mask = T)
myr_ssp245_30_mask <- terra::crop(myr_pred_ssp245_30, myr_eco_mask, mask = T)
myr_ssp245_50_mask <- terra::crop(myr_pred_ssp245_50, myr_eco_mask, mask = T)
myr_ssp245_70_mask <- terra::crop(myr_pred_ssp245_70, myr_eco_mask, mask = T)
myr_ssp585_30_mask <- terra::crop(myr_pred_ssp585_30, myr_eco_mask, mask = T)
myr_ssp585_50_mask <- terra::crop(myr_pred_ssp585_50, myr_eco_mask, mask = T)
myr_ssp585_70_mask <- terra::crop(myr_pred_ssp585_70, myr_eco_mask, mask = T)

# Save all masked rasters
myr_out_dir <- paste0(out_dir, '/myr/')
dir.create(myr_out_dir, showWarnings = FALSE)
saveRDS(myr_hist_mask, paste0(myr_out_dir, 'myr_hist_mask.rds'))
saveRDS(myr_ssp245_30_mask, paste0(myr_out_dir, 'myr_ssp245_30_mask.rds'))
saveRDS(myr_ssp245_50_mask, paste0(myr_out_dir, 'myr_ssp245_50_mask.rds'))
saveRDS(myr_ssp245_70_mask, paste0(myr_out_dir, 'myr_ssp245_70_mask.rds'))
saveRDS(myr_ssp585_30_mask, paste0(myr_out_dir, 'myr_ssp585_30_mask.rds'))
saveRDS(myr_ssp585_50_mask, paste0(myr_out_dir, 'myr_ssp585_50_mask.rds'))
saveRDS(myr_ssp585_70_mask, paste0(myr_out_dir, 'myr_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "myr_codes", "myr_eco_hist",
  "myr_pred_hist", "myr_pred_ssp245_30", "myr_pred_ssp245_50", "myr_pred_ssp245_70",
  "myr_pred_ssp585_30", "myr_pred_ssp585_50", "myr_pred_ssp585_70",
  "myr_thresholds", "myr_low",
  "myr_pred_hist_low", "myr_ssp245_30_low", "myr_ssp245_50_low", "myr_ssp245_70_low",
  "myr_ssp585_30_low", "myr_ssp585_50_low", "myr_ssp585_70_low",
  "myr_fut_codes", "myr_codes_mask", "myr_eco_mask",
  "myr_hist_mask", "myr_ssp245_30_mask", "myr_ssp245_50_mask", "myr_ssp245_70_mask",
  "myr_ssp585_30_mask", "myr_ssp585_50_mask", "myr_ssp585_70_mask",
  "myr_out_dir"
))
gc()

# V. myrsinites masking ---------------------------------------------------
# What codes did it exist in historically?
mys_codes <- readRDS('./bg_data/eco_code/eco_ occ_mys_thin _code.rds')

# Subset historical ecoregions
mys_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mys_codes)

# Import suitability rasters
mys_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/mys/mys_pred_hist.rds')
mys_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mys/mys_pred_ssp245_30.rds')
mys_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mys/mys_pred_ssp245_50.rds')
mys_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mys/mys_pred_ssp245_70.rds')
mys_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mys/mys_pred_ssp585_30.rds')
mys_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mys/mys_pred_ssp585_50.rds')
mys_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/mys/mys_pred_ssp585_70.rds')

# Import thresholds
mys_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/mys_thresholds_hist.rds')
mys_low <- mys_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
mys_pred_hist_low <- ifel(mys_pred_hist >= mys_low, 1, NA)
mys_ssp245_30_low <- ifel(mys_pred_ssp245_30 >= mys_low, 1, NA)
mys_ssp245_50_low <- ifel(mys_pred_ssp245_50 >= mys_low, 1, NA)
mys_ssp245_70_low <- ifel(mys_pred_ssp245_70 >= mys_low, 1, NA)
mys_ssp585_30_low <- ifel(mys_pred_ssp585_30 >= mys_low, 1, NA)
mys_ssp585_50_low <- ifel(mys_pred_ssp585_50 >= mys_low, 1, NA)
mys_ssp585_70_low <- ifel(mys_pred_ssp585_70 >= mys_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(mys_pred_hist_low, main = 'historical')
plot(
  mys_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(mys_ssp585_70_low, main = 'ssp585 2070')
plot(
  mys_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(mys_codes)
mys_fut_codes <- c() # NOT ADDING ANY. There is adjacent suitability into Mexico, but this is the classic Florida/PNW/Mexico maxent/worldclim prediction bruh. Suitability doesnt expand northward
mys_codes_mask <- c(mys_codes, mys_fut_codes) # combine together

# Build ecoregion mask
mys_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% mys_codes_mask)

# Mask all suitability rasters
mys_hist_mask <- terra::crop(mys_pred_hist, mys_eco_mask, mask = T)
mys_ssp245_30_mask <- terra::crop(mys_pred_ssp245_30, mys_eco_mask, mask = T)
mys_ssp245_50_mask <- terra::crop(mys_pred_ssp245_50, mys_eco_mask, mask = T)
mys_ssp245_70_mask <- terra::crop(mys_pred_ssp245_70, mys_eco_mask, mask = T)
mys_ssp585_30_mask <- terra::crop(mys_pred_ssp585_30, mys_eco_mask, mask = T)
mys_ssp585_50_mask <- terra::crop(mys_pred_ssp585_50, mys_eco_mask, mask = T)
mys_ssp585_70_mask <- terra::crop(mys_pred_ssp585_70, mys_eco_mask, mask = T)

# Save all masked rasters
mys_out_dir <- paste0(out_dir, '/mys/')
dir.create(mys_out_dir, showWarnings = FALSE)
saveRDS(mys_hist_mask, paste0(mys_out_dir, 'mys_hist_mask.rds'))
saveRDS(mys_ssp245_30_mask, paste0(mys_out_dir, 'mys_ssp245_30_mask.rds'))
saveRDS(mys_ssp245_50_mask, paste0(mys_out_dir, 'mys_ssp245_50_mask.rds'))
saveRDS(mys_ssp245_70_mask, paste0(mys_out_dir, 'mys_ssp245_70_mask.rds'))
saveRDS(mys_ssp585_30_mask, paste0(mys_out_dir, 'mys_ssp585_30_mask.rds'))
saveRDS(mys_ssp585_50_mask, paste0(mys_out_dir, 'mys_ssp585_50_mask.rds'))
saveRDS(mys_ssp585_70_mask, paste0(mys_out_dir, 'mys_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "mys_codes", "mys_eco_hist",
  "mys_pred_hist", "mys_pred_ssp245_30", "mys_pred_ssp245_50", "mys_pred_ssp245_70",
  "mys_pred_ssp585_30", "mys_pred_ssp585_50", "mys_pred_ssp585_70",
  "mys_thresholds", "mys_low",
  "mys_pred_hist_low", "mys_ssp245_30_low", "mys_ssp245_50_low", "mys_ssp245_70_low",
  "mys_ssp585_30_low", "mys_ssp585_50_low", "mys_ssp585_70_low",
  "mys_fut_codes", "mys_codes_mask", "mys_eco_mask",
  "mys_hist_mask", "mys_ssp245_30_mask", "mys_ssp245_50_mask", "mys_ssp245_70_mask",
  "mys_ssp585_30_mask", "mys_ssp585_50_mask", "mys_ssp585_70_mask",
  "mys_out_dir"
))
gc()

# V. ovalifolium masking --------------------------------------------------
# What codes did it exist in historically?
ova_codes <- readRDS('./bg_data/eco_code/eco_ occ_ova_thin _code.rds')

# Subset historical ecoregions
ova_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ova_codes)

# Import suitability rasters
ova_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/ova/ova_pred_hist.rds')
ova_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ova/ova_pred_ssp245_30.rds')
ova_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ova/ova_pred_ssp245_50.rds')
ova_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ova/ova_pred_ssp245_70.rds')
ova_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ova/ova_pred_ssp585_30.rds')
ova_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ova/ova_pred_ssp585_50.rds')
ova_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ova/ova_pred_ssp585_70.rds')

# Import thresholds
ova_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/ova_thresholds_hist.rds')
ova_low <- ova_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ova_pred_hist_low <- ifel(ova_pred_hist >= ova_low, 1, NA)
ova_ssp245_30_low <- ifel(ova_pred_ssp245_30 >= ova_low, 1, NA)
ova_ssp245_50_low <- ifel(ova_pred_ssp245_50 >= ova_low, 1, NA)
ova_ssp245_70_low <- ifel(ova_pred_ssp245_70 >= ova_low, 1, NA)
ova_ssp585_30_low <- ifel(ova_pred_ssp585_30 >= ova_low, 1, NA)
ova_ssp585_50_low <- ifel(ova_pred_ssp585_50 >= ova_low, 1, NA)
ova_ssp585_70_low <- ifel(ova_pred_ssp585_70 >= ova_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(ova_pred_hist_low, main = 'historical')
plot(
  ova_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ova_ssp585_70_low, main = 'ssp585 2070')
plot(
  ova_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(ova_codes)
ova_fut_codes <- c("1.1", "2.4", "2.3", "3.3", "5.4") 
ova_codes_mask <- c(ova_codes, ova_fut_codes) # combine together

# Build ecoregion mask
ova_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ova_codes_mask)

# Mask all suitability rasters
ova_hist_mask <- terra::crop(ova_pred_hist, ova_eco_mask, mask = T)
ova_ssp245_30_mask <- terra::crop(ova_pred_ssp245_30, ova_eco_mask, mask = T)
ova_ssp245_50_mask <- terra::crop(ova_pred_ssp245_50, ova_eco_mask, mask = T)
ova_ssp245_70_mask <- terra::crop(ova_pred_ssp245_70, ova_eco_mask, mask = T)
ova_ssp585_30_mask <- terra::crop(ova_pred_ssp585_30, ova_eco_mask, mask = T)
ova_ssp585_50_mask <- terra::crop(ova_pred_ssp585_50, ova_eco_mask, mask = T)
ova_ssp585_70_mask <- terra::crop(ova_pred_ssp585_70, ova_eco_mask, mask = T)

# Save all masked rasters
ova_out_dir <- paste0(out_dir, '/ova/')
dir.create(ova_out_dir, showWarnings = FALSE)
saveRDS(ova_hist_mask, paste0(ova_out_dir, 'ova_hist_mask.rds'))
saveRDS(ova_ssp245_30_mask, paste0(ova_out_dir, 'ova_ssp245_30_mask.rds'))
saveRDS(ova_ssp245_50_mask, paste0(ova_out_dir, 'ova_ssp245_50_mask.rds'))
saveRDS(ova_ssp245_70_mask, paste0(ova_out_dir, 'ova_ssp245_70_mask.rds'))
saveRDS(ova_ssp585_30_mask, paste0(ova_out_dir, 'ova_ssp585_30_mask.rds'))
saveRDS(ova_ssp585_50_mask, paste0(ova_out_dir, 'ova_ssp585_50_mask.rds'))
saveRDS(ova_ssp585_70_mask, paste0(ova_out_dir, 'ova_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ova_codes", "ova_eco_hist",
  "ova_pred_hist", "ova_pred_ssp245_30", "ova_pred_ssp245_50", "ova_pred_ssp245_70",
  "ova_pred_ssp585_30", "ova_pred_ssp585_50", "ova_pred_ssp585_70",
  "ova_thresholds", "ova_low",
  "ova_pred_hist_low", "ova_ssp245_30_low", "ova_ssp245_50_low", "ova_ssp245_70_low",
  "ova_ssp585_30_low", "ova_ssp585_50_low", "ova_ssp585_70_low",
  "ova_fut_codes", "ova_codes_mask", "ova_eco_mask",
  "ova_hist_mask", "ova_ssp245_30_mask", "ova_ssp245_50_mask", "ova_ssp245_70_mask",
  "ova_ssp585_30_mask", "ova_ssp585_50_mask", "ova_ssp585_70_mask",
  "ova_out_dir"
))
gc()

# V. ovatum masking -------------------------------------------------------
# What codes did it exist in historically?
ovt_codes <- readRDS('./bg_data/eco_code/eco_ occ_ovt_thin _code.rds')

# Subset historical ecoregions
ovt_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ovt_codes)

# Import suitability rasters
ovt_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/ovt/ovt_pred_hist.rds')
ovt_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ovt/ovt_pred_ssp245_30.rds')
ovt_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ovt/ovt_pred_ssp245_50.rds')
ovt_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ovt/ovt_pred_ssp245_70.rds')
ovt_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ovt/ovt_pred_ssp585_30.rds')
ovt_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ovt/ovt_pred_ssp585_50.rds')
ovt_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ovt/ovt_pred_ssp585_70.rds')

# Import thresholds
ovt_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/ovt_thresholds_hist.rds')
ovt_low <- ovt_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ovt_pred_hist_low <- ifel(ovt_pred_hist >= ovt_low, 1, NA)
ovt_ssp245_30_low <- ifel(ovt_pred_ssp245_30 >= ovt_low, 1, NA)
ovt_ssp245_50_low <- ifel(ovt_pred_ssp245_50 >= ovt_low, 1, NA)
ovt_ssp245_70_low <- ifel(ovt_pred_ssp245_70 >= ovt_low, 1, NA)
ovt_ssp585_30_low <- ifel(ovt_pred_ssp585_30 >= ovt_low, 1, NA)
ovt_ssp585_50_low <- ifel(ovt_pred_ssp585_50 >= ovt_low, 1, NA)
ovt_ssp585_70_low <- ifel(ovt_pred_ssp585_70 >= ovt_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(ovt_pred_hist_low, main = 'historical')
plot(
  ovt_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ovt_ssp585_70_low, main = 'ssp585 2070')
plot(
  ovt_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(ovt_codes)
ovt_fut_codes <- c("2.2")
ovt_codes_mask <- c(ovt_codes, ovt_fut_codes) # combine together

# Build ecoregion mask
ovt_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ovt_codes_mask)

# Mask all suitability rasters
ovt_hist_mask <- terra::crop(ovt_pred_hist, ovt_eco_mask, mask = T)
ovt_ssp245_30_mask <- terra::crop(ovt_pred_ssp245_30, ovt_eco_mask, mask = T)
ovt_ssp245_50_mask <- terra::crop(ovt_pred_ssp245_50, ovt_eco_mask, mask = T)
ovt_ssp245_70_mask <- terra::crop(ovt_pred_ssp245_70, ovt_eco_mask, mask = T)
ovt_ssp585_30_mask <- terra::crop(ovt_pred_ssp585_30, ovt_eco_mask, mask = T)
ovt_ssp585_50_mask <- terra::crop(ovt_pred_ssp585_50, ovt_eco_mask, mask = T)
ovt_ssp585_70_mask <- terra::crop(ovt_pred_ssp585_70, ovt_eco_mask, mask = T)

# Save all masked rasters
ovt_out_dir <- paste0(out_dir, '/ovt/')
dir.create(ovt_out_dir, showWarnings = FALSE)
saveRDS(ovt_hist_mask, paste0(ovt_out_dir, 'ovt_hist_mask.rds'))
saveRDS(ovt_ssp245_30_mask, paste0(ovt_out_dir, 'ovt_ssp245_30_mask.rds'))
saveRDS(ovt_ssp245_50_mask, paste0(ovt_out_dir, 'ovt_ssp245_50_mask.rds'))
saveRDS(ovt_ssp245_70_mask, paste0(ovt_out_dir, 'ovt_ssp245_70_mask.rds'))
saveRDS(ovt_ssp585_30_mask, paste0(ovt_out_dir, 'ovt_ssp585_30_mask.rds'))
saveRDS(ovt_ssp585_50_mask, paste0(ovt_out_dir, 'ovt_ssp585_50_mask.rds'))
saveRDS(ovt_ssp585_70_mask, paste0(ovt_out_dir, 'ovt_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ovt_codes", "ovt_eco_hist",
  "ovt_pred_hist", "ovt_pred_ssp245_30", "ovt_pred_ssp245_50", "ovt_pred_ssp245_70",
  "ovt_pred_ssp585_30", "ovt_pred_ssp585_50", "ovt_pred_ssp585_70",
  "ovt_thresholds", "ovt_low",
  "ovt_pred_hist_low", "ovt_ssp245_30_low", "ovt_ssp245_50_low", "ovt_ssp245_70_low",
  "ovt_ssp585_30_low", "ovt_ssp585_50_low", "ovt_ssp585_70_low",
  "ovt_fut_codes", "ovt_codes_mask", "ovt_eco_mask",
  "ovt_hist_mask", "ovt_ssp245_30_mask", "ovt_ssp245_50_mask", "ovt_ssp245_70_mask",
  "ovt_ssp585_30_mask", "ovt_ssp585_50_mask", "ovt_ssp585_70_mask",
  "ovt_out_dir"
))
gc()

# V. oxycoccos masking ----------------------------------------------------
# What codes did it exist in historically?
oxy_codes <- readRDS('./bg_data/eco_code/eco_ occ_oxy_thin _code.rds')

# Subset historical ecoregions
oxy_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% oxy_codes)

# Import suitability rasters
oxy_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/oxy/oxy_pred_hist.rds')
oxy_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/oxy/oxy_pred_ssp245_30.rds')
oxy_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/oxy/oxy_pred_ssp245_50.rds')
oxy_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/oxy/oxy_pred_ssp245_70.rds')
oxy_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/oxy/oxy_pred_ssp585_30.rds')
oxy_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/oxy/oxy_pred_ssp585_50.rds')
oxy_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/oxy/oxy_pred_ssp585_70.rds')

# Import thresholds
oxy_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/oxy_thresholds_hist.rds')
oxy_low <- oxy_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
oxy_pred_hist_low <- ifel(oxy_pred_hist >= oxy_low, 1, NA)
oxy_ssp245_30_low <- ifel(oxy_pred_ssp245_30 >= oxy_low, 1, NA)
oxy_ssp245_50_low <- ifel(oxy_pred_ssp245_50 >= oxy_low, 1, NA)
oxy_ssp245_70_low <- ifel(oxy_pred_ssp245_70 >= oxy_low, 1, NA)
oxy_ssp585_30_low <- ifel(oxy_pred_ssp585_30 >= oxy_low, 1, NA)
oxy_ssp585_50_low <- ifel(oxy_pred_ssp585_50 >= oxy_low, 1, NA)
oxy_ssp585_70_low <- ifel(oxy_pred_ssp585_70 >= oxy_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(oxy_pred_hist_low, main = 'historical')
plot(
  oxy_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(oxy_ssp585_70_low, main = 'ssp585 2070')
plot(
  oxy_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(oxy_codes)
oxy_fut_codes <- c("2.1")
oxy_codes_mask <- c(oxy_codes, oxy_fut_codes) # combine together

# Build ecoregion mask
oxy_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% oxy_codes_mask)

# Mask all suitability rasters
oxy_hist_mask <- terra::crop(oxy_pred_hist, oxy_eco_mask, mask = T)
oxy_ssp245_30_mask <- terra::crop(oxy_pred_ssp245_30, oxy_eco_mask, mask = T)
oxy_ssp245_50_mask <- terra::crop(oxy_pred_ssp245_50, oxy_eco_mask, mask = T)
oxy_ssp245_70_mask <- terra::crop(oxy_pred_ssp245_70, oxy_eco_mask, mask = T)
oxy_ssp585_30_mask <- terra::crop(oxy_pred_ssp585_30, oxy_eco_mask, mask = T)
oxy_ssp585_50_mask <- terra::crop(oxy_pred_ssp585_50, oxy_eco_mask, mask = T)
oxy_ssp585_70_mask <- terra::crop(oxy_pred_ssp585_70, oxy_eco_mask, mask = T)

# Save all masked rasters
oxy_out_dir <- paste0(out_dir, '/oxy/')
dir.create(oxy_out_dir, showWarnings = FALSE)
saveRDS(oxy_hist_mask, paste0(oxy_out_dir, 'oxy_hist_mask.rds'))
saveRDS(oxy_ssp245_30_mask, paste0(oxy_out_dir, 'oxy_ssp245_30_mask.rds'))
saveRDS(oxy_ssp245_50_mask, paste0(oxy_out_dir, 'oxy_ssp245_50_mask.rds'))
saveRDS(oxy_ssp245_70_mask, paste0(oxy_out_dir, 'oxy_ssp245_70_mask.rds'))
saveRDS(oxy_ssp585_30_mask, paste0(oxy_out_dir, 'oxy_ssp585_30_mask.rds'))
saveRDS(oxy_ssp585_50_mask, paste0(oxy_out_dir, 'oxy_ssp585_50_mask.rds'))
saveRDS(oxy_ssp585_70_mask, paste0(oxy_out_dir, 'oxy_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "oxy_codes", "oxy_eco_hist",
  "oxy_pred_hist", "oxy_pred_ssp245_30", "oxy_pred_ssp245_50", "oxy_pred_ssp245_70",
  "oxy_pred_ssp585_30", "oxy_pred_ssp585_50", "oxy_pred_ssp585_70",
  "oxy_thresholds", "oxy_low",
  "oxy_pred_hist_low", "oxy_ssp245_30_low", "oxy_ssp245_50_low", "oxy_ssp245_70_low",
  "oxy_ssp585_30_low", "oxy_ssp585_50_low", "oxy_ssp585_70_low",
  "oxy_fut_codes", "oxy_codes_mask", "oxy_eco_mask",
  "oxy_hist_mask", "oxy_ssp245_30_mask", "oxy_ssp245_50_mask", "oxy_ssp245_70_mask",
  "oxy_ssp585_30_mask", "oxy_ssp585_50_mask", "oxy_ssp585_70_mask",
  "oxy_out_dir"
))
gc()

# V. pallidum masking -----------------------------------------------------
# What codes did it exist in historically?
pal_codes <- readRDS('./bg_data/eco_code/eco_ occ_pal_thin _code.rds')

# Subset historical ecoregions
pal_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% pal_codes)

# Import suitability rasters
pal_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/pal/pal_pred_hist.rds')
pal_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/pal/pal_pred_ssp245_30.rds')
pal_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/pal/pal_pred_ssp245_50.rds')
pal_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/pal/pal_pred_ssp245_70.rds')
pal_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/pal/pal_pred_ssp585_30.rds')
pal_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/pal/pal_pred_ssp585_50.rds')
pal_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/pal/pal_pred_ssp585_70.rds')

# Import thresholds
pal_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/pal_thresholds_hist.rds')
pal_low <- pal_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
pal_pred_hist_low <- ifel(pal_pred_hist >= pal_low, 1, NA)
pal_ssp245_30_low <- ifel(pal_pred_ssp245_30 >= pal_low, 1, NA)
pal_ssp245_50_low <- ifel(pal_pred_ssp245_50 >= pal_low, 1, NA)
pal_ssp245_70_low <- ifel(pal_pred_ssp245_70 >= pal_low, 1, NA)
pal_ssp585_30_low <- ifel(pal_pred_ssp585_30 >= pal_low, 1, NA)
pal_ssp585_50_low <- ifel(pal_pred_ssp585_50 >= pal_low, 1, NA)
pal_ssp585_70_low <- ifel(pal_pred_ssp585_70 >= pal_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(pal_pred_hist_low, main = 'historical')
plot(
  pal_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(pal_ssp585_70_low, main = 'ssp585 2070')
plot(
  pal_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(pal_codes)
pal_fut_codes <- c("3.4", "4.1", "2.4", "1.1")
pal_codes_mask <- c(pal_codes, pal_fut_codes) # combine together

# Build ecoregion mask
pal_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% pal_codes_mask)

# Mask all suitability rasters
pal_hist_mask <- terra::crop(pal_pred_hist, pal_eco_mask, mask = T)
pal_ssp245_30_mask <- terra::crop(pal_pred_ssp245_30, pal_eco_mask, mask = T)
pal_ssp245_50_mask <- terra::crop(pal_pred_ssp245_50, pal_eco_mask, mask = T)
pal_ssp245_70_mask <- terra::crop(pal_pred_ssp245_70, pal_eco_mask, mask = T)
pal_ssp585_30_mask <- terra::crop(pal_pred_ssp585_30, pal_eco_mask, mask = T)
pal_ssp585_50_mask <- terra::crop(pal_pred_ssp585_50, pal_eco_mask, mask = T)
pal_ssp585_70_mask <- terra::crop(pal_pred_ssp585_70, pal_eco_mask, mask = T)

# Save all masked rasters
pal_out_dir <- paste0(out_dir, '/pal/')
dir.create(pal_out_dir, showWarnings = FALSE)
saveRDS(pal_hist_mask, paste0(pal_out_dir, 'pal_hist_mask.rds'))
saveRDS(pal_ssp245_30_mask, paste0(pal_out_dir, 'pal_ssp245_30_mask.rds'))
saveRDS(pal_ssp245_50_mask, paste0(pal_out_dir, 'pal_ssp245_50_mask.rds'))
saveRDS(pal_ssp245_70_mask, paste0(pal_out_dir, 'pal_ssp245_70_mask.rds'))
saveRDS(pal_ssp585_30_mask, paste0(pal_out_dir, 'pal_ssp585_30_mask.rds'))
saveRDS(pal_ssp585_50_mask, paste0(pal_out_dir, 'pal_ssp585_50_mask.rds'))
saveRDS(pal_ssp585_70_mask, paste0(pal_out_dir, 'pal_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "pal_codes", "pal_eco_hist",
  "pal_pred_hist", "pal_pred_ssp245_30", "pal_pred_ssp245_50", "pal_pred_ssp245_70",
  "pal_pred_ssp585_30", "pal_pred_ssp585_50", "pal_pred_ssp585_70",
  "pal_thresholds", "pal_low",
  "pal_pred_hist_low", "pal_ssp245_30_low", "pal_ssp245_50_low", "pal_ssp245_70_low",
  "pal_ssp585_30_low", "pal_ssp585_50_low", "pal_ssp585_70_low",
  "pal_fut_codes", "pal_codes_mask", "pal_eco_mask",
  "pal_hist_mask", "pal_ssp245_30_mask", "pal_ssp245_50_mask", "pal_ssp245_70_mask",
  "pal_ssp585_30_mask", "pal_ssp585_50_mask", "pal_ssp585_70_mask",
  "pal_out_dir"
))
gc()

# V. parvifolium masking --------------------------------------------------
# What codes did it exist in historically?
par_codes <- readRDS('./bg_data/eco_code/eco_ occ_par_thin _code.rds')

# Subset historical ecoregions
par_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% par_codes)

# Import suitability rasters
par_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/par/par_pred_hist.rds')
par_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/par/par_pred_ssp245_30.rds')
par_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/par/par_pred_ssp245_50.rds')
par_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/par/par_pred_ssp245_70.rds')
par_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/par/par_pred_ssp585_30.rds')
par_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/par/par_pred_ssp585_50.rds')
par_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/par/par_pred_ssp585_70.rds')

# Import thresholds
par_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/par_thresholds_hist.rds')
par_low <- par_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
par_pred_hist_low <- ifel(par_pred_hist >= par_low, 1, NA)
par_ssp245_30_low <- ifel(par_pred_ssp245_30 >= par_low, 1, NA)
par_ssp245_50_low <- ifel(par_pred_ssp245_50 >= par_low, 1, NA)
par_ssp245_70_low <- ifel(par_pred_ssp245_70 >= par_low, 1, NA)
par_ssp585_30_low <- ifel(par_pred_ssp585_30 >= par_low, 1, NA)
par_ssp585_50_low <- ifel(par_pred_ssp585_50 >= par_low, 1, NA)
par_ssp585_70_low <- ifel(par_pred_ssp585_70 >= par_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(par_pred_hist_low, main = 'historical')
plot(
  par_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(par_ssp585_70_low, main = 'ssp585 2070')
plot(
  par_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(par_codes)
par_fut_codes <- c("6.1","2.2", "3.1")
par_codes_mask <- c(par_codes, par_fut_codes) # combine together

# Build ecoregion mask
par_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% par_codes_mask)

# Mask all suitability rasters
par_hist_mask <- terra::crop(par_pred_hist, par_eco_mask, mask = T)
par_ssp245_30_mask <- terra::crop(par_pred_ssp245_30, par_eco_mask, mask = T)
par_ssp245_50_mask <- terra::crop(par_pred_ssp245_50, par_eco_mask, mask = T)
par_ssp245_70_mask <- terra::crop(par_pred_ssp245_70, par_eco_mask, mask = T)
par_ssp585_30_mask <- terra::crop(par_pred_ssp585_30, par_eco_mask, mask = T)
par_ssp585_50_mask <- terra::crop(par_pred_ssp585_50, par_eco_mask, mask = T)
par_ssp585_70_mask <- terra::crop(par_pred_ssp585_70, par_eco_mask, mask = T)

# Save all masked rasters
par_out_dir <- paste0(out_dir, '/par/')
dir.create(par_out_dir, showWarnings = FALSE)
saveRDS(par_hist_mask, paste0(par_out_dir, 'par_hist_mask.rds'))
saveRDS(par_ssp245_30_mask, paste0(par_out_dir, 'par_ssp245_30_mask.rds'))
saveRDS(par_ssp245_50_mask, paste0(par_out_dir, 'par_ssp245_50_mask.rds'))
saveRDS(par_ssp245_70_mask, paste0(par_out_dir, 'par_ssp245_70_mask.rds'))
saveRDS(par_ssp585_30_mask, paste0(par_out_dir, 'par_ssp585_30_mask.rds'))
saveRDS(par_ssp585_50_mask, paste0(par_out_dir, 'par_ssp585_50_mask.rds'))
saveRDS(par_ssp585_70_mask, paste0(par_out_dir, 'par_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "par_codes", "par_eco_hist",
  "par_pred_hist", "par_pred_ssp245_30", "par_pred_ssp245_50", "par_pred_ssp245_70",
  "par_pred_ssp585_30", "par_pred_ssp585_50", "par_pred_ssp585_70",
  "par_thresholds", "par_low",
  "par_pred_hist_low", "par_ssp245_30_low", "par_ssp245_50_low", "par_ssp245_70_low",
  "par_ssp585_30_low", "par_ssp585_50_low", "par_ssp585_70_low",
  "par_fut_codes", "par_codes_mask", "par_eco_mask",
  "par_hist_mask", "par_ssp245_30_mask", "par_ssp245_50_mask", "par_ssp245_70_mask",
  "par_ssp585_30_mask", "par_ssp585_50_mask", "par_ssp585_70_mask",
  "par_out_dir"
))
gc()

# V. scoparium masking ----------------------------------------------------
# What codes did it exist in historically?
sco_codes <- readRDS('./bg_data/eco_code/eco_ occ_sco_thin _code.rds')

# Subset historical ecoregions
sco_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sco_codes)

# Import suitability rasters
sco_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/sco/sco_pred_hist.rds')
sco_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sco/sco_pred_ssp245_30.rds')
sco_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sco/sco_pred_ssp245_50.rds')
sco_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sco/sco_pred_ssp245_70.rds')
sco_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sco/sco_pred_ssp585_30.rds')
sco_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sco/sco_pred_ssp585_50.rds')
sco_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sco/sco_pred_ssp585_70.rds')

# Import thresholds
sco_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/sco_thresholds_hist.rds')
sco_low <- sco_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
sco_pred_hist_low <- ifel(sco_pred_hist >= sco_low, 1, NA)
sco_ssp245_30_low <- ifel(sco_pred_ssp245_30 >= sco_low, 1, NA)
sco_ssp245_50_low <- ifel(sco_pred_ssp245_50 >= sco_low, 1, NA)
sco_ssp245_70_low <- ifel(sco_pred_ssp245_70 >= sco_low, 1, NA)
sco_ssp585_30_low <- ifel(sco_pred_ssp585_30 >= sco_low, 1, NA)
sco_ssp585_50_low <- ifel(sco_pred_ssp585_50 >= sco_low, 1, NA)
sco_ssp585_70_low <- ifel(sco_pred_ssp585_70 >= sco_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(sco_pred_hist_low, main = 'historical')
plot(
  sco_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(sco_ssp585_70_low, main = 'ssp585 2070')
plot(
  sco_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(sco_codes)
sco_fut_codes <- c("2.2", "3.1", "2.3") # 2.2 and 3.1 also historical, 2.3 future
sco_codes_mask <- c(sco_codes, sco_fut_codes) # combine together

# Build ecoregion mask
sco_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sco_codes_mask)

# Mask all suitability rasters
sco_hist_mask <- terra::crop(sco_pred_hist, sco_eco_mask, mask = T)
sco_ssp245_30_mask <- terra::crop(sco_pred_ssp245_30, sco_eco_mask, mask = T)
sco_ssp245_50_mask <- terra::crop(sco_pred_ssp245_50, sco_eco_mask, mask = T)
sco_ssp245_70_mask <- terra::crop(sco_pred_ssp245_70, sco_eco_mask, mask = T)
sco_ssp585_30_mask <- terra::crop(sco_pred_ssp585_30, sco_eco_mask, mask = T)
sco_ssp585_50_mask <- terra::crop(sco_pred_ssp585_50, sco_eco_mask, mask = T)
sco_ssp585_70_mask <- terra::crop(sco_pred_ssp585_70, sco_eco_mask, mask = T)

# Save all masked rasters
sco_out_dir <- paste0(out_dir, '/sco/')
dir.create(sco_out_dir, showWarnings = FALSE)
saveRDS(sco_hist_mask, paste0(sco_out_dir, 'sco_hist_mask.rds'))
saveRDS(sco_ssp245_30_mask, paste0(sco_out_dir, 'sco_ssp245_30_mask.rds'))
saveRDS(sco_ssp245_50_mask, paste0(sco_out_dir, 'sco_ssp245_50_mask.rds'))
saveRDS(sco_ssp245_70_mask, paste0(sco_out_dir, 'sco_ssp245_70_mask.rds'))
saveRDS(sco_ssp585_30_mask, paste0(sco_out_dir, 'sco_ssp585_30_mask.rds'))
saveRDS(sco_ssp585_50_mask, paste0(sco_out_dir, 'sco_ssp585_50_mask.rds'))
saveRDS(sco_ssp585_70_mask, paste0(sco_out_dir, 'sco_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "sco_codes", "sco_eco_hist",
  "sco_pred_hist", "sco_pred_ssp245_30", "sco_pred_ssp245_50", "sco_pred_ssp245_70",
  "sco_pred_ssp585_30", "sco_pred_ssp585_50", "sco_pred_ssp585_70",
  "sco_thresholds", "sco_low",
  "sco_pred_hist_low", "sco_ssp245_30_low", "sco_ssp245_50_low", "sco_ssp245_70_low",
  "sco_ssp585_30_low", "sco_ssp585_50_low", "sco_ssp585_70_low",
  "sco_fut_codes", "sco_codes_mask", "sco_eco_mask",
  "sco_hist_mask", "sco_ssp245_30_mask", "sco_ssp245_50_mask", "sco_ssp245_70_mask",
  "sco_ssp585_30_mask", "sco_ssp585_50_mask", "sco_ssp585_70_mask",
  "sco_out_dir"
))
gc()

# V. shastense masking ----------------------------------------------------
# What codes did it exist in historically?
sha_codes <- readRDS('./bg_data/eco_code/eco_ occ_sha_thin _code.rds')

# Subset historical ecoregions
sha_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sha_codes)

# Import suitability rasters
sha_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/sha/sha_pred_hist.rds')
sha_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sha/sha_pred_ssp245_30.rds')
sha_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sha/sha_pred_ssp245_50.rds')
sha_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sha/sha_pred_ssp245_70.rds')
sha_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sha/sha_pred_ssp585_30.rds')
sha_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sha/sha_pred_ssp585_50.rds')
sha_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sha/sha_pred_ssp585_70.rds')

# Import thresholds
sha_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/sha_thresholds_hist.rds')
sha_low <- sha_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
sha_pred_hist_low <- ifel(sha_pred_hist >= sha_low, 1, NA)
sha_ssp245_30_low <- ifel(sha_pred_ssp245_30 >= sha_low, 1, NA)
sha_ssp245_50_low <- ifel(sha_pred_ssp245_50 >= sha_low, 1, NA)
sha_ssp245_70_low <- ifel(sha_pred_ssp245_70 >= sha_low, 1, NA)
sha_ssp585_30_low <- ifel(sha_pred_ssp585_30 >= sha_low, 1, NA)
sha_ssp585_50_low <- ifel(sha_pred_ssp585_50 >= sha_low, 1, NA)
sha_ssp585_70_low <- ifel(sha_pred_ssp585_70 >= sha_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(sha_pred_hist_low, main = 'historical')
plot(
  sha_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(sha_ssp585_70_low, main = 'ssp585 2070')
plot(
  sha_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(sha_codes)
sha_fut_codes <- c("7.1", "10.1") # Future only
sha_codes_mask <- c(sha_codes, sha_fut_codes) # combine together

# Build ecoregion mask
sha_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sha_codes_mask)

# Mask all suitability rasters
sha_hist_mask <- terra::crop(sha_pred_hist, sha_eco_mask, mask = T)
sha_ssp245_30_mask <- terra::crop(sha_pred_ssp245_30, sha_eco_mask, mask = T)
sha_ssp245_50_mask <- terra::crop(sha_pred_ssp245_50, sha_eco_mask, mask = T)
sha_ssp245_70_mask <- terra::crop(sha_pred_ssp245_70, sha_eco_mask, mask = T)
sha_ssp585_30_mask <- terra::crop(sha_pred_ssp585_30, sha_eco_mask, mask = T)
sha_ssp585_50_mask <- terra::crop(sha_pred_ssp585_50, sha_eco_mask, mask = T)
sha_ssp585_70_mask <- terra::crop(sha_pred_ssp585_70, sha_eco_mask, mask = T)

# Save all masked rasters
sha_out_dir <- paste0(out_dir, '/sha/')
dir.create(sha_out_dir, showWarnings = FALSE)
saveRDS(sha_hist_mask, paste0(sha_out_dir, 'sha_hist_mask.rds'))
saveRDS(sha_ssp245_30_mask, paste0(sha_out_dir, 'sha_ssp245_30_mask.rds'))
saveRDS(sha_ssp245_50_mask, paste0(sha_out_dir, 'sha_ssp245_50_mask.rds'))
saveRDS(sha_ssp245_70_mask, paste0(sha_out_dir, 'sha_ssp245_70_mask.rds'))
saveRDS(sha_ssp585_30_mask, paste0(sha_out_dir, 'sha_ssp585_30_mask.rds'))
saveRDS(sha_ssp585_50_mask, paste0(sha_out_dir, 'sha_ssp585_50_mask.rds'))
saveRDS(sha_ssp585_70_mask, paste0(sha_out_dir, 'sha_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "sha_codes", "sha_eco_hist",
  "sha_pred_hist", "sha_pred_ssp245_30", "sha_pred_ssp245_50", "sha_pred_ssp245_70",
  "sha_pred_ssp585_30", "sha_pred_ssp585_50", "sha_pred_ssp585_70",
  "sha_thresholds", "sha_low",
  "sha_pred_hist_low", "sha_ssp245_30_low", "sha_ssp245_50_low", "sha_ssp245_70_low",
  "sha_ssp585_30_low", "sha_ssp585_50_low", "sha_ssp585_70_low",
  "sha_fut_codes", "sha_codes_mask", "sha_eco_mask",
  "sha_hist_mask", "sha_ssp245_30_mask", "sha_ssp245_50_mask", "sha_ssp245_70_mask",
  "sha_ssp585_30_mask", "sha_ssp585_50_mask", "sha_ssp585_70_mask",
  "sha_out_dir"
))
gc()

# V. stamineum masking ----------------------------------------------------
# What codes did it exist in historically?
sta_codes <- readRDS('./bg_data/eco_code/eco_ occ_sta_thin _code.rds')

# Subset historical ecoregions
sta_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sta_codes)

# Import suitability rasters
sta_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/sta/sta_pred_hist.rds')
sta_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sta/sta_pred_ssp245_30.rds')
sta_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sta/sta_pred_ssp245_50.rds')
sta_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sta/sta_pred_ssp245_70.rds')
sta_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sta/sta_pred_ssp585_30.rds')
sta_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sta/sta_pred_ssp585_50.rds')
sta_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/sta/sta_pred_ssp585_70.rds')

# Import thresholds
sta_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/sta_thresholds_hist.rds')
sta_low <- sta_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
sta_pred_hist_low <- ifel(sta_pred_hist >= sta_low, 1, NA)
sta_ssp245_30_low <- ifel(sta_pred_ssp245_30 >= sta_low, 1, NA)
sta_ssp245_50_low <- ifel(sta_pred_ssp245_50 >= sta_low, 1, NA)
sta_ssp245_70_low <- ifel(sta_pred_ssp245_70 >= sta_low, 1, NA)
sta_ssp585_30_low <- ifel(sta_pred_ssp585_30 >= sta_low, 1, NA)
sta_ssp585_50_low <- ifel(sta_pred_ssp585_50 >= sta_low, 1, NA)
sta_ssp585_70_low <- ifel(sta_pred_ssp585_70 >= sta_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(sta_pred_hist_low, main = 'historical')
plot(
  sta_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(sta_ssp585_70_low, main = 'ssp585 2070')
plot(
  sta_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(sta_codes)
sta_fut_codes <- c("5.1", "3.4")
sta_codes_mask <- c(sta_codes, sta_fut_codes) # combine together

# Build ecoregion mask
sta_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sta_codes_mask)

# Mask all suitability rasters
sta_hist_mask <- terra::crop(sta_pred_hist, sta_eco_mask, mask = T)
sta_ssp245_30_mask <- terra::crop(sta_pred_ssp245_30, sta_eco_mask, mask = T)
sta_ssp245_50_mask <- terra::crop(sta_pred_ssp245_50, sta_eco_mask, mask = T)
sta_ssp245_70_mask <- terra::crop(sta_pred_ssp245_70, sta_eco_mask, mask = T)
sta_ssp585_30_mask <- terra::crop(sta_pred_ssp585_30, sta_eco_mask, mask = T)
sta_ssp585_50_mask <- terra::crop(sta_pred_ssp585_50, sta_eco_mask, mask = T)
sta_ssp585_70_mask <- terra::crop(sta_pred_ssp585_70, sta_eco_mask, mask = T)

# Save all masked rasters
sta_out_dir <- paste0(out_dir, '/sta/')
dir.create(sta_out_dir, showWarnings = FALSE)
saveRDS(sta_hist_mask, paste0(sta_out_dir, 'sta_hist_mask.rds'))
saveRDS(sta_ssp245_30_mask, paste0(sta_out_dir, 'sta_ssp245_30_mask.rds'))
saveRDS(sta_ssp245_50_mask, paste0(sta_out_dir, 'sta_ssp245_50_mask.rds'))
saveRDS(sta_ssp245_70_mask, paste0(sta_out_dir, 'sta_ssp245_70_mask.rds'))
saveRDS(sta_ssp585_30_mask, paste0(sta_out_dir, 'sta_ssp585_30_mask.rds'))
saveRDS(sta_ssp585_50_mask, paste0(sta_out_dir, 'sta_ssp585_50_mask.rds'))
saveRDS(sta_ssp585_70_mask, paste0(sta_out_dir, 'sta_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "sta_codes", "sta_eco_hist",
  "sta_pred_hist", "sta_pred_ssp245_30", "sta_pred_ssp245_50", "sta_pred_ssp245_70",
  "sta_pred_ssp585_30", "sta_pred_ssp585_50", "sta_pred_ssp585_70",
  "sta_thresholds", "sta_low",
  "sta_pred_hist_low", "sta_ssp245_30_low", "sta_ssp245_50_low", "sta_ssp245_70_low",
  "sta_ssp585_30_low", "sta_ssp585_50_low", "sta_ssp585_70_low",
  "sta_fut_codes", "sta_codes_mask", "sta_eco_mask",
  "sta_hist_mask", "sta_ssp245_30_mask", "sta_ssp245_50_mask", "sta_ssp245_70_mask",
  "sta_ssp585_30_mask", "sta_ssp585_50_mask", "sta_ssp585_70_mask",
  "sta_out_dir"
))
gc()

# V. tenellum masking -----------------------------------------------------
# What codes did it exist in historically?
ten_codes <- readRDS('./bg_data/eco_code/eco_ occ_ten_thin _code.rds')

# Subset historical ecoregions
ten_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ten_codes)

# Import suitability rasters
ten_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/ten/ten_pred_hist.rds')
ten_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ten/ten_pred_ssp245_30.rds')
ten_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ten/ten_pred_ssp245_50.rds')
ten_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ten/ten_pred_ssp245_70.rds')
ten_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ten/ten_pred_ssp585_30.rds')
ten_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ten/ten_pred_ssp585_50.rds')
ten_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/ten/ten_pred_ssp585_70.rds')

# Import thresholds
ten_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/ten_thresholds_hist.rds')
ten_low <- ten_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ten_pred_hist_low <- ifel(ten_pred_hist >= ten_low, 1, NA)
ten_ssp245_30_low <- ifel(ten_pred_ssp245_30 >= ten_low, 1, NA)
ten_ssp245_50_low <- ifel(ten_pred_ssp245_50 >= ten_low, 1, NA)
ten_ssp245_70_low <- ifel(ten_pred_ssp245_70 >= ten_low, 1, NA)
ten_ssp585_30_low <- ifel(ten_pred_ssp585_30 >= ten_low, 1, NA)
ten_ssp585_50_low <- ifel(ten_pred_ssp585_50 >= ten_low, 1, NA)
ten_ssp585_70_low <- ifel(ten_pred_ssp585_70 >= ten_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(ten_pred_hist_low, main = 'historical')
plot(
  ten_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ten_ssp585_70_low, main = 'ssp585 2070')
plot(
  ten_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(ten_codes)
ten_fut_codes <- c("8.4") # future only, not including disjunt patch in newfoundland and NS
ten_codes_mask <- c(ten_codes, ten_fut_codes) # combine together

# Build ecoregion mask
ten_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ten_codes_mask)

# Mask all suitability rasters
ten_hist_mask <- terra::crop(ten_pred_hist, ten_eco_mask, mask = T)
ten_ssp245_30_mask <- terra::crop(ten_pred_ssp245_30, ten_eco_mask, mask = T)
ten_ssp245_50_mask <- terra::crop(ten_pred_ssp245_50, ten_eco_mask, mask = T)
ten_ssp245_70_mask <- terra::crop(ten_pred_ssp245_70, ten_eco_mask, mask = T)
ten_ssp585_30_mask <- terra::crop(ten_pred_ssp585_30, ten_eco_mask, mask = T)
ten_ssp585_50_mask <- terra::crop(ten_pred_ssp585_50, ten_eco_mask, mask = T)
ten_ssp585_70_mask <- terra::crop(ten_pred_ssp585_70, ten_eco_mask, mask = T)

# Save all masked rasters
ten_out_dir <- paste0(out_dir, '/ten/')
dir.create(ten_out_dir, showWarnings = FALSE)
saveRDS(ten_hist_mask, paste0(ten_out_dir, 'ten_hist_mask.rds'))
saveRDS(ten_ssp245_30_mask, paste0(ten_out_dir, 'ten_ssp245_30_mask.rds'))
saveRDS(ten_ssp245_50_mask, paste0(ten_out_dir, 'ten_ssp245_50_mask.rds'))
saveRDS(ten_ssp245_70_mask, paste0(ten_out_dir, 'ten_ssp245_70_mask.rds'))
saveRDS(ten_ssp585_30_mask, paste0(ten_out_dir, 'ten_ssp585_30_mask.rds'))
saveRDS(ten_ssp585_50_mask, paste0(ten_out_dir, 'ten_ssp585_50_mask.rds'))
saveRDS(ten_ssp585_70_mask, paste0(ten_out_dir, 'ten_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ten_codes", "ten_eco_hist",
  "ten_pred_hist", "ten_pred_ssp245_30", "ten_pred_ssp245_50", "ten_pred_ssp245_70",
  "ten_pred_ssp585_30", "ten_pred_ssp585_50", "ten_pred_ssp585_70",
  "ten_thresholds", "ten_low",
  "ten_pred_hist_low", "ten_ssp245_30_low", "ten_ssp245_50_low", "ten_ssp245_70_low",
  "ten_ssp585_30_low", "ten_ssp585_50_low", "ten_ssp585_70_low",
  "ten_fut_codes", "ten_codes_mask", "ten_eco_mask",
  "ten_hist_mask", "ten_ssp245_30_mask", "ten_ssp245_50_mask", "ten_ssp245_70_mask",
  "ten_ssp585_30_mask", "ten_ssp585_50_mask", "ten_ssp585_70_mask",
  "ten_out_dir"
))
gc()

# V. uliginosum masking ---------------------------------------------------
# What codes did it exist in historically?
uli_codes <- readRDS('./bg_data/eco_code/eco_ occ_uli_thin _code.rds')

# Subset historical ecoregions
uli_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% uli_codes)

# Import suitability rasters
uli_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/uli/uli_pred_hist.rds')
uli_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/uli/uli_pred_ssp245_30.rds')
uli_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/uli/uli_pred_ssp245_50.rds')
uli_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/uli/uli_pred_ssp245_70.rds')
uli_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/uli/uli_pred_ssp585_30.rds')
uli_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/uli/uli_pred_ssp585_50.rds')
uli_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/uli/uli_pred_ssp585_70.rds')

# Import thresholds
uli_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/uli_thresholds_hist.rds')
uli_low <- uli_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
uli_pred_hist_low <- ifel(uli_pred_hist >= uli_low, 1, NA)
uli_ssp245_30_low <- ifel(uli_pred_ssp245_30 >= uli_low, 1, NA)
uli_ssp245_50_low <- ifel(uli_pred_ssp245_50 >= uli_low, 1, NA)
uli_ssp245_70_low <- ifel(uli_pred_ssp245_70 >= uli_low, 1, NA)
uli_ssp585_30_low <- ifel(uli_pred_ssp585_30 >= uli_low, 1, NA)
uli_ssp585_50_low <- ifel(uli_pred_ssp585_50 >= uli_low, 1, NA)
uli_ssp585_70_low <- ifel(uli_pred_ssp585_70 >= uli_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(uli_pred_hist_low, main = 'historical')
plot(
  uli_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(uli_ssp585_70_low, main = 'ssp585 2070')
plot(
  uli_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(uli_codes)
uli_fut_codes <- c("9.2", "9.3")
uli_codes_mask <- c(uli_codes, uli_fut_codes) # combine together

# Build ecoregion mask
uli_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% uli_codes_mask)

# Mask all suitability rasters
uli_hist_mask <- terra::crop(uli_pred_hist, uli_eco_mask, mask = T)
uli_ssp245_30_mask <- terra::crop(uli_pred_ssp245_30, uli_eco_mask, mask = T)
uli_ssp245_50_mask <- terra::crop(uli_pred_ssp245_50, uli_eco_mask, mask = T)
uli_ssp245_70_mask <- terra::crop(uli_pred_ssp245_70, uli_eco_mask, mask = T)
uli_ssp585_30_mask <- terra::crop(uli_pred_ssp585_30, uli_eco_mask, mask = T)
uli_ssp585_50_mask <- terra::crop(uli_pred_ssp585_50, uli_eco_mask, mask = T)
uli_ssp585_70_mask <- terra::crop(uli_pred_ssp585_70, uli_eco_mask, mask = T)

# Save all masked rasters
uli_out_dir <- paste0(out_dir, '/uli/')
dir.create(uli_out_dir, showWarnings = FALSE)
saveRDS(uli_hist_mask, paste0(uli_out_dir, 'uli_hist_mask.rds'))
saveRDS(uli_ssp245_30_mask, paste0(uli_out_dir, 'uli_ssp245_30_mask.rds'))
saveRDS(uli_ssp245_50_mask, paste0(uli_out_dir, 'uli_ssp245_50_mask.rds'))
saveRDS(uli_ssp245_70_mask, paste0(uli_out_dir, 'uli_ssp245_70_mask.rds'))
saveRDS(uli_ssp585_30_mask, paste0(uli_out_dir, 'uli_ssp585_30_mask.rds'))
saveRDS(uli_ssp585_50_mask, paste0(uli_out_dir, 'uli_ssp585_50_mask.rds'))
saveRDS(uli_ssp585_70_mask, paste0(uli_out_dir, 'uli_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "uli_codes", "uli_eco_hist",
  "uli_pred_hist", "uli_pred_ssp245_30", "uli_pred_ssp245_50", "uli_pred_ssp245_70",
  "uli_pred_ssp585_30", "uli_pred_ssp585_50", "uli_pred_ssp585_70",
  "uli_thresholds", "uli_low",
  "uli_pred_hist_low", "uli_ssp245_30_low", "uli_ssp245_50_low", "uli_ssp245_70_low",
  "uli_ssp585_30_low", "uli_ssp585_50_low", "uli_ssp585_70_low",
  "uli_fut_codes", "uli_codes_mask", "uli_eco_mask",
  "uli_hist_mask", "uli_ssp245_30_mask", "uli_ssp245_50_mask", "uli_ssp245_70_mask",
  "uli_ssp585_30_mask", "uli_ssp585_50_mask", "uli_ssp585_70_mask",
  "uli_out_dir"
))
gc()

# V. vitis-idaea masking --------------------------------------------------
# What codes did it exist in historically?
vid_codes <- readRDS('./bg_data/eco_code/eco_ occ_vid_thin _code.rds')

# Subset historical ecoregions
vid_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% vid_codes)

# Import suitability rasters
vid_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/vid/vid_pred_hist.rds')
vid_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/vid/vid_pred_ssp245_30.rds')
vid_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/vid/vid_pred_ssp245_50.rds')
vid_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/vid/vid_pred_ssp245_70.rds')
vid_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/vid/vid_pred_ssp585_30.rds')
vid_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/vid/vid_pred_ssp585_50.rds')
vid_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/vid/vid_pred_ssp585_70.rds')

# Import thresholds
vid_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/thresholds/vid_thresholds_hist.rds')
vid_low <- vid_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
vid_pred_hist_low <- ifel(vid_pred_hist >= vid_low, 1, NA)
vid_ssp245_30_low <- ifel(vid_pred_ssp245_30 >= vid_low, 1, NA)
vid_ssp245_50_low <- ifel(vid_pred_ssp245_50 >= vid_low, 1, NA)
vid_ssp245_70_low <- ifel(vid_pred_ssp245_70 >= vid_low, 1, NA)
vid_ssp585_30_low <- ifel(vid_pred_ssp585_30 >= vid_low, 1, NA)
vid_ssp585_50_low <- ifel(vid_pred_ssp585_50 >= vid_low, 1, NA)
vid_ssp585_70_low <- ifel(vid_pred_ssp585_70 >= vid_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(vid_pred_hist_low, main = 'historical')
plot(
  vid_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(vid_ssp585_70_low, main = 'ssp585 2070')
plot(
  vid_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(vid_codes)
vid_fut_codes <- c("9.3", "10.1")
vid_codes_mask <- c(vid_codes, vid_fut_codes) # combine together

# Build ecoregion mask
vid_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% vid_codes_mask)

# Mask all suitability rasters
vid_hist_mask <- terra::crop(vid_pred_hist, vid_eco_mask, mask = T)
vid_ssp245_30_mask <- terra::crop(vid_pred_ssp245_30, vid_eco_mask, mask = T)
vid_ssp245_50_mask <- terra::crop(vid_pred_ssp245_50, vid_eco_mask, mask = T)
vid_ssp245_70_mask <- terra::crop(vid_pred_ssp245_70, vid_eco_mask, mask = T)
vid_ssp585_30_mask <- terra::crop(vid_pred_ssp585_30, vid_eco_mask, mask = T)
vid_ssp585_50_mask <- terra::crop(vid_pred_ssp585_50, vid_eco_mask, mask = T)
vid_ssp585_70_mask <- terra::crop(vid_pred_ssp585_70, vid_eco_mask, mask = T)

# Save all masked rasters
vid_out_dir <- paste0(out_dir, '/vid/')
dir.create(vid_out_dir, showWarnings = FALSE)
saveRDS(vid_hist_mask, paste0(vid_out_dir, 'vid_hist_mask.rds'))
saveRDS(vid_ssp245_30_mask, paste0(vid_out_dir, 'vid_ssp245_30_mask.rds'))
saveRDS(vid_ssp245_50_mask, paste0(vid_out_dir, 'vid_ssp245_50_mask.rds'))
saveRDS(vid_ssp245_70_mask, paste0(vid_out_dir, 'vid_ssp245_70_mask.rds'))
saveRDS(vid_ssp585_30_mask, paste0(vid_out_dir, 'vid_ssp585_30_mask.rds'))
saveRDS(vid_ssp585_50_mask, paste0(vid_out_dir, 'vid_ssp585_50_mask.rds'))
saveRDS(vid_ssp585_70_mask, paste0(vid_out_dir, 'vid_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "vid_codes", "vid_eco_hist",
  "vid_pred_hist", "vid_pred_ssp245_30", "vid_pred_ssp245_50", "vid_pred_ssp245_70",
  "vid_pred_ssp585_30", "vid_pred_ssp585_50", "vid_pred_ssp585_70",
  "vid_thresholds", "vid_low",
  "vid_pred_hist_low", "vid_ssp245_30_low", "vid_ssp245_50_low", "vid_ssp245_70_low",
  "vid_ssp585_30_low", "vid_ssp585_50_low", "vid_ssp585_70_low",
  "vid_fut_codes", "vid_codes_mask", "vid_eco_mask",
  "vid_hist_mask", "vid_ssp245_30_mask", "vid_ssp245_50_mask", "vid_ssp245_70_mask",
  "vid_ssp585_30_mask", "vid_ssp585_50_mask", "vid_ssp585_70_mask",
  "vid_out_dir"
))
gc()

##### CORYM SUBSPECIES #####
# V. ashei masking --------------------------------------------------------
# What codes did it exist in historically?
ash_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_ash_thin _code.rds')

# Subset historical ecoregions
ash_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ash_codes)

# Import suitability rasters
ash_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ash/ash_pred_hist.rds')
ash_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ash/ash_pred_ssp245_30.rds')
ash_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ash/ash_pred_ssp245_50.rds')
ash_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ash/ash_pred_ssp245_70.rds')
ash_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ash/ash_pred_ssp585_30.rds')
ash_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ash/ash_pred_ssp585_50.rds')
ash_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ash/ash_pred_ssp585_70.rds')

# Import thresholds
ash_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/ash_thresholds_hist.rds')
ash_low <- ash_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ash_pred_hist_low <- ifel(ash_pred_hist >= ash_low, 1, NA)
ash_ssp245_30_low <- ifel(ash_pred_ssp245_30 >= ash_low, 1, NA)
ash_ssp245_50_low <- ifel(ash_pred_ssp245_50 >= ash_low, 1, NA)
ash_ssp245_70_low <- ifel(ash_pred_ssp245_70 >= ash_low, 1, NA)
ash_ssp585_30_low <- ifel(ash_pred_ssp585_30 >= ash_low, 1, NA)
ash_ssp585_50_low <- ifel(ash_pred_ssp585_50 >= ash_low, 1, NA)
ash_ssp585_70_low <- ifel(ash_pred_ssp585_70 >= ash_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(ash_pred_hist_low, main = 'historical')
plot(
  ash_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ash_ssp585_70_low, main = 'ssp585 2070')
plot(
  ash_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(ash_codes)
ash_fut_codes <- c("15.4", "9.5", "9.4")
ash_codes_mask <- c(ash_codes, ash_fut_codes) # combine together

# Build ecoregion mask
ash_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ash_codes_mask)

# Mask all suitability rasters
ash_hist_mask <- terra::crop(ash_pred_hist, ash_eco_mask, mask = T)
ash_ssp245_30_mask <- terra::crop(ash_pred_ssp245_30, ash_eco_mask, mask = T)
ash_ssp245_50_mask <- terra::crop(ash_pred_ssp245_50, ash_eco_mask, mask = T)
ash_ssp245_70_mask <- terra::crop(ash_pred_ssp245_70, ash_eco_mask, mask = T)
ash_ssp585_30_mask <- terra::crop(ash_pred_ssp585_30, ash_eco_mask, mask = T)
ash_ssp585_50_mask <- terra::crop(ash_pred_ssp585_50, ash_eco_mask, mask = T)
ash_ssp585_70_mask <- terra::crop(ash_pred_ssp585_70, ash_eco_mask, mask = T)

# Save all masked rasters
ash_out_dir <- paste0(out_dir, '/ash/')
dir.create(ash_out_dir, showWarnings = FALSE)
saveRDS(ash_hist_mask, paste0(ash_out_dir, 'ash_hist_mask.rds'))
saveRDS(ash_ssp245_30_mask, paste0(ash_out_dir, 'ash_ssp245_30_mask.rds'))
saveRDS(ash_ssp245_50_mask, paste0(ash_out_dir, 'ash_ssp245_50_mask.rds'))
saveRDS(ash_ssp245_70_mask, paste0(ash_out_dir, 'ash_ssp245_70_mask.rds'))
saveRDS(ash_ssp585_30_mask, paste0(ash_out_dir, 'ash_ssp585_30_mask.rds'))
saveRDS(ash_ssp585_50_mask, paste0(ash_out_dir, 'ash_ssp585_50_mask.rds'))
saveRDS(ash_ssp585_70_mask, paste0(ash_out_dir, 'ash_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ash_codes", "ash_eco_hist",
  "ash_pred_hist", "ash_pred_ssp245_30", "ash_pred_ssp245_50", "ash_pred_ssp245_70",
  "ash_pred_ssp585_30", "ash_pred_ssp585_50", "ash_pred_ssp585_70",
  "ash_thresholds", "ash_low",
  "ash_pred_hist_low", "ash_ssp245_30_low", "ash_ssp245_50_low", "ash_ssp245_70_low",
  "ash_ssp585_30_low", "ash_ssp585_50_low", "ash_ssp585_70_low",
  "ash_fut_codes", "ash_codes_mask", "ash_eco_mask",
  "ash_hist_mask", "ash_ssp245_30_mask", "ash_ssp245_50_mask", "ash_ssp245_70_mask",
  "ash_ssp585_30_mask", "ash_ssp585_50_mask", "ash_ssp585_70_mask",
  "ash_out_dir"
))
gc()

# V. caesariense masking --------------------------------------------------
# What codes did it exist in historically?
# THIS MODEL IS REALLY STRANGE
# MAY NEED TO RERUN !! THE HISTORICAL SUITABILITY IS HIGHEST IN AREA WITHOUT OCCURRENCE??
# Maybe expand background
cae_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_occ_cae_thin_code_v2.rds')

# Subset historical ecoregions
cae_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cae_codes)

# Import suitability rasters
cae_pred_hist <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/cae2/cae2_pred_hist.rds')
cae_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/cae2/cae2_pred_ssp245_30.rds')
cae_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/cae2/cae2_pred_ssp245_50.rds')
cae_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/cae2/cae2_pred_ssp245_70.rds')
cae_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/cae2/cae2_pred_ssp585_30.rds')
cae_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/cae2/cae2_pred_ssp585_50.rds')
cae_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/cae2/cae2_pred_ssp585_70.rds')

# Import thresholds
cae_thresholds <- readRDS('./sdm_output/sdm_output_feb_25_2026/corym_sub/thresholds/cae_thresholds_hist.rds')
cae_low <- cae_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
cae_pred_hist_low <- ifel(cae_pred_hist >= cae_low, 1, NA)
cae_ssp245_30_low <- ifel(cae_pred_ssp245_30 >= cae_low, 1, NA)
cae_ssp245_50_low <- ifel(cae_pred_ssp245_50 >= cae_low, 1, NA)
cae_ssp245_70_low <- ifel(cae_pred_ssp245_70 >= cae_low, 1, NA)
cae_ssp585_30_low <- ifel(cae_pred_ssp585_30 >= cae_low, 1, NA)
cae_ssp585_50_low <- ifel(cae_pred_ssp585_50 >= cae_low, 1, NA)
cae_ssp585_70_low <- ifel(cae_pred_ssp585_70 >= cae_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(cae_pred_hist_low, main = 'historical')
plot(
  cae_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(cae_ssp585_70_low, main = 'ssp585 2070')
plot(
  cae_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(cae_codes)
cae_fut_codes <- c() # 8.4 and 8.2 historical plus rest fut, not their is a bit of dijunt suitability in the west of eco 2.4
cae_codes_mask <- c(cae_codes, cae_fut_codes) # combine together

# Build ecoregion mask
cae_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cae_codes_mask)

# Mask all suitability rasters
cae_hist_mask <- terra::crop(cae_pred_hist, cae_eco_mask, mask = T)
cae_ssp245_30_mask <- terra::crop(cae_pred_ssp245_30, cae_eco_mask, mask = T)
cae_ssp245_50_mask <- terra::crop(cae_pred_ssp245_50, cae_eco_mask, mask = T)
cae_ssp245_70_mask <- terra::crop(cae_pred_ssp245_70, cae_eco_mask, mask = T)
cae_ssp585_30_mask <- terra::crop(cae_pred_ssp585_30, cae_eco_mask, mask = T)
cae_ssp585_50_mask <- terra::crop(cae_pred_ssp585_50, cae_eco_mask, mask = T)
cae_ssp585_70_mask <- terra::crop(cae_pred_ssp585_70, cae_eco_mask, mask = T)

# Save all masked rasters
cae_out_dir <- paste0(out_dir, '/cae/')
dir.create(cae_out_dir, showWarnings = FALSE)
saveRDS(cae_hist_mask, paste0(cae_out_dir, 'cae_hist_mask.rds'))
saveRDS(cae_ssp245_30_mask, paste0(cae_out_dir, 'cae_ssp245_30_mask.rds'))
saveRDS(cae_ssp245_50_mask, paste0(cae_out_dir, 'cae_ssp245_50_mask.rds'))
saveRDS(cae_ssp245_70_mask, paste0(cae_out_dir, 'cae_ssp245_70_mask.rds'))
saveRDS(cae_ssp585_30_mask, paste0(cae_out_dir, 'cae_ssp585_30_mask.rds'))
saveRDS(cae_ssp585_50_mask, paste0(cae_out_dir, 'cae_ssp585_50_mask.rds'))
saveRDS(cae_ssp585_70_mask, paste0(cae_out_dir, 'cae_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "cae_codes", "cae_eco_hist",
  "cae_pred_hist", "cae_pred_ssp245_30", "cae_pred_ssp245_50", "cae_pred_ssp245_70",
  "cae_pred_ssp585_30", "cae_pred_ssp585_50", "cae_pred_ssp585_70",
  "cae_thresholds", "cae_low",
  "cae_pred_hist_low", "cae_ssp245_30_low", "cae_ssp245_50_low", "cae_ssp245_70_low",
  "cae_ssp585_30_low", "cae_ssp585_50_low", "cae_ssp585_70_low",
  "cae_fut_codes", "cae_codes_mask", "cae_eco_mask",
  "cae_hist_mask", "cae_ssp245_30_mask", "cae_ssp245_50_mask", "cae_ssp245_70_mask",
  "cae_ssp585_30_mask", "cae_ssp585_50_mask", "cae_ssp585_70_mask",
  "cae_out_dir"
))
gc()

# V. corymbosum masking ---------------------------------------------------
# What codes did it exist in historically?
cor2_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_cor2_thin _code.rds')

# Subset historical ecoregions
cor2_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cor2_codes)

# Import suitability rasters
cor2_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cor2/cor2_pred_hist.rds')
cor2_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cor2/cor2_pred_ssp245_30.rds')
cor2_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cor2/cor2_pred_ssp245_50.rds')
cor2_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cor2/cor2_pred_ssp245_70.rds')
cor2_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cor2/cor2_pred_ssp585_30.rds')
cor2_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cor2/cor2_pred_ssp585_50.rds')
cor2_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cor2/cor2_pred_ssp585_70.rds')

# Import thresholds
cor2_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/cor2_thresholds_hist.rds')
cor2_low <- cor2_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
cor2_pred_hist_low <- ifel(cor2_pred_hist >= cor2_low, 1, NA)
cor2_ssp245_30_low <- ifel(cor2_pred_ssp245_30 >= cor2_low, 1, NA)
cor2_ssp245_50_low <- ifel(cor2_pred_ssp245_50 >= cor2_low, 1, NA)
cor2_ssp245_70_low <- ifel(cor2_pred_ssp245_70 >= cor2_low, 1, NA)
cor2_ssp585_30_low <- ifel(cor2_pred_ssp585_30 >= cor2_low, 1, NA)
cor2_ssp585_50_low <- ifel(cor2_pred_ssp585_50 >= cor2_low, 1, NA)
cor2_ssp585_70_low <- ifel(cor2_pred_ssp585_70 >= cor2_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(cor2_pred_hist_low, main = 'historical')
plot(
  cor2_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(cor2_ssp585_70_low, main = 'ssp585 2070')
plot(
  cor2_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(cor2_codes)
cor2_fut_codes <- c("4.1", "3.4") 
cor2_codes_mask <- c(cor2_codes, cor2_fut_codes) # combine together

# Build ecoregion mask
cor2_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cor2_codes_mask)

# Mask all suitability rasters
cor2_hist_mask <- terra::crop(cor2_pred_hist, cor2_eco_mask, mask = T)
cor2_ssp245_30_mask <- terra::crop(cor2_pred_ssp245_30, cor2_eco_mask, mask = T)
cor2_ssp245_50_mask <- terra::crop(cor2_pred_ssp245_50, cor2_eco_mask, mask = T)
cor2_ssp245_70_mask <- terra::crop(cor2_pred_ssp245_70, cor2_eco_mask, mask = T)
cor2_ssp585_30_mask <- terra::crop(cor2_pred_ssp585_30, cor2_eco_mask, mask = T)
cor2_ssp585_50_mask <- terra::crop(cor2_pred_ssp585_50, cor2_eco_mask, mask = T)
cor2_ssp585_70_mask <- terra::crop(cor2_pred_ssp585_70, cor2_eco_mask, mask = T)

# Save all masked rasters
cor2_out_dir <- paste0(out_dir, '/cor2/')
dir.create(cor2_out_dir, showWarnings = FALSE)
saveRDS(cor2_hist_mask, paste0(cor2_out_dir, 'cor2_hist_mask.rds'))
saveRDS(cor2_ssp245_30_mask, paste0(cor2_out_dir, 'cor2_ssp245_30_mask.rds'))
saveRDS(cor2_ssp245_50_mask, paste0(cor2_out_dir, 'cor2_ssp245_50_mask.rds'))
saveRDS(cor2_ssp245_70_mask, paste0(cor2_out_dir, 'cor2_ssp245_70_mask.rds'))
saveRDS(cor2_ssp585_30_mask, paste0(cor2_out_dir, 'cor2_ssp585_30_mask.rds'))
saveRDS(cor2_ssp585_50_mask, paste0(cor2_out_dir, 'cor2_ssp585_50_mask.rds'))
saveRDS(cor2_ssp585_70_mask, paste0(cor2_out_dir, 'cor2_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "cor2_codes", "cor2_eco_hist",
  "cor2_pred_hist", "cor2_pred_ssp245_30", "cor2_pred_ssp245_50", "cor2_pred_ssp245_70",
  "cor2_pred_ssp585_30", "cor2_pred_ssp585_50", "cor2_pred_ssp585_70",
  "cor2_thresholds", "cor2_low",
  "cor2_pred_hist_low", "cor2_ssp245_30_low", "cor2_ssp245_50_low", "cor2_ssp245_70_low",
  "cor2_ssp585_30_low", "cor2_ssp585_50_low", "cor2_ssp585_70_low",
  "cor2_fut_codes", "cor2_codes_mask", "cor2_eco_mask",
  "cor2_hist_mask", "cor2_ssp245_30_mask", "cor2_ssp245_50_mask", "cor2_ssp245_70_mask",
  "cor2_ssp585_30_mask", "cor2_ssp585_50_mask", "cor2_ssp585_70_mask",
  "cor2_out_dir"
))
gc()


# V. constablaei masking --------------------------------------------------
# What codes did it exist in historically?
cot_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_cot_thin _code.rds')

# Subset historical ecoregions
cot_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cot_codes)

# Import suitability rasters
cot_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cot/cot_pred_hist.rds')
cot_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cot/cot_pred_ssp245_30.rds')
cot_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cot/cot_pred_ssp245_50.rds')
cot_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cot/cot_pred_ssp245_70.rds')
cot_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cot/cot_pred_ssp585_30.rds')
cot_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cot/cot_pred_ssp585_50.rds')
cot_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/cot/cot_pred_ssp585_70.rds')

# Import thresholds
cot_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/cot_thresholds_hist.rds')
cot_low <- cot_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
cot_pred_hist_low <- ifel(cot_pred_hist >= cot_low, 1, NA)
cot_ssp245_30_low <- ifel(cot_pred_ssp245_30 >= cot_low, 1, NA)
cot_ssp245_50_low <- ifel(cot_pred_ssp245_50 >= cot_low, 1, NA)
cot_ssp245_70_low <- ifel(cot_pred_ssp245_70 >= cot_low, 1, NA)
cot_ssp585_30_low <- ifel(cot_pred_ssp585_30 >= cot_low, 1, NA)
cot_ssp585_50_low <- ifel(cot_pred_ssp585_50 >= cot_low, 1, NA)
cot_ssp585_70_low <- ifel(cot_pred_ssp585_70 >= cot_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(cot_pred_hist_low, main = 'historical')
plot(
  cot_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(cot_ssp585_70_low, main = 'ssp585 2070')
plot(
  cot_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(cot_codes)
cot_fut_codes <- c() # No codes to add for the future, there is lots of supurious adhacent suitability especially into texas and mexico
cot_codes_mask <- c(cot_codes, cot_fut_codes) # combine together

# Build ecoregion mask
cot_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% cot_codes_mask)

# Mask all suitability rasters
cot_hist_mask <- terra::crop(cot_pred_hist, cot_eco_mask, mask = T)
cot_ssp245_30_mask <- terra::crop(cot_pred_ssp245_30, cot_eco_mask, mask = T)
cot_ssp245_50_mask <- terra::crop(cot_pred_ssp245_50, cot_eco_mask, mask = T)
cot_ssp245_70_mask <- terra::crop(cot_pred_ssp245_70, cot_eco_mask, mask = T)
cot_ssp585_30_mask <- terra::crop(cot_pred_ssp585_30, cot_eco_mask, mask = T)
cot_ssp585_50_mask <- terra::crop(cot_pred_ssp585_50, cot_eco_mask, mask = T)
cot_ssp585_70_mask <- terra::crop(cot_pred_ssp585_70, cot_eco_mask, mask = T)

# Save all masked rasters
cot_out_dir <- paste0(out_dir, '/cot/')
dir.create(cot_out_dir, showWarnings = FALSE)
saveRDS(cot_hist_mask, paste0(cot_out_dir, 'cot_hist_mask.rds'))
saveRDS(cot_ssp245_30_mask, paste0(cot_out_dir, 'cot_ssp245_30_mask.rds'))
saveRDS(cot_ssp245_50_mask, paste0(cot_out_dir, 'cot_ssp245_50_mask.rds'))
saveRDS(cot_ssp245_70_mask, paste0(cot_out_dir, 'cot_ssp245_70_mask.rds'))
saveRDS(cot_ssp585_30_mask, paste0(cot_out_dir, 'cot_ssp585_30_mask.rds'))
saveRDS(cot_ssp585_50_mask, paste0(cot_out_dir, 'cot_ssp585_50_mask.rds'))
saveRDS(cot_ssp585_70_mask, paste0(cot_out_dir, 'cot_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "cot_codes", "cot_eco_hist",
  "cot_pred_hist", "cot_pred_ssp245_30", "cot_pred_ssp245_50", "cot_pred_ssp245_70",
  "cot_pred_ssp585_30", "cot_pred_ssp585_50", "cot_pred_ssp585_70",
  "cot_thresholds", "cot_low",
  "cot_pred_hist_low", "cot_ssp245_30_low", "cot_ssp245_50_low", "cot_ssp245_70_low",
  "cot_ssp585_30_low", "cot_ssp585_50_low", "cot_ssp585_70_low",
  "cot_fut_codes", "cot_codes_mask", "cot_eco_mask",
  "cot_hist_mask", "cot_ssp245_30_mask", "cot_ssp245_50_mask", "cot_ssp245_70_mask",
  "cot_ssp585_30_mask", "cot_ssp585_50_mask", "cot_ssp585_70_mask",
  "cot_out_dir"
))
gc()

# V. elliottii masking ----------------------------------------------------
ell_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_ell_thin _code.rds')

# Subset historical ecoregions
ell_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ell_codes)

# Import suitability rasters
ell_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ell/ell_pred_hist.rds')
ell_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ell/ell_pred_ssp245_30.rds')
ell_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ell/ell_pred_ssp245_50.rds')
ell_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ell/ell_pred_ssp245_70.rds')
ell_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ell/ell_pred_ssp585_30.rds')
ell_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ell/ell_pred_ssp585_50.rds')
ell_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/ell/ell_pred_ssp585_70.rds')

# Import thresholds
ell_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/ell_thresholds_hist.rds')
ell_low <- ell_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
ell_pred_hist_low <- ifel(ell_pred_hist >= ell_low, 1, NA)
ell_ssp245_30_low <- ifel(ell_pred_ssp245_30 >= ell_low, 1, NA)
ell_ssp245_50_low <- ifel(ell_pred_ssp245_50 >= ell_low, 1, NA)
ell_ssp245_70_low <- ifel(ell_pred_ssp245_70 >= ell_low, 1, NA)
ell_ssp585_30_low <- ifel(ell_pred_ssp585_30 >= ell_low, 1, NA)
ell_ssp585_50_low <- ifel(ell_pred_ssp585_50 >= ell_low, 1, NA)
ell_ssp585_70_low <- ifel(ell_pred_ssp585_70 >= ell_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(ell_pred_hist_low, main = 'historical')
plot(
  ell_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(ell_ssp585_70_low, main = 'ssp585 2070')
plot(
  ell_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(ell_codes)
ell_fut_codes <- c() # No codes to add for the future
ell_codes_mask <- c(ell_codes, ell_fut_codes) # combine together

# Build ecoregion mask
ell_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% ell_codes_mask)

# Mask all suitability rasters
ell_hist_mask <- terra::crop(ell_pred_hist, ell_eco_mask, mask = T)
ell_ssp245_30_mask <- terra::crop(ell_pred_ssp245_30, ell_eco_mask, mask = T)
ell_ssp245_50_mask <- terra::crop(ell_pred_ssp245_50, ell_eco_mask, mask = T)
ell_ssp245_70_mask <- terra::crop(ell_pred_ssp245_70, ell_eco_mask, mask = T)
ell_ssp585_30_mask <- terra::crop(ell_pred_ssp585_30, ell_eco_mask, mask = T)
ell_ssp585_50_mask <- terra::crop(ell_pred_ssp585_50, ell_eco_mask, mask = T)
ell_ssp585_70_mask <- terra::crop(ell_pred_ssp585_70, ell_eco_mask, mask = T)

# Save all masked rasters
ell_out_dir <- paste0(out_dir, '/ell/')
dir.create(ell_out_dir, showWarnings = FALSE)
saveRDS(ell_hist_mask, paste0(ell_out_dir, 'ell_hist_mask.rds'))
saveRDS(ell_ssp245_30_mask, paste0(ell_out_dir, 'ell_ssp245_30_mask.rds'))
saveRDS(ell_ssp245_50_mask, paste0(ell_out_dir, 'ell_ssp245_50_mask.rds'))
saveRDS(ell_ssp245_70_mask, paste0(ell_out_dir, 'ell_ssp245_70_mask.rds'))
saveRDS(ell_ssp585_30_mask, paste0(ell_out_dir, 'ell_ssp585_30_mask.rds'))
saveRDS(ell_ssp585_50_mask, paste0(ell_out_dir, 'ell_ssp585_50_mask.rds'))
saveRDS(ell_ssp585_70_mask, paste0(ell_out_dir, 'ell_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "ell_codes", "ell_eco_hist",
  "ell_pred_hist", "ell_pred_ssp245_30", "ell_pred_ssp245_50", "ell_pred_ssp245_70",
  "ell_pred_ssp585_30", "ell_pred_ssp585_50", "ell_pred_ssp585_70",
  "ell_thresholds", "ell_low",
  "ell_pred_hist_low", "ell_ssp245_30_low", "ell_ssp245_50_low", "ell_ssp245_70_low",
  "ell_ssp585_30_low", "ell_ssp585_50_low", "ell_ssp585_70_low",
  "ell_fut_codes", "ell_codes_mask", "ell_eco_mask",
  "ell_hist_mask", "ell_ssp245_30_mask", "ell_ssp245_50_mask", "ell_ssp245_70_mask",
  "ell_ssp585_30_mask", "ell_ssp585_50_mask", "ell_ssp585_70_mask",
  "ell_out_dir"
))
gc()

# V. formosum masking -----------------------------------------------------
# What codes did it exist in historically?
for_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_for_thin _code.rds')

# Subset historical ecoregions
for_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% for_codes)

# Import suitability rasters
for_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/for/for_pred_hist.rds')
for_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/for/for_pred_ssp245_30.rds')
for_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/for/for_pred_ssp245_50.rds')
for_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/for/for_pred_ssp245_70.rds')
for_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/for/for_pred_ssp585_30.rds')
for_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/for/for_pred_ssp585_50.rds')
for_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/for/for_pred_ssp585_70.rds')

# Import thresholds
for_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/for_thresholds_hist.rds')
for_low <- for_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
for_pred_hist_low <- ifel(for_pred_hist >= for_low, 1, NA)
for_ssp245_30_low <- ifel(for_pred_ssp245_30 >= for_low, 1, NA)
for_ssp245_50_low <- ifel(for_pred_ssp245_50 >= for_low, 1, NA)
for_ssp245_70_low <- ifel(for_pred_ssp245_70 >= for_low, 1, NA)
for_ssp585_30_low <- ifel(for_pred_ssp585_30 >= for_low, 1, NA)
for_ssp585_50_low <- ifel(for_pred_ssp585_50 >= for_low, 1, NA)
for_ssp585_70_low <- ifel(for_pred_ssp585_70 >= for_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(for_pred_hist_low, main = 'historical')
plot(
  for_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(for_ssp585_70_low, main = 'ssp585 2070')
plot(
  for_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(for_codes)
for_fut_codes <- c("15.4") # 15.4 is historical 
for_codes_mask <- c(for_codes, for_fut_codes) # combine together

# Build ecoregion mask
for_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% for_codes_mask)

# Mask all suitability rasters
for_hist_mask <- terra::crop(for_pred_hist, for_eco_mask, mask = T)
for_ssp245_30_mask <- terra::crop(for_pred_ssp245_30, for_eco_mask, mask = T)
for_ssp245_50_mask <- terra::crop(for_pred_ssp245_50, for_eco_mask, mask = T)
for_ssp245_70_mask <- terra::crop(for_pred_ssp245_70, for_eco_mask, mask = T)
for_ssp585_30_mask <- terra::crop(for_pred_ssp585_30, for_eco_mask, mask = T)
for_ssp585_50_mask <- terra::crop(for_pred_ssp585_50, for_eco_mask, mask = T)
for_ssp585_70_mask <- terra::crop(for_pred_ssp585_70, for_eco_mask, mask = T)

# Save all masked rasters
for_out_dir <- paste0(out_dir, '/for/')
dir.create(for_out_dir, showWarnings = FALSE)
saveRDS(for_hist_mask, paste0(for_out_dir, 'for_hist_mask.rds'))
saveRDS(for_ssp245_30_mask, paste0(for_out_dir, 'for_ssp245_30_mask.rds'))
saveRDS(for_ssp245_50_mask, paste0(for_out_dir, 'for_ssp245_50_mask.rds'))
saveRDS(for_ssp245_70_mask, paste0(for_out_dir, 'for_ssp245_70_mask.rds'))
saveRDS(for_ssp585_30_mask, paste0(for_out_dir, 'for_ssp585_30_mask.rds'))
saveRDS(for_ssp585_50_mask, paste0(for_out_dir, 'for_ssp585_50_mask.rds'))
saveRDS(for_ssp585_70_mask, paste0(for_out_dir, 'for_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "for_codes", "for_eco_hist",
  "for_pred_hist", "for_pred_ssp245_30", "for_pred_ssp245_50", "for_pred_ssp245_70",
  "for_pred_ssp585_30", "for_pred_ssp585_50", "for_pred_ssp585_70",
  "for_thresholds", "for_low",
  "for_pred_hist_low", "for_ssp245_30_low", "for_ssp245_50_low", "for_ssp245_70_low",
  "for_ssp585_30_low", "for_ssp585_50_low", "for_ssp585_70_low",
  "for_fut_codes", "for_codes_mask", "for_eco_mask",
  "for_hist_mask", "for_ssp245_30_mask", "for_ssp245_50_mask", "for_ssp245_70_mask",
  "for_ssp585_30_mask", "for_ssp585_50_mask", "for_ssp585_70_mask",
  "for_out_dir"
))

gc()

# V. fuscatum masking -----------------------------------------------------
# What codes did it exist in historically?
fus_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_fus_thin _code.rds')

# Subset historical ecoregions
fus_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% fus_codes)

# Import suitability rasters
fus_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/fus/fus_pred_hist.rds')
fus_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/fus/fus_pred_ssp245_30.rds')
fus_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/fus/fus_pred_ssp245_50.rds')
fus_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/fus/fus_pred_ssp245_70.rds')
fus_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/fus/fus_pred_ssp585_30.rds')
fus_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/fus/fus_pred_ssp585_50.rds')
fus_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/fus/fus_pred_ssp585_70.rds')

# Import thresholds
fus_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/fus_thresholds_hist.rds')
fus_low <- fus_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
fus_pred_hist_low <- ifel(fus_pred_hist >= fus_low, 1, NA)
fus_ssp245_30_low <- ifel(fus_pred_ssp245_30 >= fus_low, 1, NA)
fus_ssp245_50_low <- ifel(fus_pred_ssp245_50 >= fus_low, 1, NA)
fus_ssp245_70_low <- ifel(fus_pred_ssp245_70 >= fus_low, 1, NA)
fus_ssp585_30_low <- ifel(fus_pred_ssp585_30 >= fus_low, 1, NA)
fus_ssp585_50_low <- ifel(fus_pred_ssp585_50 >= fus_low, 1, NA)
fus_ssp585_70_low <- ifel(fus_pred_ssp585_70 >= fus_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(fus_pred_hist_low, main = 'historical')
plot(
  fus_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(fus_ssp585_70_low, main = 'ssp585 2070')
plot(
  fus_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(fus_codes)
fus_fut_codes <- c("15.4", "5.2", "5.3", "5.1", "3.4", "2.4", "8.2", "1.1") # 15.4 historical and all rest future
fus_codes_mask <- c(fus_codes, fus_fut_codes) # combine together

# Build ecoregion mask
fus_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% fus_codes_mask)

# Mask all suitability rasters
fus_hist_mask <- terra::crop(fus_pred_hist, fus_eco_mask, mask = T)
fus_ssp245_30_mask <- terra::crop(fus_pred_ssp245_30, fus_eco_mask, mask = T)
fus_ssp245_50_mask <- terra::crop(fus_pred_ssp245_50, fus_eco_mask, mask = T)
fus_ssp245_70_mask <- terra::crop(fus_pred_ssp245_70, fus_eco_mask, mask = T)
fus_ssp585_30_mask <- terra::crop(fus_pred_ssp585_30, fus_eco_mask, mask = T)
fus_ssp585_50_mask <- terra::crop(fus_pred_ssp585_50, fus_eco_mask, mask = T)
fus_ssp585_70_mask <- terra::crop(fus_pred_ssp585_70, fus_eco_mask, mask = T)

# Save all masked rasters
fus_out_dir <- paste0(out_dir, '/fus/')
dir.create(fus_out_dir, showWarnings = FALSE)
saveRDS(fus_hist_mask, paste0(fus_out_dir, 'fus_hist_mask.rds'))
saveRDS(fus_ssp245_30_mask, paste0(fus_out_dir, 'fus_ssp245_30_mask.rds'))
saveRDS(fus_ssp245_50_mask, paste0(fus_out_dir, 'fus_ssp245_50_mask.rds'))
saveRDS(fus_ssp245_70_mask, paste0(fus_out_dir, 'fus_ssp245_70_mask.rds'))
saveRDS(fus_ssp585_30_mask, paste0(fus_out_dir, 'fus_ssp585_30_mask.rds'))
saveRDS(fus_ssp585_50_mask, paste0(fus_out_dir, 'fus_ssp585_50_mask.rds'))
saveRDS(fus_ssp585_70_mask, paste0(fus_out_dir, 'fus_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "fus_codes", "fus_eco_hist",
  "fus_pred_hist", "fus_pred_ssp245_30", "fus_pred_ssp245_50", "fus_pred_ssp245_70",
  "fus_pred_ssp585_30", "fus_pred_ssp585_50", "fus_pred_ssp585_70",
  "fus_thresholds", "fus_low",
  "fus_pred_hist_low", "fus_ssp245_30_low", "fus_ssp245_50_low", "fus_ssp245_70_low",
  "fus_ssp585_30_low", "fus_ssp585_50_low", "fus_ssp585_70_low",
  "fus_fut_codes", "fus_codes_mask", "fus_eco_mask",
  "fus_hist_mask", "fus_ssp245_30_mask", "fus_ssp245_50_mask", "fus_ssp245_70_mask",
  "fus_ssp585_30_mask", "fus_ssp585_50_mask", "fus_ssp585_70_mask",
  "fus_out_dir"
))
gc()

# V. simulatum masking ----------------------------------------------------
# What codes did it exist in historically?
sim_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_sim_thin _code.rds')

# Subset historical ecoregions
sim_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sim_codes)

# Import suitability rasters
sim_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/sim/sim_pred_hist.rds')
sim_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/sim/sim_pred_ssp245_30.rds')
sim_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/sim/sim_pred_ssp245_50.rds')
sim_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/sim/sim_pred_ssp245_70.rds')
sim_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/sim/sim_pred_ssp585_30.rds')
sim_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/sim/sim_pred_ssp585_50.rds')
sim_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/sim/sim_pred_ssp585_70.rds')

# Import thresholds
sim_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/sim_thresholds_hist.rds')
sim_low <- sim_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
sim_pred_hist_low <- ifel(sim_pred_hist >= sim_low, 1, NA)
sim_ssp245_30_low <- ifel(sim_pred_ssp245_30 >= sim_low, 1, NA)
sim_ssp245_50_low <- ifel(sim_pred_ssp245_50 >= sim_low, 1, NA)
sim_ssp245_70_low <- ifel(sim_pred_ssp245_70 >= sim_low, 1, NA)
sim_ssp585_30_low <- ifel(sim_pred_ssp585_30 >= sim_low, 1, NA)
sim_ssp585_50_low <- ifel(sim_pred_ssp585_50 >= sim_low, 1, NA)
sim_ssp585_70_low <- ifel(sim_pred_ssp585_70 >= sim_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(sim_pred_hist_low, main = 'historical')
plot(
  sim_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(sim_ssp585_70_low, main = 'ssp585 2070')
plot(
  sim_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(sim_codes)
sim_fut_codes <- c("8.5") # historical
sim_codes_mask <- c(sim_codes, sim_fut_codes) # combine together

# Build ecoregion mask
sim_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% sim_codes_mask)

# Mask all suitability rasters
sim_hist_mask <- terra::crop(sim_pred_hist, sim_eco_mask, mask = T)
sim_ssp245_30_mask <- terra::crop(sim_pred_ssp245_30, sim_eco_mask, mask = T)
sim_ssp245_50_mask <- terra::crop(sim_pred_ssp245_50, sim_eco_mask, mask = T)
sim_ssp245_70_mask <- terra::crop(sim_pred_ssp245_70, sim_eco_mask, mask = T)
sim_ssp585_30_mask <- terra::crop(sim_pred_ssp585_30, sim_eco_mask, mask = T)
sim_ssp585_50_mask <- terra::crop(sim_pred_ssp585_50, sim_eco_mask, mask = T)
sim_ssp585_70_mask <- terra::crop(sim_pred_ssp585_70, sim_eco_mask, mask = T)

# Save all masked rasters
sim_out_dir <- paste0(out_dir, '/sim/')
dir.create(sim_out_dir, showWarnings = FALSE)
saveRDS(sim_hist_mask, paste0(sim_out_dir, 'sim_hist_mask.rds'))
saveRDS(sim_ssp245_30_mask, paste0(sim_out_dir, 'sim_ssp245_30_mask.rds'))
saveRDS(sim_ssp245_50_mask, paste0(sim_out_dir, 'sim_ssp245_50_mask.rds'))
saveRDS(sim_ssp245_70_mask, paste0(sim_out_dir, 'sim_ssp245_70_mask.rds'))
saveRDS(sim_ssp585_30_mask, paste0(sim_out_dir, 'sim_ssp585_30_mask.rds'))
saveRDS(sim_ssp585_50_mask, paste0(sim_out_dir, 'sim_ssp585_50_mask.rds'))
saveRDS(sim_ssp585_70_mask, paste0(sim_out_dir, 'sim_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "sim_codes", "sim_eco_hist",
  "sim_pred_hist", "sim_pred_ssp245_30", "sim_pred_ssp245_50", "sim_pred_ssp245_70",
  "sim_pred_ssp585_30", "sim_pred_ssp585_50", "sim_pred_ssp585_70",
  "sim_thresholds", "sim_low",
  "sim_pred_hist_low", "sim_ssp245_30_low", "sim_ssp245_50_low", "sim_ssp245_70_low",
  "sim_ssp585_30_low", "sim_ssp585_50_low", "sim_ssp585_70_low",
  "sim_fut_codes", "sim_codes_mask", "sim_eco_mask",
  "sim_hist_mask", "sim_ssp245_30_mask", "sim_ssp245_50_mask", "sim_ssp245_70_mask",
  "sim_ssp585_30_mask", "sim_ssp585_50_mask", "sim_ssp585_70_mask",
  "sim_out_dir"
))
gc()

# V. virgatum masking -----------------------------------------------------
# What codes did it exist in historically?
vir_codes <- readRDS('./bg_data/eco_code/corym_sub/eco_ occ_vir_thin _code.rds')

# Subset historical ecoregions
vir_eco_hist <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% vir_codes)

# Import suitability rasters
vir_pred_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/vir/vir_pred_hist.rds')
vir_pred_ssp245_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/vir/vir_pred_ssp245_30.rds')
vir_pred_ssp245_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/vir/vir_pred_ssp245_50.rds')
vir_pred_ssp245_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/vir/vir_pred_ssp245_70.rds')
vir_pred_ssp585_30 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/vir/vir_pred_ssp585_30.rds')
vir_pred_ssp585_50 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/vir/vir_pred_ssp585_50.rds')
vir_pred_ssp585_70 <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/vir/vir_pred_ssp585_70.rds')

# Import thresholds
vir_thresholds <- readRDS('./sdm_output/sdm_output_feb_10_2026/corym_sub/thresholds/vir_thresholds_hist.rds')
vir_low <- vir_thresholds[1] # get first index

# Make binary rasters
# Only consider suitable cells: 1 = TRUE, NA = FALSE
vir_pred_hist_low <- ifel(vir_pred_hist >= vir_low, 1, NA)
vir_ssp245_30_low <- ifel(vir_pred_ssp245_30 >= vir_low, 1, NA)
vir_ssp245_50_low <- ifel(vir_pred_ssp245_50 >= vir_low, 1, NA)
vir_ssp245_70_low <- ifel(vir_pred_ssp245_70 >= vir_low, 1, NA)
vir_ssp585_30_low <- ifel(vir_pred_ssp585_30 >= vir_low, 1, NA)
vir_ssp585_50_low <- ifel(vir_pred_ssp585_50 >= vir_low, 1, NA)
vir_ssp585_70_low <- ifel(vir_pred_ssp585_70 >= vir_low, 1, NA)

# Now plot each future slice with ecoregions overlaid and crossref
# with https://www.epa.gov/eco-research/ecoregions-north-america to
# select the eco codes to keep...

dev.off()
dev.new()
par(mfrow = c(1, 2)) 
terra::plot(vir_pred_hist_low, main = 'historical')
plot(
  vir_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
terra::plot(vir_ssp585_70_low, main = 'ssp585 2070')
plot(
  vir_eco_hist,
  col = alpha('grey', 0.5),
  border = 'black',
  lwd = 0.2,
  add = T
)
plot(
  ecoNA,
  col = 'transparent',
  border = 'black',
  lwd = 0.2,
  add = T
)

# Codes to add to historical
print(vir_codes)
vir_fut_codes <- c("9.2", "9.4", "9.5", "8.1", "5.3") # 9.2, 9.4, 9.5
vir_codes_mask <- c(vir_codes, vir_fut_codes) # combine together

# Build ecoregion mask
vir_eco_mask <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% vir_codes_mask)

# Mask all suitability rasters
vir_hist_mask <- terra::crop(vir_pred_hist, vir_eco_mask, mask = T)
vir_ssp245_30_mask <- terra::crop(vir_pred_ssp245_30, vir_eco_mask, mask = T)
vir_ssp245_50_mask <- terra::crop(vir_pred_ssp245_50, vir_eco_mask, mask = T)
vir_ssp245_70_mask <- terra::crop(vir_pred_ssp245_70, vir_eco_mask, mask = T)
vir_ssp585_30_mask <- terra::crop(vir_pred_ssp585_30, vir_eco_mask, mask = T)
vir_ssp585_50_mask <- terra::crop(vir_pred_ssp585_50, vir_eco_mask, mask = T)
vir_ssp585_70_mask <- terra::crop(vir_pred_ssp585_70, vir_eco_mask, mask = T)

# Save all masked rasters
vir_out_dir <- paste0(out_dir, '/vir/')
dir.create(vir_out_dir, showWarnings = FALSE)
saveRDS(vir_hist_mask, paste0(vir_out_dir, 'vir_hist_mask.rds'))
saveRDS(vir_ssp245_30_mask, paste0(vir_out_dir, 'vir_ssp245_30_mask.rds'))
saveRDS(vir_ssp245_50_mask, paste0(vir_out_dir, 'vir_ssp245_50_mask.rds'))
saveRDS(vir_ssp245_70_mask, paste0(vir_out_dir, 'vir_ssp245_70_mask.rds'))
saveRDS(vir_ssp585_30_mask, paste0(vir_out_dir, 'vir_ssp585_30_mask.rds'))
saveRDS(vir_ssp585_50_mask, paste0(vir_out_dir, 'vir_ssp585_50_mask.rds'))
saveRDS(vir_ssp585_70_mask, paste0(vir_out_dir, 'vir_ssp585_70_mask.rds'))

# CLEAN UP
rm(list = c(
  "vir_codes", "vir_eco_hist",
  "vir_pred_hist", "vir_pred_ssp245_30", "vir_pred_ssp245_50", "vir_pred_ssp245_70",
  "vir_pred_ssp585_30", "vir_pred_ssp585_50", "vir_pred_ssp585_70",
  "vir_thresholds", "vir_low",
  "vir_pred_hist_low", "vir_ssp245_30_low", "vir_ssp245_50_low", "vir_ssp245_70_low",
  "vir_ssp585_30_low", "vir_ssp585_50_low", "vir_ssp585_70_low",
  "vir_fut_codes", "vir_codes_mask", "vir_eco_mask",
  "vir_hist_mask", "vir_ssp245_30_mask", "vir_ssp245_50_mask", "vir_ssp245_70_mask",
  "vir_ssp585_30_mask", "vir_ssp585_50_mask", "vir_ssp585_70_mask",
  "vir_out_dir"
))
gc()

