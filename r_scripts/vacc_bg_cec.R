# Top ---------------------------------------------------------------------
# Terrell Roulston

# This script is for generating background data for vaccinium species
# NOTE: I am updating the ecoregion data to the ecoregions of North America published by the EPA and Commision for Environmental Cooperation
# from the Koppen-Greiger climate zontes used previously, as we are no longer including 
# Central American countries

# Libraries
library(tidyverse)
library(terra)
library(tidyterra)

# Load ecoregion vector and wclim raster ----------------------------------
# Load ecoregion shape file from the CEC dataset
# Visit: https://www.epa.gov/eco-research/ecoregions-north-america
ecoNA <- vect(x = "maps/cec_eco/na_cec_eco_l2/NA_CEC_Eco_Level2.shp")
ecoNA <- project(ecoNA, 'WGS84') # project ecoregion vector to same coords ref as basemap

# Load Canada, US and Mexico cropped Worldcim raster
wclim_CA_US_MX <- readRDS('./wclim_data/wclim_CA_US_MX/wclim_CA_US_MX.Rdata')


# Load occurrence data for main Vaccinium ---------------------------------
file_names1 <- c(
  "occ_ang_thin", "occ_arb_thin", "occ_bor_thin", "occ_ces_thin", "occ_cor_thin",
  "occ_cra_thin", "occ_dar_thin", "occ_del_thin", "occ_ery_thin", "occ_hir_thin",
  "occ_mac_thin", "occ_mem_thin", "occ_mtu_thin", "occ_myr_thin", "occ_mys_thin",
  "occ_ova_thin", "occ_ovt_thin", "occ_oxy_thin", "occ_pal_thin", "occ_par_thin",
  "occ_sco_thin", "occ_sta_thin", "occ_ten_thin", "occ_uli_thin", "occ_vid_thin",
  "occ_sha_thin"
)

file_path1 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/"

# Read all Rdata and assign each to a variable with its corresponding name
for (name in file_names1) {
  assign(name, readRDS(file.path(file_path1, paste0(name, ".Rdata"))))
}

# Load occurrence data for Corymbosum complex -----------------------------
file_names2 <- c(
  "occ_ash_thin", "occ_cae_thin", "occ_cor2_thin", "occ_cot_thin", "occ_ell_thin",
  "occ_for_thin", "occ_fus_thin", "occ_sim_thin", "occ_vir_thin"
)

file_path2 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/corym_sub"

# Read all Rdata and assign each to a variable with its corresponding name
for (name in file_names2) {
  assign(name, readRDS(file.path(file_path2, paste0(name, ".Rdata"))))
}


# Create list of occ df from filenames ------------------------------------
# setNames = assign object names
# lapply across file names and return the filename to setNames
# Main Vaccinium spp dataset
occ_thin_list1 <- setNames(lapply(file_names1, get), file_names1)
# Corymbossum complex dataset
occ_thin_list2 <- setNames(lapply(file_names2, get), file_names2) 

# Ecoregion extraction function -------------------------------------------
# This function does two things 1) from the spatvector of occurrence points for each species,
# it returns the list of ecoregion codes at points, and 2) it subsets the ecoregion spatvector
# to contain only the ecoregions where occurrences are found for each species and 
# returns the subsetted ecoregion spatvector

get_ecoregions <- function(occ_pts, ecoNA, code_col = "NA_L2CODE", drop_code = "0.0") {
  
  x <- terra::intersect(occ_pts, ecoNA) # Intersect returns pts values from spatvector layer
  
  # Catch if intersect returns no overlap, return 0
  if (nrow(x) == 0) {
    return(list(
      codes = character(0),
      eco_subset = ecoNA[0, ]
    ))
  }
  
  codes <- unique(x[[code_col]][[1]]) # Return the unique codes extracted from the Level 2 ecoregion codes
  codes <- codes[!is.na(codes) & codes != drop_code] # Drop NA values and Water code: "0.0"
  
  # Subset CEC ecoregion spatvector from unique codes for each species
  eco_subset <- terra::subset(ecoNA, ecoNA[[code_col]] %in% codes) 
  
  # For each spp list what ecoregion codes they are, and a spatevector of subsetted ecoregions
  list(
    codes = codes,
    eco_subset = eco_subset
  )
}

# Run ecoregion extraction function ---------------------------------------
# Main Vaccinium occurrence set
ecoregion_list1 <- lapply(occ_thin_list1, get_ecoregions, ecoNA = ecoNA)

# Corymbosum complex occurrence set
ecoregion_list2 <- lapply(occ_thin_list2, get_ecoregions, ecoNA = ecoNA)

# Now I want to split the ecoregion lists into two seperate list, one of the ecoregion codes and 
# two the spatvectors of subsetted ecoregions so I can save them separately

# Note: `[[` is the list-extraction operator; here it pulls the named element from each sublist

# Ecoregion code lists
eco_codes_list1 <- lapply(ecoregion_list1, `[[`, 'codes') # Main set
eco_codes_list2 <- lapply(ecoregion_list2, `[[`, 'codes') # Corymbosum complex

# Ecoregion spatvector lists
eco_vect_list1 <- lapply(ecoregion_list1, `[[`, 'eco_subset') # Main set
eco_vect_list2 <- lapply(ecoregion_list2, `[[`, 'eco_subset') # Corymbosum complex

# Save the ecoregion codes and spatvectors --------------------------------
# ECOREGION CODES
# Function for saving vector of ecoregion codes for each species from list above
save_eco_code <- function(x, name, out_dir) {
  fname <- file.path(out_dir, paste("eco_", name, "_code.Rdata"))
  saveRDS(x, fname)
  fname
} 

out_dir1 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_code/" # specify output dir
dir.create(out_dir1, showWarnings = FALSE, recursive = TRUE) # create the dir and/or check it exists
out_dir2 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_code/corym_sub"
dir.create(out_dir2, showWarnings = FALSE, recursive = TRUE) 

# Save main Vaccinium spp ecoregion spatvectors
Map(save_eco_code, eco_codes_list1, names(eco_codes_list1), MoreArgs = list(out_dir = out_dir1)) 
# Save Corymbosum complex spp ecoregion spatvectors
Map(save_eco_code, eco_codes_list2, names(eco_codes_list2), MoreArgs = list(out_dir = out_dir2))


# ECOREGION SPATVECTORS
# Function for saving spatvector of subseted ecoregions from list above
save_eco_tiff <- function(x, name, out_dir) {
  fname <- file.path(out_dir, paste0("eco_", name, "_vect.shp"))
  terra::writeVector(x, fname)
  fname
}

out_dir1 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_shp/" # specify output dir
dir.create(out_dir1, showWarnings = FALSE, recursive = TRUE) # create the dir and/or check it exists
out_dir2 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_shp/corym_sub"
dir.create(out_dir2, showWarnings = FALSE, recursive = TRUE)

# Save main Vaccinium spp ecoregion spatvectors
Map(save_eco_tiff, eco_vect_list1, names(eco_vect_list1), MoreArgs = list(out_dir = out_dir1)) 
# Save Corymbosum complex spp ecoregion spatvectors
Map(save_eco_tiff, eco_vect_list2, names(eco_vect_list2), MoreArgs = list(out_dir = out_dir2))

# Crop WorldClim data to ecoregions ---------------------------------------
# Now we need to crop the Worldclim training data raster to the extent of the ecoregions for each species




