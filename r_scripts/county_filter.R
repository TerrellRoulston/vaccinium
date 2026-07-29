# Script for filtering occurrences at by counties
# There is county level data available for the below ressurected species
# And for V. hirsutum

library(tidyverse)
library(terra)
library(tidyterra)
library(tigris) # us county data
options(tigris_use_cache = TRUE) # download county data
library(readxl)
library(purrr)
library(stringr)

# Species abbreviations
# RESERCETED sensu V. corymbosum Vander Kloet
# ash – Vaccinium ashei
# cor – Vaccinium corymbosum (syn. Vaccinium austral, Vaccinium formosum)
# cot – Vaccinium constablaei
# ell – Vaccinium elliottii
# fus – Vaccinium fuscatum (syn. Vaccinium arkansanum, Vaccinium atrococcum, Vaccinium caesariense)
# sim – Vaccinium simulatum
# vir – Vaccinium virgatum (syn. Vaccinium amoenum)
# REMAINING SECT CYANOCOCCUS
# hir – Vaccinium hirsutum


lu_counties <- tigris::list_counties(state = c("LOUISIANA"))
lu_counties_shp <- tigris::counties(state = c("LOUISIANA"))
subset_lu <- c("Lincoln Parish" , "Washington Parish")

lu_counties_shp_subset <-  lu_counties_shp %>% dplyr::filter(NAMELSAD %in% subset_lu)                                  

vi_counties <- tigris::list_counties(state = c("VIRGINIA"))


# Load in cleaned occurrence data -----------------------------------------
# Need to combine a few synonomous species that were seperated upstream during GBIF download
# Comnbine V. corymbossum and V. formosum
# Combine V. fuscatum and V. caesariense

occ_ash_clean <- readRDS("occ_data/clean/corym_sub/occ_ash_clean.rds")
occ_cor_clean <- readRDS("occ_data/clean/corym_sub/occ_cor2_clean.rds") # combine
occ_for_clean <- readRDS("occ_data/clean/corym_sub/occ_for_clean.rds") # combine
occ_cot_clean <- readRDS("occ_data/clean/corym_sub/occ_cot_clean.rds")
occ_ell_clean <- readRDS("occ_data/clean/corym_sub/occ_ell_clean.rds")
occ_fus_clean <- readRDS("occ_data/clean/corym_sub/occ_fus_clean.rds") # combine
occ_cae_clean <- readRDS("occ_data/clean/corym_sub/occ_cae_clean.rds") # combine
occ_sim_clean <- readRDS("occ_data/clean/corym_sub/occ_sim_clean.rds")
occ_vir_clean <- readRDS("occ_data/clean/corym_sub/occ_vir_clean.rds")
occ_hir_clean <- readRDS("occ_data/clean/occ_hir_clean.rds")

# combine the syn spp
occ_cor_for_clean <- rbind(occ_cor_clean, occ_for_clean)
occ_fus_cae_clean <- rbind(occ_fus_clean, occ_cae_clean)

# Vectorize occ data ------------------------------------------------------
# Vectorize occurrence dataframe
occ_ash_vect <- vect(occ_ash_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_cor_vect <- vect(occ_cor_for_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_fus_vect <- vect(occ_fus_cae_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_cot_vect <- vect(occ_cot_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_ell_vect <- vect(occ_ell_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_sim_vect <- vect(occ_sim_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_vir_vect <- vect(occ_vir_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
occ_hir_vect <- vect(occ_hir_clean, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")



# Load in excel sheet with county data ------------------------------------
cyan_counties <- read_xlsx("/occ_data/sect_cyan_final/corymbosum_complex_counties.xlsx") %>% select(!c(7, 8, 9)) # deselect the random columns...


ash_counties <- cyan_counties %>% filter(species == "Vaccinium ashei")
cor_counties <- cyan_counties %>% filter(species == "Vaccinium corymbosum")
cot_counties <- cyan_counties %>% filter(species == "Vaccinium constablei")
ell_counties <- cyan_counties %>% filter(species == "Vaccinium elliottii")
fus_counties <- cyan_counties %>% filter(species == "Vaccinium fuscatum")
sim_counties <- cyan_counties %>% filter(species == "Vaccinium simulatum")
vir_counties <- cyan_counties %>% filter(species == "Vaccinium virgatum")
hir_counties <- cyan_counties %>% filter(species == "Vaccinium hirsutum")

# split V corymbosum list into Canada and US subset
cor_counties_ca <- cor_counties %>% filter(country == "CANADA")
cor_counties_us <- cor_counties %>% filter(country == "USA")

# Load US county data from tigris -----------------------------------------
# Get vector of US states needed
us_states <- cyan_counties %>%
  filter(country == "USA") %>%
  distinct(state_province)

# Match state names to FIPS codes
us_states_fips <- us_states %>%
  mutate(state_province = str_to_upper(str_squish(state_province))) %>%
  left_join(
    fips_codes %>%
      distinct(state_name, state_code) %>%
      mutate(state_name = str_to_upper(str_squish(state_name))),
    by = c("state_province" = "state_name")
  )

# Retrieve county names and codes for each state
us_counties <- map_dfr(
  us_states_fips$state_code,
  tigris::list_counties,
  .id = "state_row"
) %>%
  mutate(state_row = as.integer(state_row)) %>%
  left_join(
    us_states_fips %>%
      mutate(state_row = row_number()) %>%
      select(state_row, state_province, state_code),
    by = "state_row"
  ) %>%
  select(
    state_province,
    state_code,
    county,
    county_code
  )

# Get US counties from the Corymbosum dataset
cyan_counties_us <- cyan_counties %>%
  filter(country == "USA") %>%
  mutate(
    state_province = str_to_upper(str_squish(state_province))
  )

# Appear to be errors in the  Franck and Salman, 2025. Castanea publication itself:
#   - Putnam Co. is listed under Arkansas, but Arkansas has no Putnam County.
#     The cited locality ("between Eatonton and Milledgeville") is in
#     Putnam County, Georgia, so the state was changed to GEORGIA.
#   - Forest Co., Mississippi -> Forrest Co. (official county name).
#   - Hartford Co., North Carolina -> Hertford Co. (official county name).

cyan_counties_us <- cyan_counties_us %>%
  mutate(
    state_province = case_when(
      state_province == "ARKANSAS" & county == "Putnam" ~ "GEORGIA",
      TRUE ~ state_province
    ),
    county = case_when(
      state_province == "MISSISSIPPI" & county == "Forest" ~ "Forrest",
      state_province == "NORTH CAROLINA" & county == "Hartford" ~ "Hertford",
      TRUE ~ county
    )
  )

# Quick function for normalizing dataset names
normalize_county <- function(x) {
  x %>%
    str_replace_all("[‘’]", "'") %>%
    str_to_lower() %>%
    str_squish() %>%
    str_replace("\\s+(county|parish|city)$", "") %>%
    str_replace_all("[^a-z0-9]", "")
}

cyan_counties_us <- cyan_counties_us %>%
  mutate(
    state_match = str_to_upper(str_squish(state_province)),
    county_match = normalize_county(county)
  )

us_counties <- us_counties %>%
  mutate(
    state_match = str_to_upper(str_squish(state_province)),
    county_match = normalize_county(county)
  )

# check for any unmattched counties leftover
unmatched_counties <- cyan_counties_us %>%
  anti_join(
    us_counties,
    by = c("state_match", "county_match")
  ) %>%
  distinct(state_province, county)

unmatched_counties # no unmatched counties

# Download US county shape files ------------------------------------------
# Download county boundary polygons for all required states
us_counties_vect <- map(
  us_states_fips$state_code,
  \(state_fips) {
    tigris::counties(
      state = state_fips,
      cb = TRUE,
      year = 2024,
      class = "sf"
    ) |>
      terra::vect()
  }
)

# Combine state-level SpatVectors into one object
us_counties_vect <- do.call(rbind, us_counties_vect)

# Create standardized state and county names for matching
us_counties_vect$state_match <- str_to_upper(
  str_squish(us_counties_vect$STATE_NAME)
)

us_counties_vect$county_match <- normalize_county(
  us_counties_vect$NAME
)

# Create unique matching keys
us_counties_vect$match_key <- paste(
  us_counties_vect$state_match,
  us_counties_vect$county_match,
  sep = "__"
)

county_keys <- cyan_counties_us %>%
  distinct(state_match, county_match) %>%
  mutate(
    match_key = paste(state_match, county_match, sep = "__")
  )

# Retain only counties included in the Corymbosum dataset
cyan_counties_us_vect <- us_counties_vect[
  us_counties_vect$match_key %in% county_keys$match_key,
]

plot(cyan_counties_us_vect) # US Counties loooooook good!!

# Access Canada County data -----------------------------------------------
# NOTE: DOWNLOAD CANADA 2021 CENSUS BOUNDARY SHAPE FILES HERE: 
# https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21

# Peak at what Canadian "counties" there are
cor_counties_ca 

# Load Canadian counties
canada_counties_vect <- vect("maps/ca_census_shp/")
# They use a bunch of crazy numbers for provinces (nice...)

# Statistics Canada province and territory codes
province_lookup <- tibble(
  PRUID = c(
    "10", "11", "12", "13", "24", "35", "46",
    "47", "48", "59", "60", "61", "62"
  ),
  state_province = c(
    "NEWFOUNDLAND AND LABRADOR",
    "PRINCE EDWARD ISLAND",
    "NOVA SCOTIA",
    "NEW BRUNSWICK",
    "QUEBEC",
    "ONTARIO",
    "MANITOBA",
    "SASKATCHEWAN",
    "ALBERTA",
    "BRITISH COLUMBIA",
    "YUKON",
    "NORTHWEST TERRITORIES",
    "NUNAVUT"
  )
)

# update atribute table
canada_county_attributes <- as.data.frame(
  canada_counties_vect
) %>%
  left_join(
    province_lookup,
    by = "PRUID"
  )

# assign value
values(canada_counties_vect) <- canada_county_attributes

# Function for normalizing names
# Standardize administrative-unit names for matching
normalize_admin_name <- function(x) {
  x %>%
    stringi::stri_trans_general("Latin-ASCII") %>%
    stringr::str_to_lower() %>%
    stringr::str_squish() %>%
    stringr::str_replace_all("[^a-z0-9]", "")
}

# Correct Canadian county names to match official Census Division names
cor_counties_ca <- cor_counties_ca %>%
  mutate(
    county = case_when(
      state_province == "ONTARIO" & county == "Russell" ~
        "Prescott and Russell",
      
      state_province == "ONTARIO" & county == "Norfolk" ~
        "Haldimand-Norfolk",
      
      state_province == "QUEBEC" & county == "LeHaut-Richelieu" ~
        "Le Haut-Richelieu",
      
      state_province == "QUEBEC" & county == "LeHaut-Saint-Laurent" ~
        "Le Haut-Saint-Laurent",
      
      state_province == "QUEBEC" & county == "Lotbiniere" ~
        "Lotbinière",
      
      state_province == "QUEBEC" & county == "Quebéc" ~
        "Québec",
      
      TRUE ~ county
    )
  )

# Recreate matching fields
cor_counties_ca <- cor_counties_ca %>%
  mutate(
    province_match = normalize_admin_name(state_province),
    county_match = normalize_admin_name(county)
  )

# Matching key for all Canadian Census Division polygons
canada_counties_vect$match_key <- paste(
  canada_counties_vect$province_match,
  canada_counties_vect$county_match,
  sep = "__"
)

# Matching keys for Census Divisions containing Vaccinium corymbosum
cor_county_keys_ca <- cor_counties_ca %>%
  distinct(
    province_match,
    county_match
  ) %>%
  mutate(
    match_key = paste(
      province_match,
      county_match,
      sep = "__"
    )
  )

# check matches
canada_county_attributes <- as.data.frame(
  canada_counties_vect
)

unmatched_ca <- cor_county_keys_ca %>%
  anti_join(
    canada_county_attributes %>%
      distinct(match_key),
    by = "match_key"
  )

unmatched_ca # checked unmatched...

# Retain only Census Divisions containing Vaccinium corymbosum
cor_counties_ca_vect <- canada_counties_vect[
  canada_counties_vect$match_key %in%
    cor_county_keys_ca$match_key,
]

plot(cor_counties_ca_vect) # plot v. corymbosum counties!

# Project both US and Canada Counties to WGS84 ----------------------------
# Project U.S. and Canadian administrative boundaries to WGS84
cyan_counties_us_vect <- terra::project(
  cyan_counties_us_vect,
  "EPSG:4326"
)

cor_counties_ca_vect <- terra::project(
  cor_counties_ca_vect,
  "EPSG:4326"
)

# Subset counties by species ----------------------------------------------
# Create a standardized state/province-county key in both boundary layers
cyan_counties_us_vect$match_key <- paste(
  cyan_counties_us_vect$state_match,
  cyan_counties_us_vect$county_match,
  sep = "__"
)

cor_counties_ca_vect$match_key <- paste(
  cor_counties_ca_vect$province_match,
  cor_counties_ca_vect$county_match,
  sep = "__"
)

# Subset administrative-unit polygons for a single species
subset_admin_by_species <- function(
    admin_vect,
    county_data,
    species_name
) {
  
  species_keys <- county_data %>%
    filter(species == species_name) %>%
    distinct(state_match, county_match) %>%
    mutate(
      match_key = paste(
        state_match,
        county_match,
        sep = "__"
      )
    ) %>%
    pull(match_key)
  
  admin_vect[
    admin_vect$match_key %in% species_keys,
  ]
}

# Use consistent matching-column names between the U.S. and Canadian tables
cor_counties_ca <- cor_counties_ca %>%
  rename(
    state_match = province_match
  )

cor_counties_ca_vect$state_match <-
  cor_counties_ca_vect$province_match

cor_counties_ca_vect$match_key <- paste(
  cor_counties_ca_vect$state_match,
  cor_counties_ca_vect$county_match,
  sep = "__"
)

# SEPERATE BY SPECIES (corymbosum seperate)
# Restricted sensu Vaccinium corymbosum Vander Kloet

ash_counties_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium ashei"
)

cor_counties_us_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium corymbosum"
)

cot_counties_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium constablei" # note drop a in aei...
)

ell_counties_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium elliottii"
)

fus_counties_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium fuscatum"
)

sim_counties_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium simulatum"
)

vir_counties_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium virgatum"
)

# Remaining Vaccinium sect. Cyanococcus

hir_counties_vect <- subset_admin_by_species(
  admin_vect = cyan_counties_us_vect,
  county_data = cyan_counties_us,
  species_name = "Vaccinium hirsutum"
)

# CORYMBOSUM
# Standardize U.S. Vaccinium corymbosum county attributes
cor_counties_us_vect$country <- "USA"
cor_counties_us_vect$admin_name <- cor_counties_us_vect$NAME

cor_counties_us_vect <- cor_counties_us_vect[
  ,
  c(
    "country",
    "state_match",
    "county_match",
    "match_key",
    "admin_name"
  )
]

# Standardize Canadian Vaccinium corymbosum Census Division attributes
cor_counties_ca_vect$country <- "CANADA"
cor_counties_ca_vect$admin_name <- cor_counties_ca_vect$CDNAME

cor_counties_ca_vect <- cor_counties_ca_vect[
  ,
  c(
    "country",
    "state_match",
    "county_match",
    "match_key",
    "admin_name"
  )
]

# Combine U.S. counties and Canadian Census Divisions for V. corymbosum
cor_counties_vect <- rbind(
  cor_counties_us_vect,
  cor_counties_ca_vect
)

# CHECK SUBSETS
ash_counties_vect
cor_counties_vect
cot_counties_vect
ell_counties_vect
fus_counties_vect
sim_counties_vect
vir_counties_vect
hir_counties_vect

# Mask occurrence data by species by counties -----------------------------

occ_ash_vect_filtered <- terra::intersect(
  occ_ash_vect,
  ash_counties_vect
)

occ_cor_vect_filtered <- terra::intersect(
  occ_cor_vect,
  cor_counties_vect
)

occ_fus_vect_filtered <- terra::intersect(
  occ_for_vect,
  fus_counties_vect
)

occ_cot_vect_filtered <- terra::intersect(
  occ_cot_vect,
  cot_counties_vect
)

occ_ell_vect_filtered <- terra::intersect(
  occ_ell_vect,
  ell_counties_vect
)

occ_sim_vect_filtered <- terra::intersect(
  occ_sim_vect,
  sim_counties_vect
)

occ_vir_vect_filtered <- terra::intersect(
  occ_vir_vect,
  vir_counties_vect
)

occ_hir_vect_filtered <- terra::intersect(
  occ_hir_vect,
  hir_counties_vect
)

# check how many records were retained
tibble(
  species = c(
    "ash", "cor", "fus", "cot",
    "ell", "sim", "vir", "hir"
  ),
  after = c(
    nrow(occ_ash_vect_filtered),
    nrow(occ_cor_vect_filtered),
    nrow(occ_fus_vect_filtered),
    nrow(occ_cot_vect_filtered),
    nrow(occ_ell_vect_filtered),
    nrow(occ_sim_vect_filtered),
    nrow(occ_vir_vect_filtered),
    nrow(occ_hir_vect_filtered)
  ),
  before = c(
    nrow(occ_ash_vect),
    nrow(occ_cor_vect),
    nrow(occ_fus_vect),
    nrow(occ_cot_vect),
    nrow(occ_ell_vect),
    nrow(occ_sim_vect),
    nrow(occ_vir_vect),
    nrow(occ_hir_vect)
  )
) %>%
  mutate(
    removed = before - after,
    retained_percent = round(after / before * 100, 1)
  )

# A tibble: 8 × 5
# species after before removed retained_percent
# <chr>   <dbl>  <dbl>   <dbl>            <dbl>
#   1 ash        39     51      12             76.5
# 2 cor      8373  13780    5407             60.8
# 3 fus      1952   2235     283             87.3
# 4 cot        96    100       4             96  
# 5 ell       457   2087    1630             21.9
# 6 sim       148    157       9             94.3
# 7 vir       334    362      28             92.3
# 8 hir       142    145       3             97.9

# Export filtered occ data ------------------------------------------------
saveRDS(occ_ash_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_ash_clean.rds")
saveRDS(occ_cor_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_cor_clean.rds")
saveRDS(occ_fus_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_fus_clean.rds")
saveRDS(occ_cot_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_cot_clean.rds")
saveRDS(occ_ell_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_ell_clean.rds")
saveRDS(occ_sim_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_sim_clean.rds")
saveRDS(occ_vir_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_vir_clean.rds")
saveRDS(occ_hir_vect_filtered, "occ_data/sect_cyan_final/clean_county_filtered/occ_hir_clean.rds")
