# Top ---------------------------------------------------------------------
# Terrell Roulston
# Thinning occurrence data for sect. Cyanocacus species

# Libraries
library(tidyverse) # grammar and data management 
library(terra) # working with spatial data
library(geodata) # basemaps and climate data

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
# ang – Vaccinium angustifolium
# bor – Vaccinium boreale
# dar – Vaccinium darrowii
# hir – Vaccinium hirsutum
# myr – Vaccinium myrtilloides
# mys – Vaccinium myrsinites
# pal – Vaccinium pallidum (syn. Vaccinium vacillans)
# ten – Vaccinium tenellum



# Load cleaned occ data ---------------------------------------------------
file_names <- c(
  "occ_ash_clean", "occ_cor_clean", "occ_cot_clean", "occ_ell_clean",
  "occ_fus_clean", "occ_sim_clean", "occ_vir_clean", "occ_ang_clean",
  "occ_bor_clean", "occ_dar_clean", "occ_hir_clean", "occ_myr_clean",
  "occ_mys_clean", "occ_pal_clean", "occ_ten_clean"
)

# Directory path where the CSV files are stored
file_path <- "C:/Users/terre/Documents/R/vaccinium/occ_data/sect_cyan_final/clean_county_filtered"

# Read all Rdata and assign each to a variable with its corresponding name
for (name in file_names) {
  assign(name, readRDS(file.path(file_path, paste0(name, ".rds"))))
}

# Vectorize the cleaned occurrences ---------------------------------------
occ_list_clean <- mget(file_names) # list the df objects using the files names from above

# Build function to vectorize occ dfs
df_to_vect <- function(df, spp) {
  
  # If already a SpatVector, simply add species name and return
  if (inherits(df, "SpatVector")) {
    df$spp <- spp
    return(df)
  }
  
  # Otherwise convert the data frame to a SpatVector
  df$spp <- spp
  
  terra::vect(
    df,
    geom = c("decimalLongitude", "decimalLatitude"),
    crs = "EPSG:4326"
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
save_thin_rds <- function(x, name, out_dir) {
  fname <- file.path(out_dir, paste0("occ_", name, "_thin.rds"))
  saveRDS(x, fname)
  fname
}

out_dir <- "C:/Users/terre/Documents/R/vaccinium/occ_data/sect_cyan_final/thin" # specify output dir
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE) # create the dir and/or check it exists

# Using Map rather than lapply bc multiple arguments vary, lapply is better if only the input varies...
Map(save_thin_rds, occ_thin_list, names(occ_thin_list), MoreArgs = list(out_dir = out_dir))

# Compare cleaned and thinned occurrence counts ---------------------------

compare_occ_counts <- function(clean_list, thin_list) {
  
  stopifnot(
    identical(names(clean_list), names(thin_list))
  )
  
  tibble(
    taxa = names(clean_list),
    clean_n = map_int(clean_list, nrow),
    thin_n = map_int(thin_list, nrow)
  ) %>%
    mutate(
      removed_n = clean_n - thin_n,
      retained_percent = round(
        thin_n / clean_n * 100,
        1
      )
    )
}

occ_count_summary <- compare_occ_counts(
  clean_list = occ_vect_list,
  thin_list = occ_thin_list
)

occ_count_summary

write_csv(
  occ_count_summary,
  file.path(out_dir, "occ_thinning_summary.csv")
)
