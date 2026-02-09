# Top ---------------------------------------------------------------------
# Terrell Roulston
# February 4th, 2026
# Cleaning occurrence data for V. corymbosum complex taxa

# ash – Vaccinium ashei
# cae – Vaccinium caesariense
# cor2 – Vaccinium corymbosum
# cot – Vaccinium constablaei
# ell – Vaccinium elliottii
# for – Vaccinium formosum (syn. Vaccinium australe)
# fus – Vaccinium fuscatum (syn. Vaccinium arkansanum, Vaccinium atrococcum)
# sim – Vaccinium simulatum
# vir – Vaccinium virgatum (syn. Vaccinium amoenum)

# Libraries
library(tidyverse) #grammar, data management
library(CoordinateCleaner) #helpful functions to clean data
library(terra) #working with vector/raster data
library(geodata) #download basemaps


# Import raw GBIF data ----------------------------------------------------

file_names <- c(
  "occ_ash", "occ_cae", "occ_cor2", "occ_cot", "occ_ell",
  "occ_for", "occ_fus", "occ_sim", "occ_vir"
)

# Directory path where the CSV files are stored
file_path <- "C:/Users/terre/Documents/R/vaccinium/occ_data/raw/corym_sub/"

# Read all CSVs and assign each to a variable with its corresponding name
for (name in file_names) {
  assign(name, read.csv(file.path(file_path, paste0(name, ".csv"))))
}


# Load basemaps -----------------------------------------------------------

# Country ISO-2 codes for those that contain species occurrence data for Vaccinium
country_codes <- c("CA","US")
base_path <- "./maps/base_maps/" # path to GADM files

# map to download/load GADM level-1 maps for all countries, returns list of SpatVectors
maps_list <- map(country_codes, ~gadm(country = .x, level = 0, resolution = 2, path = base_path))
# Combine all SpatVectors into one
CA_US_map <- do.call(rbind, maps_list)

# plot(CA_US_map, xlim = c(-180, -50))

# Vaccinium ashei clean ---------------------------------------------------
# All these occurrences look clean!
occ_ash_clean <- occ_ash %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium ashei") %>% 
  rename(gbif_species = species) %>% 
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_ash_clean$decimalLongitude, occ_ash_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
       

saveRDS(occ_ash_clean, file = "./occ_data/clean/corym_sub/occ_ash_clean.rds")

# Vaccinium caesariense clean ---------------------------------------------
# All these occurrences look clean!
occ_cae_clean <- occ_cae %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium caesariense") %>% 
  rename(gbif_species = species) %>% 
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_cae_clean$decimalLongitude, occ_cae_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
       

saveRDS(occ_cae_clean, file = "./occ_data/clean/corym_sub/occ_cae_clean.rds")

# Vaccinium corymbosum clean ----------------------------------------------
occ_cor2_clean <- occ_cor2 %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium corymbosum") %>% 
  rename(gbif_species = species) %>% 
  filter(!(stateProvince  %in% c('New Mexico', 'Nevada', 'Montana'))) %>%  # filter out reccords from strange provinces
  filter(!(decimalLatitude > 52)) %>%
  filter((decimalLongitude > -100)) %>% 
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>%
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) %>% 
  filter(!(gbifID  %in% c('4926151230', '4921982592')))   # 4926151230 IDd incorrectly, is cultivated non-wild

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_cor2_clean$decimalLongitude, occ_cor2_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
       

saveRDS(occ_cor2_clean, file = "./occ_data/clean/corym_sub/occ_cor2_clean.rds")

# Vaccinium constablaei clean ---------------------------------------------
# All these occurrences look clean!
occ_cot_clean <- occ_cot %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium constablaei") %>% 
  rename(gbif_species = species) %>% 
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_cot_clean$decimalLongitude, occ_cot_clean$decimalLatitude, pch = 16,  col = alpha("red", 0.2))
      

saveRDS(occ_cot_clean, file = "./occ_data/clean/corym_sub/occ_cot_clean.rds")

# Vaccinium elliottii clean -----------------------------------------------
occ_ell_clean <- occ_ell %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium elliottii") %>% 
  rename(gbif_species = species) %>% 
  filter((decimalLongitude > -100)) %>% # one weird one from western US
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_ell_clean$decimalLongitude, occ_ell_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
       

saveRDS(occ_ell_clean, file = "./occ_data/clean/corym_sub/occ_ell_clean.rds")

# Vaccinium formosum clean ------------------------------------------------
occ_for_clean <- occ_for %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium formosum") %>% 
  rename(gbif_species = species) %>% 
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_for_clean$decimalLongitude, occ_for_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
       

saveRDS(occ_for_clean, file = "./occ_data/clean/corym_sub/occ_for_clean.rds")

# Vaccinium fuscatum clean ------------------------------------------------
occ_fus_clean <- occ_fus %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium fuscatum") %>% 
  rename(gbif_species = species) %>%
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_fus_clean$decimalLongitude, occ_fus_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
       

saveRDS(occ_fus_clean, file = "./occ_data/clean/corym_sub/occ_fus_clean.rds")

# Vaccinium simulatum clean -----------------------------------------------
occ_sim_clean <- occ_sim %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium simulatum") %>% 
  rename(gbif_species = species) %>%
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  filter(!(gbifID %in% c(1931267375, 5103873353, 1302605284, 41857499))) %>% # 1931267375 annotaed as atrococum, 5103873353 annotated as corymbosum, 1302605284 and 41857499 is suspicious
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_sim_clean$decimalLongitude, occ_sim_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
     

saveRDS(occ_sim_clean, file = "./occ_data/clean/corym_sub/occ_sim_clean.rds")

# Vaccinium virgatum clean ------------------------------------------------
occ_vir_clean <- occ_vir %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  mutate(taxon = "Vaccinium virgatum") %>% 
  rename(gbif_species = species) %>%
  filter(!decimalLatitude > 38) %>% # remove weird north records
  dplyr::select(taxon, gbif_species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot occurrences
# plot(CA_US_map, xlim = c(-180, -50))
# points(occ_vir_clean$decimalLongitude, occ_vir_clean$decimalLatitude, pch = 16, col = alpha("red", 0.2))
       

saveRDS(occ_vir_clean, file = "./occ_data/clean/corym_sub/occ_vir_clean.rds")


