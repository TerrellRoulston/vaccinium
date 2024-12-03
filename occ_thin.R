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
# Vectorize occurrence dataframe
occ_ang_vect <- vect(occ_ang_clean, geom = c('decimalLongitude', 'decimalLatitude'),
                crs = "+proj=longlat +datum=WGS84")
occ_angPankaj_vect <- vect(occ_ang_cleanPankaj, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84") 


# Download WorldClim Bioclimatic raster -----------------------------------
# Use the predictor layer at 2.5 arc/min grid to thin occ
# NOTE MAKE SURE TO ADD WCLIM to .gitignore so not to push big files

wclim <- worldclim_global(var = 'bio', res = 2.5, version = '2.1', path = "./wclim_data/")


# Thin using sampler ------------------------------------------------------
set.seed(1337) # set random generator seed to get reproducible results

# V. angustifolium thinning
occ_angThin <- spatSample(occ_ang_vect, size = 1, 
                      strata = wclim) #sample one occurrence from each climatic cell

occ_angPankajThin <- spatSample(occ_angPankaj_vect, size = 1, 
                                strata = wclim) #sample one occurrence from each climatic cell
# Peak at which samples were retained from Pankaj's collection
terra::as.data.frame(occ_angPankajThin) %>% filter(source == 'pankaj')

# Save vectorized thinned occurrences -------------------------------------
saveRDS(occ_angThin, file = './occ_data/thinned/occ_angThin.Rdata')
saveRDS(occ_angPankajThin, file = './occ_data/thinned/occ_angPankajThin.Rdata')

