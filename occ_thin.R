# Top ---------------------------------------------------------------------
# thinning occurrence data of Vaccinium
# Terrell Roulston
# Started Nov 20, 2024

library(tidyverse) # grammar and data management 
library(terra) # working with spatial data
library(geodata) # basemaps and climate data


# Load cleaned occ data ---------------------------------------------------
occ_ang_clean <- readRDS(file = "./occ_data/clean/occ_ang_clean.Rdata") %>% mutate(source = 'gbif')
pankaj_occ_ang <- read.csv(file = './occ_data/pankaj_v_ang_lon_lat.csv', fileEncoding = "UTF-8-BOM") %>% mutate(source = 'pankaj') 
occ_ang_cleanPankaj <- merge(
  occ_ang_clean,
  pankaj_occ_ang,
  by.x = c("decimalLatitude", "decimalLongitude", 'source'),
  by.y = c("lat", "lon", 'source'),
  all = TRUE # Keep all rows (adjust if needed)
)



occ_arb_clean <- readRDS(file = "./occ_data/clean/occ_arb_clean.Rdata")
occ_bor_clean <- readRDS(file = "./occ_data/clean/occ_bor_clean.Rdata")
occ_ces_clean <- readRDS(file = "./occ_data/clean/occ_ces_clean.Rdata")
occ_cor_clean <- readRDS(file = "./occ_data/clean/occ_cor_clean.Rdata")
occ_cra_clean <- readRDS(file = "./occ_data/clean/occ_cra_clean.Rdata")
occ_dar_clean <- readRDS(file = "./occ_data/clean/occ_dar_clean.Rdata")
occ_del_clean <- readRDS(file = "./occ_data/clean/occ_del_clean.Rdata")
occ_ery_clean <- readRDS(file = "./occ_data/clean/occ_ery_clean.Rdata")
occ_hir_clean <- readRDS(file = "./occ_data/clean/occ_hir_clean.Rdata")
occ_mac_clean <- readRDS(file = "./occ_data/clean/occ_mac_clean.Rdata")
occ_mem_clean <- readRDS(file = "./occ_data/clean/occ_mem_clean.Rdata")
occ_mtu_clean <- readRDS(file = "./occ_data/clean/occ_mtu_clean.Rdata")
occ_myr_clean <- readRDS(file = "./occ_data/clean/occ_myr_clean.Rdata")
occ_mys_clean <- readRDS(file = "./occ_data/clean/occ_mys_clean.Rdata")
occ_ova_clean <- readRDS(file = "./occ_data/clean/occ_ova_clean.Rdata")
occ_ovt_clean <- readRDS(file = "./occ_data/clean/occ_ovt_clean.Rdata")
occ_pal_clean <- readRDS(file = "./occ_data/clean/occ_pal_clean.Rdata")
occ_par_clean <- readRDS(file = "./occ_data/clean/occ_par_clean.Rdata")
occ_sco_clean <- readRDS(file = "./occ_data/clean/occ_sco_clean.Rdata")
occ_sta_clean <- readRDS(file = "./occ_data/clean/occ_sta_clean.Rdata")
occ_ten_clean <- readRDS(file = "./occ_data/clean/occ_ten_clean.Rdata")
occ_uli_clean <- readRDS(file = "./occ_data/clean/occ_uli_clean.Rdata")
occ_vid_clean <- readRDS(file = "./occ_data/clean/occ_vid_clean.Rdata")
occ_vir_clean <- readRDS(file = "./occ_data/clean/occ_vir_clean.Rdata")

# Vectorize occurrence dataframe
occ_ang_vect <- vect(occ_ang_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_angPankaj_vect <- vect(occ_ang_cleanPankaj, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84") 
occ_arb_vect <- vect(occ_arb_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_bor_vect <- vect(occ_bor_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ces_vect <- vect(occ_ces_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_cor_vect <- vect(occ_cor_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_cra_vect <- vect(occ_cra_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_dar_vect <- vect(occ_dar_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_del_vect <- vect(occ_del_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ery_vect <- vect(occ_ery_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_hir_vect <- vect(occ_hir_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mac_vect <- vect(occ_mac_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mem_vect <- vect(occ_mem_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mtu_vect <- vect(occ_mtu_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_myr_vect <- vect(occ_myr_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_mys_vect <- vect(occ_mys_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ova_vect <- vect(occ_ova_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ovt_vect <- vect(occ_ang_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_pal_vect <- vect(occ_pal_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_par_vect <- vect(occ_par_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_sco_vect <- vect(occ_sco_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_sta_vect <- vect(occ_sta_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ten_vect <- vect(occ_ten_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_uli_vect <- vect(occ_uli_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_vid_vect <- vect(occ_vid_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_vir_vect <- vect(occ_vir_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")


# Download WorldClim Bioclimatic raster -----------------------------------
# Use the predictor layer at 2.5 arc/min grid to thin occ
# NOTE MAKE SURE TO ADD WCLIM to .gitignore so not to push big files

wclim <- worldclim_global(var = 'bio', res = 2.5, version = '2.1', path = "./wclim_data/")


# Thin using sampler ------------------------------------------------------
set.seed(1337) # set random generator seed to get reproducible results

# V. angustifolium thinning
occ_angThin <- spatSample(occ_ang_vect, size = 1, strata = wclim) #sample one occurrence from each climatic cell
occ_angPankajThin <- spatSample(occ_angPankaj_vect, size = 1, strata = wclim) 
#terra::as.data.frame(occ_angPankajThin) %>% filter(source == 'pankaj') # Peak at which samples were retained from Pankaj's collection
occ_arbThin <- spatSample(occ_arb_vect, size = 1, strata = wclim) 
occ_borThin <- spatSample(occ_bor_vect, size = 1, strata = wclim) 
occ_cesThin <- spatSample(occ_ces_vect, size = 1, strata = wclim) 
occ_corThin <- spatSample(occ_cor_vect, size = 1, strata = wclim) 
occ_craThin <- spatSample(occ_cra_vect, size = 1, strata = wclim) 
occ_darThin <- spatSample(occ_dar_vect, size = 1, strata = wclim) 
occ_delThin <- spatSample(occ_del_vect, size = 1, strata = wclim) 
occ_eryThin <- spatSample(occ_ery_vect, size = 1, strata = wclim) 
occ_hirThin <- spatSample(occ_hir_vect, size = 1, strata = wclim) 
occ_macThin <- spatSample(occ_mac_vect, size = 1, strata = wclim) 
occ_memThin <- spatSample(occ_mem_vect, size = 1, strata = wclim) 
occ_mtuThin <- spatSample(occ_mtu_vect, size = 1, strata = wclim) 
occ_myrThin <- spatSample(occ_myr_vect, size = 1, strata = wclim) 
occ_mysThin <- spatSample(occ_mys_vect, size = 1, strata = wclim) 
occ_ovaThin <- spatSample(occ_ova_vect, size = 1, strata = wclim) 
occ_ovtThin <- spatSample(occ_ovt_vect, size = 1, strata = wclim) 
occ_palThin <- spatSample(occ_pal_vect, size = 1, strata = wclim) 
occ_parThin <- spatSample(occ_par_vect, size = 1, strata = wclim) 
occ_scoThin <- spatSample(occ_sco_vect, size = 1, strata = wclim) 
occ_staThin <- spatSample(occ_sta_vect, size = 1, strata = wclim) 
occ_tenThin <- spatSample(occ_ten_vect, size = 1, strata = wclim) 
occ_uliThin <- spatSample(occ_uli_vect, size = 1, strata = wclim) 
occ_vidThin <- spatSample(occ_vid_vect, size = 1, strata = wclim) 
occ_virThin <- spatSample(occ_vir_vect, size = 1, strata = wclim) 


# Save vectorized thinned occurrences -------------------------------------
saveRDS(occ_angThin, file = './occ_data/thinned/occ_angThin.Rdata')
saveRDS(occ_angPankajThin, file = './occ_data/thinned/occ_angPankajThin.Rdata')
saveRDS(occ_arbThin, file = './occ_data/thinned/occ_arbThin.Rdata')
saveRDS(occ_borThin, file = './occ_data/thinned/occ_borThin.Rdata')
saveRDS(occ_cesThin, file = './occ_data/thinned/occ_cesThin.Rdata')
saveRDS(occ_corThin, file = './occ_data/thinned/occ_corThin.Rdata')
saveRDS(occ_craThin, file = './occ_data/thinned/occ_craThin.Rdata')
saveRDS(occ_darThin, file = './occ_data/thinned/occ_darThin.Rdata')
saveRDS(occ_delThin, file = './occ_data/thinned/occ_delThin.Rdata')
saveRDS(occ_eryThin, file = './occ_data/thinned/occ_eryThin.Rdata')
saveRDS(occ_hirThin, file = './occ_data/thinned/occ_hirThin.Rdata')
saveRDS(occ_macThin, file = './occ_data/thinned/occ_macThin.Rdata')
saveRDS(occ_memThin, file = './occ_data/thinned/occ_memThin.Rdata')
saveRDS(occ_mtuThin, file = './occ_data/thinned/occ_mtuThin.Rdata')
saveRDS(occ_myrThin, file = './occ_data/thinned/occ_myrThin.Rdata')
saveRDS(occ_mysThin, file = './occ_data/thinned/occ_mysThin.Rdata')
saveRDS(occ_ovaThin, file = './occ_data/thinned/occ_ovaThin.Rdata')
saveRDS(occ_ovtThin, file = './occ_data/thinned/occ_ovtThin.Rdata')
saveRDS(occ_palThin, file = './occ_data/thinned/occ_palThin.Rdata')
saveRDS(occ_parThin, file = './occ_data/thinned/occ_parThin.Rdata')
saveRDS(occ_scoThin, file = './occ_data/thinned/occ_scoThin.Rdata')
saveRDS(occ_staThin, file = './occ_data/thinned/occ_staThin.Rdata')
saveRDS(occ_tenThin, file = './occ_data/thinned/occ_tenThin.Rdata')
saveRDS(occ_uliThin, file = './occ_data/thinned/occ_uliThin.Rdata')
saveRDS(occ_vidThin, file = './occ_data/thinned/occ_vidThin.Rdata')
saveRDS(occ_virThin, file = './occ_data/thinned/occ_virThin.Rdata')


