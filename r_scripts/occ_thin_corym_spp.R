# Top ---------------------------------------------------------------------
# Terrell Roulston
# February 4th, 2026
# Thinning occurrence data for V. corymbosum complex taxa

# Libraries
library(tidyverse) # grammar and data management 
library(terra) # working with spatial data
library(geodata) # basemaps and climate data

# ash – Vaccinium ashei
# cae – Vaccinium caesariense
# cor2 – Vaccinium corymbosum
# cot – Vaccinium constablaei
# ell – Vaccinium elliottii
# for – Vaccinium formosum (syn. Vaccinium australe)
# fus – Vaccinium fuscatum (syn. Vaccinium arkansanum, Vaccinium atrococcum)
# sim – Vaccinium simulatum
# vir – Vaccinium virgatum (syn. Vaccinium amoenum)


# Load cleaned occ data ---------------------------------------------------
file_names <- c(
  "occ_ash_clean", "occ_cae_clean", "occ_cor2_clean", "occ_cot_clean", "occ_ell_clean",
  "occ_for_clean", "occ_fus_clean", "occ_sim_clean", "occ_vir_clean"
)

# Directory path where the CSV files are stored
file_path <- "C:/Users/terre/Documents/R/vaccinium/occ_data/clean/corym_sub"

# Read all Rdata and assign each to a variable with its corresponding name
for (name in file_names) {
  assign(name, readRDS(file.path(file_path, paste0(name, ".Rdata"))))
}

# Vectorize the cleaned occurrences ---------------------------------------
occ_list_clean <- mget(file_names) # list the df objects using the files names from above

# Build function to vectorize occ dfs
df_to_vect <- function(df, spp) {
  df$spp <- spp
  terra::vect( # vectorize occ data by specfiying geometry and crs
    df,
    geom = c("decimalLongitude", "decimalLatitude"),
    crs = "+proj=longlat +datum=WGS84"
  )
}

taxa <- gsub("^occ_|_clean$", "", names(occ_list_clean)) # get cleaned taxa abrv to feed names into output
occ_vect_list <- Map(df_to_vect, occ_list_clean, taxa) # vectorize all cleaned occurrece dfs
names(occ_vect_list) <- taxa # name each object in list using taxon abrv

# Load Wclim data for thinning strata -------------------------------------
# Use the predictor layer at 2.5 arc/min grid to thin occ
# NOTE MAKE SURE TO ADD WCLIM to .gitignore so not to push big files

# Note that the CRS of occ data and wclim data are already the same but good to check if youre not sure
wclim <- worldclim_global(var = 'bio', res = 2.5, version = '2.1', path = "./wclim_data/")

# Thin occurrences using random sampler -----------------------------------
set.seed(1337) # set random generator seed to get reproducible results

occ_thin_list <- lapply(
  occ_vect_list, # list of occ vects
  terra::spatSample, # function to sample from spatvectors
  size = 1, # take one sample (occ) from each strata
  strata = wclim[[1]] # only need one layer for the strata
)

# Save thinned occurrences for downstream ---------------------------------

# function for saving thinned occurence spatvectors within the thinned occurrence list
save_thin_Rdata <- function(x, name, out_dir) {
  fname <- file.path(out_dir, paste0("occ_", name, "_thin.Rdata"))
  saveRDS(x, fname)
  fname
}

out_dir <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/corym_sub" # specify output dir
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE) # create the dir and/or check it exists

# Using Map rather than lapply bc multiple arguments vary, lapply is better if only the input varies...
Map(save_thin_Rdata, occ_thin_list, names(occ_thin_list), MoreArgs = list(out_dir = out_dir))

