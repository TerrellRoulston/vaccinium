# Top ---------------------------------------------------------------------
# cleaninbg=g occurrence data of Vaccinium
# Terrell Roulston
# Started Nov 6, 2024

library(tidyverse) #grammar, data management
library(CoordinateCleaner) #helpful functions to clean data
library(terra) #working with vector/raster data
library(geodata) #download basemaps

# Import occurrence dataframes --------------------------------------------

file_names <- c(
  "occ_ang", "occ_arb", "occ_bor", "occ_ces", "occ_cor", 
  "occ_cra", "occ_dar", "occ_del", "occ_ery", "occ_hir", 
  "occ_mac", "occ_mem", "occ_mtu", "occ_myr", "occ_mys", 
  "occ_ova", "occ_ovt", "occ_oxy", "occ_pal", "occ_par", 
  "occ_sco", "occ_sta", "occ_ten", "occ_uli", "occ_vid", 
  "occ_leu", "occ_con", "occ_ste", "occ_sha", "occ_gem",
  "occ_crd", "occ_cos", "occ_sel", "occ_kun"
)

# Directory path where the CSV files are stored
file_path <- "C:/Users/terre/Documents/R/vaccinium/occ_data/raw/"

# Read all CSVs and assign each to a variable with its corresponding name
for (name in file_names) {
  assign(name, read.csv(file.path(file_path, paste0(name, ".csv"))))
}

# All species occurrence objects
# occ_ang 
# occ_arb 
# occ_bor
# occ_ces
# occ_cor
# occ_cra
# occ_dar
# occ_del
# occ_ery
# occ_hir
# occ_mac
# occ_mem
# occ_mtu
# occ_myr
# occ_mys
# occ_ova
# occ_ovt
# occ_oxy
# occ_pal
# occ_par
# occ_sco
# occ_sta
# occ_ten
# occ_uli
# occ_vid
# occ_vir
# occ_leu
# occ_con
# occ_ste
# occ_sha
# occ_gem
# occ_crd
# occ_cos
# occ_sel
# occ_kun


# Country ISO-2 codes for those that contain species occurrence data for Vaccinium
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA")
base_path <- "./maps/base_maps/" # path to GADM files

# map to download/load GADM level-1 maps for all countries, returns list of SpatVectors
maps_list <- map(country_codes, ~gadm(country = .x, level = 0, resolution = 2, path = base_path))
# Combine all SpatVectors into one
all_countries_map <- do.call(rbind, maps_list)

#plot(all_countries_map, xlim = c(-180, -50))
# Cleaning Vaccinium occurrence data from GBIF
# V. angustifolium cleaning -----------------------------------------------
#View(occ_ang)

# Note there is a record from Lousianan that seems suspicous but it was IDed origionally by a botanist, so likely rare occurrence
occ_ang_clean <- occ_ang %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  dplyr::select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) %>% 
  filter(!(decimalLongitude < -110)) # remove some records from west coast

#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_ang_clean$decimalLongitude, occ_ang_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_ang_clean, file = "./occ_data/clean/occ_ang_clean.Rdata")


# V. arboreum cleaning ----------------------------------------------------
#View(occ_arb)

# Note there is a record from Lousianan that seems suspicous but it was IDed origionally by a botanist, so likely rare occurrence
occ_arb_clean <- occ_arb %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!(stateProvince  %in% c('New York'))) %>%  # filter out reccords from NY
  filter(!(decimalLatitude > 40)) %>% # One occ from northern Illinois 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_arb_clean$decimalLongitude, occ_arb_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_arb_clean, file = "./occ_data/clean/occ_arb_clean.Rdata")


# V. boreale cleaning -----------------------------------------------------
# Note there is a record from Lousianan that seems suspicous but it was IDed origionally by a botanist, so likely rare occurrence
occ_bor_clean <- occ_bor %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_bor_clean$decimalLongitude, occ_bor_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_bor_clean, file = "./occ_data/clean/occ_bor_clean.Rdata")


# V. cespitosum cleaning --------------------------------------------------
#View(occ_ces)

# Note there is a record from Lousianan that seems suspicous but it was IDed origionally by a botanist, so likely rare occurrence
occ_ces_clean <- occ_ces %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_ces_clean$decimalLongitude, occ_ces_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_ces_clean, file = "./occ_data/clean/occ_ces_clean.Rdata")


# V. corymbosum cleaning --------------------------------------------------
#View(occ_cor)

# Note I chose to include records from the west coast even though it is introduced there.
occ_cor_clean <- occ_cor %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!(stateProvince  %in% c('New Mexico', 'Nevada', 'Montana'))) %>%  # filter out reccords from strange provinces
  filter(!(decimalLatitude > 52)) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) %>% 
  filter(!(gbifID  %in% c('4926151230', '4921982592')))   # 4926151230 IDd incorrectly, is cultivated non-wild
  
# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_cor_clean$decimalLongitude, occ_cor_clean$decimalLatitude, pch = 16,
     col = alpha("red", 0.2))

saveRDS(occ_cor_clean, file = "./occ_data/clean/occ_cor_clean.Rdata")


# V. crassifolium cleaning ------------------------------------------------
#View(occ_cra)

# Note there is a record from Lousianan that seems suspicous but it was IDed origionally by a botanist, so likely rare occurrence
occ_cra_clean <- occ_cra %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) %>% 
  filter(!(decimalLatitude > 43)) %>% 
  filter(!(decimalLatitude < 30.5))

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_cra_clean$decimalLongitude, occ_cra_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_cra_clean, file = "./occ_data/clean/occ_cra_clean.Rdata")


# V. darrowii cleaning ----------------------------------------------------
#View(occ_dar)

occ_dar_clean <- occ_dar %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!(decimalLatitude > 35)) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_dar_clean$decimalLongitude, occ_dar_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_dar_clean, file = "./occ_data/clean/occ_dar_clean.Rdata")


# V. deliciosum cleaning --------------------------------------------------
#View(occ_del)

occ_del_clean <- occ_del %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!(decimalLatitude > 59)) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_del_clean$decimalLongitude, occ_del_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_del_clean, file = "./occ_data/clean/occ_del_clean.Rdata")


# V. erythrocarpum cleaning -----------------------------------------------
#View(occ_ery)

occ_ery_clean <- occ_ery %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!(decimalLongitude == -77.65)) %>% # remove bad iNat observation
  filter(!(decimalLatitude == 51.5)) %>% # remove record from BC??
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_ery_clean$decimalLongitude, occ_ery_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_ery_clean, file = "./occ_data/clean/occ_ery_clean.Rdata")


# V. hirsutum cleaning ----------------------------------------------------
#View(occ_hir)

occ_hir_clean <- occ_hir %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLatitude < 33) %>% # remove records outside of thier range
  filter(!decimalLongitude < -88) %>% # remove another erogenous record
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_hir_clean$decimalLongitude, occ_hir_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_hir_clean, file = "./occ_data/clean/occ_hir_clean.Rdata")


# V. macrocarpon cleaning -------------------------------------------------
# Because of its wide natural and introduced range its hard to tell which records are bad
#View(occ_mac)

occ_mac_clean <- occ_mac %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!catalogNumber == "G-DC-275895/11") %>% # remove records outside of thier range
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_mac_clean$decimalLongitude, occ_mac_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_mac_clean, file = "./occ_data/clean/occ_mac_clean.Rdata")


# V. membranaceum cleaning ------------------------------------------------
#View(occ_mem)

occ_mem_clean <- occ_mem %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!catalogNumber %in% c("675854", "CAN 10075102", "CONN00112509", "CONN00112510", "2936249", "2936247", "12442HIM", "o-1008204600")) %>% # remove record with doubtful ID outside range
  filter(!occurrenceID == "o-1008204600") %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_mem_clean$decimalLongitude, occ_mem_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_mem_clean, file = "./occ_data/clean/occ_mem_clean.Rdata")


# V. myrtillus cleaning ---------------------------------------------------
#View(occ_mtu)

occ_mtu_clean <- occ_mtu %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLatitude > 58) %>% # remove records from far north
  filter(!decimalLongitude > -100) %>% 
  filter(!occurrenceID %in% c("q-10393939745", "q-10611475661")) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T)

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_mtu_clean$decimalLongitude, occ_mtu_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_mtu_clean, file = "./occ_data/clean/occ_mtu_clean.Rdata")


# V. myrtilloides cleaning ------------------------------------------------
#View(occ_myr)

# Note I chose to include records from the west coast even though it is introduced there.
occ_myr_clean <- occ_myr %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!(stateProvince  %in% c('Colorado', 'Kansas', 'Wyoming', 'Florida', 'Idaho'))) %>%  # filter out reccords from strange provinces
  filter(decimalLatitude > 33) %>%
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_myr_clean$decimalLongitude, occ_myr_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_myr_clean, file = "./occ_data/clean/occ_myr_clean.Rdata")


# V. myrsinites cleaning --------------------------------------------------
#View(occ_mys)

occ_mys_clean <- occ_mys %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLongitude < -100) %>% 
  filter(!catalogNumber %in% c("2546967", "G-DC-275304/1", "G-DC-275268/1")) %>% # remove records with bad coordinates, one that was collected in Jacksonville FA
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_mys_clean$decimalLongitude, occ_mys_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_mys_clean, file = "./occ_data/clean/occ_mys_clean.Rdata")


# V. ovalifolium cleaning -------------------------------------------------
#View(occ_ova)

occ_ova_clean <- occ_ova %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_ova_clean$decimalLongitude, occ_ova_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_ova_clean, file = "./occ_data/clean/occ_ova_clean.Rdata")


# V. ovatum cleaning ------------------------------------------------------
#View(occ_ovt)

occ_ovt_clean <- occ_ovt %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLongitude > -114) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_ovt_clean$decimalLongitude, occ_ovt_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_ovt_clean, file = "./occ_data/clean/occ_ovt_clean.Rdata")


# V. oxycoccos cleaning ---------------------------------------------------
#View(occ_oxy)

occ_oxy_clean <- occ_oxy %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_oxy_clean$decimalLongitude, occ_oxy_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_oxy_clean, file = "./occ_data/clean/occ_oxy_clean.Rdata")



# V. pallidum cleaning ----------------------------------------------------
#View(occ_pal)

occ_pal_clean <- occ_pal %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_pal_clean$decimalLongitude, occ_pal_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_pal_clean, file = "./occ_data/clean/occ_pal_clean.Rdata")


# V. parvifolium cleaning -------------------------------------------------
#View(occ_par)

occ_par_clean <- occ_par %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLongitude > -114) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_par_clean$decimalLongitude, occ_par_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_par_clean, file = "./occ_data/clean/occ_par_clean.Rdata")


# V. scoparium cleaning ---------------------------------------------------
#View(occ_sco)

occ_sco_clean <- occ_sco %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLongitude > -100) %>% 
  filter(!catalogNumber %in% c("2932852", "NLU0141635")) %>% # remove records with bad coordinates, or miss IDd
  filter(!occurrenceID == "3ebaa35a-9cf5-4d07-8bce-59eeff773b87") %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_sco_clean$decimalLongitude, occ_sco_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_sco_clean, file = "./occ_data/clean/occ_sco_clean.Rdata")


# V. stamineum cleaning ---------------------------------------------------
#View(occ_sta)

occ_sta_clean <- occ_sta %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLongitude < -105) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_sta_clean$decimalLongitude, occ_sta_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_sta_clean, file = "./occ_data/clean/occ_sta_clean.Rdata")


# V. tenellum cleaning ----------------------------------------------------
#View(occ_ten)

occ_ten_clean <- occ_ten %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!catalogNumber %in% c("275974", "YU.070296", "G-DC-275387/1", "	G-DC-275389/2")) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_ten_clean$decimalLongitude, occ_ten_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_ten_clean, file = "./occ_data/clean/occ_ten_clean.Rdata")


# V. uliginosum cleaning --------------------------------------------------
#View(occ_uli)

occ_uli_clean <- occ_uli %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!catalogNumber %in% c("2551132", "0042914MOR", "64336", "MNHNL149226")) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_uli_clean$decimalLongitude, occ_uli_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_uli_clean, file = "./occ_data/clean/occ_uli_clean.Rdata")


# V. vitis-idaea cleaning -------------------------------------------------
#View(occ_vid)

occ_vid_clean <- occ_vid %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea()%>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_vid_clean$decimalLongitude, occ_vid_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_vid_clean, file = "./occ_data/clean/occ_vid_clean.Rdata")


# V. virgatum cleaning ----------------------------------------------------
#View(occ_vir)

occ_vir_clean <- occ_vir %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  filter(!decimalLatitude > 38) %>% 
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_vir_clean$decimalLongitude, occ_vir_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_vir_clean, file = "./occ_data/clean/occ_vir_clean.Rdata")

# V. leucanthum cleaning --------------------------------------------------
occ_leu_clean <- occ_leu %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50), ylim = c(10, 25))

# Plot occurrences
points(occ_leu_clean$decimalLongitude, occ_leu_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_leu_clean, file = "./occ_data/clean/occ_leu_clean.Rdata")

# V. confertum cleaning ---------------------------------------------------
occ_con_clean <- occ_con %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(!decimalLatitude < 10) %>% # drop record in Panama
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_con_clean$decimalLongitude, occ_con_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_con_clean, file = "./occ_data/clean/occ_con_clean.Rdata")

# V. stenophyllum cleaning ------------------------------------------------
occ_ste_clean <- occ_ste %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(!decimalLatitude > 30) %>% # drop records north of mexico (northeast US and Quebec?)
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_ste_clean$decimalLongitude, occ_ste_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_ste_clean, file = "./occ_data/clean/occ_ste_clean.Rdata")

# V. shastense cleaning --------------------------------------------------
occ_sha_clean <- occ_sha %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_sha_clean$decimalLongitude, occ_sha_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_sha_clean, file = "./occ_data/clean/occ_sha_clean.Rdata")

# V. geminiflorum cleaning ------------------------------------------------
occ_gem_clean <- occ_gem %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_gem_clean$decimalLongitude, occ_gem_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_gem_clean, file = "./occ_data/clean/occ_gem_clean.Rdata")

# V. cordifolium cleaning -------------------------------------------------
occ_crd_clean <- occ_crd %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50), ylim = c(10, 25))

# Plot occurrences
points(occ_crd_clean$decimalLongitude, occ_crd_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_crd_clean, file = "./occ_data/clean/occ_crd_clean.Rdata")

# V. consanguineum cleaning -----------------------------------------------
occ_cos_clean <- occ_cos %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(!decimalLatitude > 18) %>% # drop records north of mexico (northeast US and Quebec?)
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50), ylim = c(30, 0))

# Plot occurrences
points(occ_cos_clean$decimalLongitude, occ_cos_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_cos_clean, file = "./occ_data/clean/occ_cos_clean.Rdata")

# V. selerianum cleaning --------------------------------------------------
occ_sel_clean <- occ_sel %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(!decimalLatitude > 20) %>% # drop disjunct records in central mexico
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50), ylim = c(10, 25))

# Plot occurrences
points(occ_sel_clean$decimalLongitude, occ_sel_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_sel_clean, file = "./occ_data/clean/occ_sel_clean.Rdata")

# V. kunthianum cleaning --------------------------------------------------
occ_kun_clean <- occ_kun %>% 
  filter(hasGeospatialIssues == FALSE) %>% # remove records with geospatial issues
  select(species, countryCode, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, year, basisOfRecord, gbifID) %>% #grab necessary columns 
  filter(!is.na(decimalLongitude)) %>% # should have coords but you never know
  filter(decimalLongitude != 0) %>% 
  filter(coordinateUncertaintyInMeters < 30000 | is.na(coordinateUncertaintyInMeters)) %>%
  cc_cen(buffer = 2000) %>%
  cc_inst(buffer = 200) %>%
  cc_sea() %>% 
  distinct(decimalLatitude, decimalLongitude, gbifID, .keep_all = T) 

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(occ_kun_clean$decimalLongitude, occ_kun_clean$decimalLatitude, pch = 16,
       col = alpha("red", 0.2))

saveRDS(occ_kun_clean, file = "./occ_data/clean/occ_kun_clean.Rdata")

# Plot all species together -----------------------------------------------
# Append "_clean" to each name
file_names_clean <- list(
  occ_ang_clean, occ_arb_clean, occ_bor_clean, occ_ces_clean, occ_cor_clean, 
  occ_cra_clean, occ_dar_clean, occ_del_clean, occ_ery_clean, occ_hir_clean, 
  occ_mac_clean, occ_mem_clean, occ_mtu_clean, occ_myr_clean, occ_mys_clean, 
  occ_ova_clean, occ_ovt_clean, occ_pal_clean, occ_par_clean, occ_sco_clean, 
  occ_sta_clean, occ_ten_clean, occ_uli_clean, occ_vid_clean, occ_vir_clean
)

file_names_clean <- lapply(file_names_clean, function(df) {
  colnames(df) <- c("species", "countryCode", "decimalLatitude", 
                    "decimalLongitude", "coordinateUncertaintyInMeters", 
                    "year", "basisOfRecord", "gbifID")
  return(df)
})

# Combine all into a single data frame
result <- do.call(rbind, file_names_clean)

# #View the combined result
#result

# Plot basemap  
#plot(all_countries_map, xlim = c(-180, -50))

# Plot occurrences
points(result$decimalLongitude, result$decimalLatitude, pch = 16,
       col = alpha("red", 0.1))
