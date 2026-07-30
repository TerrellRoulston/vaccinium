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
wclim_CA_US_MX <- readRDS('./wclim_data/wclim_CA_US_MX/wclim_CA_US_MX.rds')


# Load occurrence data for main Vaccinium ---------------------------------
file_names <- c(
  "occ_ash_thin", "occ_cor_thin", "occ_cot_thin", "occ_ell_thin",
  "occ_fus_thin", "occ_sim_thin", "occ_vir_thin", "occ_ang_thin",
  "occ_bor_thin", "occ_dar_thin", "occ_hir_thin", "occ_myr_thin",
  "occ_mys_thin", "occ_pal_thin", "occ_ten_thin"
)

# Directory path where the CSV files are stored
file_path <- "C:/Users/terre/Documents/R/vaccinium/occ_data/sect_cyan_final/thin"


# Read all Rdata and assign each to a variable with its corresponding name
for (name in file_names) {
  assign(name, readRDS(file.path(file_path, paste0(name, ".rds"))))
}

# Create list of occ df from filenames ------------------------------------
# setNames = assign object names
# lapply across file names and return the filename to setNames
# Main Vaccinium spp dataset
# Get string of filenames and set element names in list to filenames
occ_thin_list <- setNames(lapply(file_names, get), file_names)

###### ECO REGION EXTRACTION ######
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
  
  # pull SpatVector ecoregion ID col as plain vector
  pull_vec <- function(v, col) {
    as.character(v[[col]][[1]])
  }
  
  codes <- unique(pull_vec(x, code_col)) # Return the unique codes extracted from the Level 2 ecoregion codes
  codes <- codes[!is.na(codes) & codes != drop_code]# Drop NA values and Water code: "0.0"
  
  eco_codes <- pull_vec(ecoNA, code_col)  # Pull full ecoNA code column (as vector!)
  
  # Subset CEC ecoregion spatvector from unique codes for each species
  eco_subset <- ecoNA[eco_codes %in% codes, ]
  
  # For each spp list what ecoregion codes they are, and a spatevector of subsetted ecoregions
  list(
    codes = codes,
    eco_subset = eco_subset
  )
}

# Run ecoregion extraction function ---------------------------------------
# Extract ecoregions
ecoregion_list <- lapply(occ_thin_list, get_ecoregions, ecoNA = ecoNA)

# Now I want to split the ecoregion lists into two seperate list, one of the ecoregion codes and 
# two the spatvectors of subsetted ecoregions so I can save them separately

# Note: `[[` is the list-extraction operator; here it pulls the named element from each sublist

# Ecoregion code lists
eco_codes_list <- lapply(ecoregion_list, `[[`, 'codes') 

# Ecoregion spatvector lists
eco_vect_list <- lapply(ecoregion_list, `[[`, 'eco_subset') # Main set

# Save the ecoregion codes and spatvectors --------------------------------
# ECOREGION CODES
# Function for saving vector of ecoregion codes for each species from list above
save_eco_code <- function(x, name, out_dir) {
  fname <- file.path(out_dir, paste("eco_", name, "_code.rds"))
  saveRDS(x, fname)
  fname
} 

out_dir <- "C:/Users/terre/Documents/R/vaccinium/bg_data/sect_cyan_final/eco_code/" # specify output dir
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE) # create the dir and/or check it exists

# Save Sect Cyanoccucus Vaccinium spp ecoregion spatvectors
Map(save_eco_code, eco_codes_list, names(eco_codes_list), MoreArgs = list(out_dir = out_dir)) 

# ECOREGION SPATVECTORS
# Function for saving spatvector of subseted ecoregions from list above
# Saving them as a .gpkg file
save_eco_gpkg <- function(x, name, out_dir) {
  fname <- file.path(out_dir, paste0("eco_", name, "_vect.gpkg"))
  terra::writeVector(x, fname, overwrite = TRUE)
  fname
}

out_dir1 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/sect_cyan_final/eco_shp/" # specify output dir
dir.create(out_dir1, showWarnings = FALSE, recursive = TRUE) # create the dir and/or check it exists

Map(save_eco_gpkg, eco_vect_list, names(eco_vect_list), MoreArgs = list(out_dir = out_dir)) 


# Summarize ecoregion codes by spp ----------------------------------------
# Summarize main Vaccinium spp
eco_summary <- data.frame(
  species = names(eco_codes_list),
  eco_codes = vapply(
    eco_codes_list,
    function(x) paste(x, collapse = ", "),
    character(1)
  ),
  stringsAsFactors = FALSE
)

print(eco_summary)

###### WORLDCLIM MASKING AND BG PTS SAMPLING ######
# Mask WorldClim data to ecoregion subset for each spp --------------------
# By cropping and masking WorldClim data to the ecoregion background extent for each species
# the training background climate is established for each SDM downstream

# Crop and mask the climate raster to the ecoregion spatvector
mask_wclim_to_vect <- function(r, v) {
  if (is.null(v) || nrow(v) == 0) return(NULL) # catch if vector is empty
  v2 <- terra::aggregate(v) # dissolve internal boundaries into one polygon, disjunct areas stay separate
  terra::crop(r, v2, mask = TRUE) # crop and mask worlclim to dissolved ecoregions
}

# Create masked raster lists (names preserved)
wclim_mask_list <- setNames(
  lapply(names(eco_vect_list), function(nm) mask_wclim_to_vect(wclim_CA_US_MX, eco_vect_list[[nm]])),
  names(eco_vect_list)
)

# Drop NULLs if any species had no overlap (should be rare, but safe)
wclim_mask_list <- wclim_mask_list[!vapply(wclim_mask_list, is.null, logical(1))]

# Save masked Wclim layers
save_wclim_mask_tif <- function(r, name, out_dir) {
  fname <- file.path(out_dir, paste0("wclim_", name, "_bgmask.tif"))
  terra::writeRaster(r, fname, overwrite = TRUE)
  fname
}

# Create directories
out_dir2 <- "C:/Users/terre/Documents/R/vaccinium/wclim_data/sect_cyan_final/wclim_spp_mask/"
dir.create(out_dir2, showWarnings = FALSE, recursive = TRUE)

save_wclim_mask_tif <- function(r, name, out_dir) {
  fname <- file.path(out_dir, paste0("wclim_", name, "_bgmask.tif"))
  terra::writeRaster(r, fname, overwrite = TRUE)
  fname
}

Map(save_wclim_mask_tif, wclim_mask_list, names(wclim_mask_list), MoreArgs = list(out_dir = out_dir2))

# Sample random background points from masked ecoregions ------------------
set.seed(1337) # Set seed to get reproducible results

# First need to know how many cells contain non-NA values in each raster
n_valid_cells <- function(r) {
  # logical raster: TRUE where not NA
  nn <- terra::global(!is.na(r[[1]]), "sum", na.rm = TRUE)[1, 1]
  as.integer(nn)
}

# Help function to run random sampler, will take 30000 points, or the number of non-NA cells 'nn' found above
sample_wclim_bg <- function(r, n = 30000) {
  if (is.null(r)) return(NULL) # safe catch bad rasters
  nv <- n_valid_cells(r) # number of non-NA cells
  if (is.na(nv) || nv == 0) return(NULL) # safe catch bad rasters
  
  n_take <- min(n, nv) # which ever number is smaller
  
  terra::spatSample(
    r, # masked spp wclim raster
    size = n_take, # number of samples, 30000 or less than if nv is smaller
    method = "random", # random sample
    na.rm = TRUE, # skip NA cells
    as.points = TRUE, # points
    values = TRUE # keep the values of the raster at each pt (might not really need to do this tbh)
  )
}

# SpatSampler take quite a while to run so be patient!


# Build sampled lists (points with BIO variables as attributes)
wclim_bgpts_list <- setNames(
  lapply(names(wclim_mask_list), \(nm) sample_wclim_bg(wclim_mask_list[[nm]], n = 30000)),
  names(wclim_mask_list)
)

# Drop NULLs if any
wclim_bgpts_list <- wclim_bgpts_list[!vapply(wclim_bgpts_list, is.null, logical(1))]

# Save background point SpatVectors
save_bgpts_rds <- function(x, name, out_dir) {
  fname <- file.path(out_dir, paste0("wclim_", name, "_bgpts.rds"))
  saveRDS(x, fname)
  fname
}

out_dir3 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/sect_cyan_final/wclim_bgpts/"
dir.create(out_dir3, showWarnings = FALSE, recursive = TRUE)


Map(save_bgpts_rds, wclim_bgpts_list, names(wclim_bgpts_list), MoreArgs = list(out_dir = out_dir3))

# Summarize bg point selection --------------------------------------------
# Summarize the number of bg pts for each spp
# Looking for spp with fewer than 30000 pts

# Summarize main Vaccinium spp
bg_summary <- data.frame(
  species = names(wclim_bgpts_list),
  n_bg = vapply(wclim_bgpts_list, nrow, numeric(1))
)
  
print(bg_summary)


# Subset spp with fewer than 30000 bg pts (this is do to their small ecogeorgapic available space)
# i.e. the number of non-NA raster cells found within masked wclim raster is fewer than 30,000

# Subset returns
subset(bg_summary, n_bg < 30000)
