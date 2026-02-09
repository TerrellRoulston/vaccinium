# Top ---------------------------------------------------------------------
# thinning occurrence data of Vaccinium
# Terrell Roulston
# Started Nov 20, 2024
# ***NOTE***
# Updated Feb 06, 2026
# Changes: removed Central American species

library(tidyverse) # grammar and data management 
library(terra) # working with spatial data
library(geodata) # basemaps and climate data


# Load cleaned occ data ---------------------------------------------------
occ_ang_clean <- readRDS(file = "./occ_data/clean/occ_ang_clean.rds")
occ_arb_clean <- readRDS(file = "./occ_data/clean/occ_arb_clean.rds")
occ_bor_clean <- readRDS(file = "./occ_data/clean/occ_bor_clean.rds")
occ_ces_clean <- readRDS(file = "./occ_data/clean/occ_ces_clean.rds")
occ_cor_clean <- readRDS(file = "./occ_data/clean/occ_cor_clean.rds")
occ_cra_clean <- readRDS(file = "./occ_data/clean/occ_cra_clean.rds")
occ_dar_clean <- readRDS(file = "./occ_data/clean/occ_dar_clean.rds")
occ_del_clean <- readRDS(file = "./occ_data/clean/occ_del_clean.rds")
occ_ery_clean <- readRDS(file = "./occ_data/clean/occ_ery_clean.rds")
occ_gem_clean <- readRDS(file = "./occ_data/clean/occ_gem_clean.rds")
occ_hir_clean <- readRDS(file = "./occ_data/clean/occ_hir_clean.rds")
occ_mac_clean <- readRDS(file = "./occ_data/clean/occ_mac_clean.rds")
occ_mem_clean <- readRDS(file = "./occ_data/clean/occ_mem_clean.rds")
occ_mtu_clean <- readRDS(file = "./occ_data/clean/occ_mtu_clean.rds")
occ_myr_clean <- readRDS(file = "./occ_data/clean/occ_myr_clean.rds")
occ_mys_clean <- readRDS(file = "./occ_data/clean/occ_mys_clean.rds")
occ_ova_clean <- readRDS(file = "./occ_data/clean/occ_ova_clean.rds")
occ_ovt_clean <- readRDS(file = "./occ_data/clean/occ_ovt_clean.rds")
occ_oxy_clean <- readRDS(file = "./occ_data/clean/occ_oxy_clean.rds")
occ_pal_clean <- readRDS(file = "./occ_data/clean/occ_pal_clean.rds")
occ_par_clean <- readRDS(file = "./occ_data/clean/occ_par_clean.rds")
occ_sco_clean <- readRDS(file = "./occ_data/clean/occ_sco_clean.rds")
occ_sha_clean <- readRDS(file = "./occ_data/clean/occ_sha_clean.rds")
occ_sta_clean <- readRDS(file = "./occ_data/clean/occ_sta_clean.rds")
occ_ten_clean <- readRDS(file = "./occ_data/clean/occ_ten_clean.rds")
occ_uli_clean <- readRDS(file = "./occ_data/clean/occ_uli_clean.rds")
occ_vid_clean <- readRDS(file = "./occ_data/clean/occ_vid_clean.rds")




# Vectorize occurrence dataframe
occ_ang_vect <- vect(occ_ang_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_arb_vect <- vect(occ_arb_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_bor_vect <- vect(occ_bor_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ces_vect <- vect(occ_ces_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_cor_vect <- vect(occ_cor_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_cra_vect <- vect(occ_cra_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_dar_vect <- vect(occ_dar_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_del_vect <- vect(occ_del_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ery_vect <- vect(occ_ery_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_gem_vect <- vect(occ_gem_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_hir_vect <- vect(occ_hir_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mac_vect <- vect(occ_mac_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mem_vect <- vect(occ_mem_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mtu_vect <- vect(occ_mtu_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_myr_vect <- vect(occ_myr_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mys_vect <- vect(occ_mys_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ova_vect <- vect(occ_ova_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ovt_vect <- vect(occ_ovt_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_oxy_vect <- vect(occ_oxy_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_pal_vect <- vect(occ_pal_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_par_vect <- vect(occ_par_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_sco_vect <- vect(occ_sco_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_sha_vect <- vect(occ_sha_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_sta_vect <- vect(occ_sta_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ten_vect <- vect(occ_ten_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_uli_vect <- vect(occ_uli_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_vid_vect <- vect(occ_vid_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")

# Download WorldClim Bioclimatic raster -----------------------------------
# Use the predictor layer at 2.5 arc/min grid to thin occ
# NOTE MAKE SURE TO ADD WCLIM to .gitignore so not to push big files

wclim <- worldclim_global(var = 'bio', res = 2.5, version = '2.1', path = "./wclim_data/")


# Thin using sampler ------------------------------------------------------
set.seed(1337) # set random generator seed to get reproducible results

# Thinning one occurrence within each grid cell from wclim
occ_ang_thin <- spatSample(occ_ang_vect, size = 1, strata = wclim) 
occ_arb_thin <- spatSample(occ_arb_vect, size = 1, strata = wclim) 
occ_bor_thin <- spatSample(occ_bor_vect, size = 1, strata = wclim) 
occ_ces_thin <- spatSample(occ_ces_vect, size = 1, strata = wclim) 
occ_cor_thin <- spatSample(occ_cor_vect, size = 1, strata = wclim) 
occ_cra_thin <- spatSample(occ_cra_vect, size = 1, strata = wclim) 
occ_dar_thin <- spatSample(occ_dar_vect, size = 1, strata = wclim) 
occ_del_thin <- spatSample(occ_del_vect, size = 1, strata = wclim) 
occ_ery_thin <- spatSample(occ_ery_vect, size = 1, strata = wclim)
occ_gem_thin <- spatSample(occ_gem_vect, size = 1, strata = wclim) 
occ_hir_thin <- spatSample(occ_hir_vect, size = 1, strata = wclim) 
occ_mac_thin <- spatSample(occ_mac_vect, size = 1, strata = wclim) 
occ_mem_thin <- spatSample(occ_mem_vect, size = 1, strata = wclim) 
occ_mtu_thin <- spatSample(occ_mtu_vect, size = 1, strata = wclim) 
occ_myr_thin <- spatSample(occ_myr_vect, size = 1, strata = wclim) 
occ_mys_thin <- spatSample(occ_mys_vect, size = 1, strata = wclim) 
occ_ova_thin <- spatSample(occ_ova_vect, size = 1, strata = wclim) 
occ_ovt_thin <- spatSample(occ_ovt_vect, size = 1, strata = wclim) 
occ_oxy_thin <- spatSample(occ_oxy_vect, size = 1, strata = wclim)
occ_pal_thin <- spatSample(occ_pal_vect, size = 1, strata = wclim) 
occ_par_thin <- spatSample(occ_par_vect, size = 1, strata = wclim) 
occ_sco_thin <- spatSample(occ_sco_vect, size = 1, strata = wclim)
occ_sha_thin <- spatSample(occ_sha_vect, size = 1, strata = wclim)
occ_sta_thin <- spatSample(occ_sta_vect, size = 1, strata = wclim) 
occ_ten_thin <- spatSample(occ_ten_vect, size = 1, strata = wclim) 
occ_uli_thin <- spatSample(occ_uli_vect, size = 1, strata = wclim) 
occ_vid_thin <- spatSample(occ_vid_vect, size = 1, strata = wclim) 


# Save vectorized thinned occurrences -------------------------------------
saveRDS(occ_ang_thin, file = './occ_data/thin/occ_ang_thin.rds')
saveRDS(occ_arb_thin, file = './occ_data/thin/occ_arb_thin.rds')
saveRDS(occ_bor_thin, file = './occ_data/thin/occ_bor_thin.rds')
saveRDS(occ_ces_thin, file = './occ_data/thin/occ_ces_thin.rds')
saveRDS(occ_cor_thin, file = './occ_data/thin/occ_cor_thin.rds')
saveRDS(occ_cra_thin, file = './occ_data/thin/occ_cra_thin.rds')
saveRDS(occ_dar_thin, file = './occ_data/thin/occ_dar_thin.rds')
saveRDS(occ_del_thin, file = './occ_data/thin/occ_del_thin.rds')
saveRDS(occ_ery_thin, file = './occ_data/thin/occ_ery_thin.rds')
saveRDS(occ_hir_thin, file = './occ_data/thin/occ_hir_thin.rds')
saveRDS(occ_mac_thin, file = './occ_data/thin/occ_mac_thin.rds')
saveRDS(occ_mem_thin, file = './occ_data/thin/occ_mem_thin.rds')
saveRDS(occ_mtu_thin, file = './occ_data/thin/occ_mtu_thin.rds')
saveRDS(occ_myr_thin, file = './occ_data/thin/occ_myr_thin.rds')
saveRDS(occ_mys_thin, file = './occ_data/thin/occ_mys_thin.rds')
saveRDS(occ_ova_thin, file = './occ_data/thin/occ_ova_thin.rds')
saveRDS(occ_ovt_thin, file = './occ_data/thin/occ_ovt_thin.rds')
saveRDS(occ_oxy_thin, file = './occ_data/thin/occ_oxy_thin.rds')
saveRDS(occ_pal_thin, file = './occ_data/thin/occ_pal_thin.rds')
saveRDS(occ_par_thin, file = './occ_data/thin/occ_par_thin.rds')
saveRDS(occ_sco_thin, file = './occ_data/thin/occ_sco_thin.rds')
saveRDS(occ_sta_thin, file = './occ_data/thin/occ_sta_thin.rds')
saveRDS(occ_ten_thin, file = './occ_data/thin/occ_ten_thin.rds')
saveRDS(occ_uli_thin, file = './occ_data/thin/occ_uli_thin.rds')
saveRDS(occ_vid_thin, file = './occ_data/thin/occ_vid_thin.rds')
saveRDS(occ_sha_thin, file = './occ_data/thin/occ_sha_thin.rds')



