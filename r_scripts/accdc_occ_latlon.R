
# Top ---------------------------------------------------------------------
# Started Jan 2 2025
# Extract coords from ACCDC 
# This script will work for extracting coordinates from any shape file .sh
library(tidyverse) # grammar and data management 
library(terra) # working with spatial data
library(geodata) # basemaps and climate data


accdc_ld_occ <- vect("C:/Users/terre/Documents/Acadia/Vaccinium/ZoeMigicovsky__VaccPlantSpecies_Export_5Jun2024_Modified_29Dec2024/LB_PLANTS_WD_ACCDCNL_Export_Vacc3Jun2024.shp")
accdc_nf_occ <- vect("C:/Users/terre/Documents/Acadia/Vaccinium/ZoeMigicovsky__VaccPlantSpecies_Export_5Jun2024_Modified_29Dec2024/NF_PLANTS_WD_ACCDCNL_Export_Vacc3Jun2024.shp")

# The base projection is NAD83
# which uses projected coordinates in METERs of Northing/Easting instead of decimal degrees like is expected downstream
# Convert to WGS84 to get decimal lat/lon
print(crs(accdc_ld_occ)) # access base proj

accdc_ld_occ <- project(accdc_ld_occ, "EPSG:4326") # overwrite object with new crs
accdc_nf_occ <- project(accdc_nf_occ, "EPSG:4326")

# return the unique species (stored as variable'GNAME')
unique(accdc_ld_occ$GNAME) 
unique(accdc_nf_occ$GNAME) 


# extract coordinates and attributes from each location
accdc_ld_df <- as.data.frame(accdc_ld_occ) %>% mutate(prov = 'LD')
accdc_nf_df <- as.data.frame(accdc_nf_occ) %>% mutate(prov = 'NF')


accdc_ld_nf_combined <- full_join(accdc_ld_df, accdc_nf_df) # combine the Newfoundland and Labrador dataset together
accdc_ld_nf_combined <- accdc_ld_nf_combined %>% rename(species == GNAME, day = Day, month = Month, year = Year, lat = Lat, lon = Long)
rename()
# Now we are also going to bring in the data from the other Maritime provinces (NS, NB, PE)
accdc_ns_ns_pe <- read.csv(file = "C:/Users/terre/Documents/Acadia/Vaccinium/ACCDC_VacciniumMaritimes_June2024.csv")


# create separate df for each species
# select only the relevant attributes for downstream
# Remove inat observations

#Vaccinium angustifolium
accdc_ang <- accdc_ld_nf_combined %>% filter(GNAME == 'Vaccinium angustifolium') %>% 
  filter(!str_detect(OBSERVERS, 'iNaturalist')) %>%  # Exclude rows containing 'iNaturalist' observations
  select(species, day, month, Year, Lat, Long, prov) %>% 
  mutate(source = 'ACCDC')

write.csv(accdc_ang, file = './occ_data/accdc_data/accdc_ang.csv')

#Vaccinium boreale
accdc_bor <- accdc_df_combined %>% filter(GNAME == 'Vaccinium boreale') %>% 
  filter(!str_detect(OBSERVERS, 'iNaturalist')) %>%  # Exclude rows containing 'iNaturalist' observations
  select(GNAME, Day, Month, Year, Lat, Long, prov) %>% 
  mutate(source = 'ACCDC')

write.csv(accdc_bor, file = './occ_data/accdc_data/accdc_bor.csv')

#Vaccinium boreale
accdc_bor <- accdc_df_combined %>% filter(GNAME == 'Vaccinium boreale') %>% 
  filter(!str_detect(OBSERVERS, 'iNaturalist')) %>%  # Exclude rows containing 'iNaturalist' observations
  select(GNAME, Day, Month, Year, Lat, Long, prov) %>% 
  mutate(source = 'ACCDC')

write.csv(accdc_bor, file = './occ_data/accdc_data/accdc_bor.csv')



