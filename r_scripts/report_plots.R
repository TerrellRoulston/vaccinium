# Top ---------------------------------------------------------------------
# This script is for automating plotting of suitability maps to be used in internal reporting
# Terrell Roulston
# Feb 11th 2025

# Libraries
library(tidyverse)
library(terra)

# Load occurrence data ----------------------------------------------------
# Main Vaccinium spp (use sp_codes1)
sp_codes1 <- c(
  "ang", "arb", "bor", "ces", "cor",
  "cra", "dar", "del", "ery", "gem",
  "hir", "mac", "mem", "mtu", "mys",
  "myr", "ova", "ovt", "oxy", "pal",
  "par", "sco", "sta", "ten", "uli",
  "vid", "sha"
)
# Corymbosum complex (use sp_codes2)
sp_codes2 <- c(
  "ash", "cae", "cor2", "cot", "ell",
  "for", "fus", "sim", "vir"
)

# Directories where thinned occurrence RDS live
occ_dir1 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/"
occ_dir2 <- "C:/Users/terre/Documents/R/vaccinium/occ_data/thin/corym_sub/"

# Build full file paths from species codes
occ_files1 <- file.path(occ_dir1, paste0("occ_", sp_codes1, "_thin.rds"))
occ_files2 <- file.path(occ_dir2, paste0("occ_", sp_codes2, "_thin.rds"))

names(occ_files1) <- sp_codes1
names(occ_files2) <- sp_codes2

# Helper: read + fail loudly with a helpful message
read_occ_rds <- function(path) {
  if (!file.exists(path)) stop("Missing occurrence file: ", path)
  readRDS(path)
}

# Load occurrence data as named lists (names = species codes)
occ_thin_list1 <- lapply(occ_files1, read_occ_rds)
occ_thin_list2 <- lapply(occ_files2, read_occ_rds)

# Load map assets ---------------------------------------------------------
# Great Lakes shapefiles for making pretty maps
# Shape files downloaded from the USGS (https://www.sciencebase.gov/catalog/item/530f8a0ee4b0e7e46bd300dd)
great_lakes <- vect('C:/Users/terre/Documents/Acadia/Malus Project/maps/great lakes/combined great lakes/')

# Canada/US Border for showing the international line. Gadm admin boundaries trace the entire country, vs this is just the border
# Much easier to see the SDM results along coastlines where tracing obscures the data
# Downloaded from  https://koordinates.com/layer/111012-canada-and-us-border/
can_us_border <- vect('C:/Users/terre/Documents/Acadia/Malus Project/maps/can_us border')

# Two line segments are in the water and are not needed in this case, lets remove them to make the maps look prettier
segments_to_remove <- c("Gulf of Maine", "Straits of Georgia and Juan de Fuca")
can_us_border <- can_us_border[!can_us_border$SectionEng %in% segments_to_remove]



