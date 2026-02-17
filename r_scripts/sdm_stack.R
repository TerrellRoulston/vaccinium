# Top ---------------------------------------------------------------------
# Stacking SDMs
# Compute individual SDM for each species
# Reference:
# Calabrese, J. M., Certain, G., Kraan, C., & Dormann, C. F. (2014). 
#Stacking species distribution models and adjusting bias by linking them to macroecological models. 
#Global Ecology and Biogeography, 23(1), 99–112. https://doi.org/10.1111/geb.12102

# Output of Maxent are on cloglog scale and do not need to be transformed, but should stack before thresholding and not after!


# libraries ---------------------------------------------------------------
library(tidyverse)
library(terra)
library(geodata)

# Import suitability rasters ----------------------------------------------
sp_codes1 <- c(
  "ang", "arb", "bor", "ces", "cor", 
  "cra", "dar", "del", "ery", "gem", 
  "hir", "mac", "mem", "mtu", "mys", 
  "myr", "ova", "ovt", "oxy", "pal", 
  "par", "sco", "sha", "sta", "ten", 
  "uli", "vid"
)

sp_codes2 <- c(
  "ash", "cae", "cor2", "cot", "ell",
  "for", "fus", "sim", "vir"
)

# make a file path to read each species as its code
pred_files1 <- file.path(
  "sdm_output", "sdm_output_feb_10_2026",
  sp_codes1,
  paste0(sp_codes1, "_pred_hist.rds")
)

pred_files2 <- file.path(
  "sdm_output", "sdm_output_feb_10_2026", "corym_sub",
  sp_codes2,
  paste0(sp_codes2, "_pred_hist.rds")
)

names(pred_files1) <- sp_codes1  # so I can keep track
names(pred_files2) <- sp_codes2  # so I can keep track

# Helper function for reading in rasters as RDS
read_pred_raster <- function(path) {
  obj <- readRDS(path)
  
  # If you saved the prediction directly as a SpatRaster
  if (inherits(obj, "SpatRaster")) {
    return(obj)
  }
  
  stop("Don't know how to extract a raster from: ", path)
}

# Load all Rasters using function
spp_rasters1 <- lapply(pred_files1, read_pred_raster)
spp_rasters2 <- lapply(pred_files2, read_pred_raster)

# Mask suitability rasters to historical ecoregions -----------------------

# First need to import the ecoregion shape files from the background script

eco_dir1 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_shp"
eco_dir2 <- "C:/Users/terre/Documents/R/vaccinium/bg_data/eco_shp/corym_sub"

# build file paths as inputs
eco_files1 <- file.path(
  eco_dir1,
  paste0("eco_occ_", sp_codes1, "_thin_vect.gpkg")
)
names(eco_files1) <- sp_codes1

eco_files2 <- file.path(
  eco_dir2,
  paste0("eco_occ_", sp_codes2, "_thin_vect.gpkg")
)
names(eco_files2) <- sp_codes2


# load ecoregion vectors
eco_vect_list1 <- lapply(eco_files1, function(f) {
  if (!file.exists(f)) {
    stop("Missing ecoregion file: ", f)
  }
  vect(f)
})

eco_vect_list2 <- lapply(eco_files2, function(f) {
  if (!file.exists(f)) {
    stop("Missing ecoregion file: ", f)
  }
  vect(f)
})

# Now mask the suitability rasters
mask_to_ecos <- function(r, eco) {
  if (is.null(r) || is.null(eco)) return(NULL)
  
  # CRS match (required)
  if (!same.crs(r, eco)) eco <- project(eco, crs(r))
  
  # crop (fast) then mask (set outside to NA)
  r2 <- mask(r, eco)
  
  r2
}

mask_raster_list <- function(r_list, eco_list) {
  # only process species present in both lists
  common <- intersect(names(r_list), names(eco_list))
  
  if (length(common) == 0) stop("No overlapping names between rasters and ecoregions.")
  
  out <- setNames(vector("list", length(common)), common)
  
  for (nm in common) {
    out[[nm]] <- mask_to_ecos(r_list[[nm]], eco_list[[nm]])
  }
  
  out
}

# mask both sets
spp_rasters1_masked <- mask_raster_list(spp_rasters1, eco_vect_list1)
spp_rasters2_masked <- mask_raster_list(spp_rasters2, eco_vect_list2)

# Stack rasters! ----------------------------------------------------------
# Create a SpatRaster stack
spp_stack1 <- rast(spp_rasters1_masked)
names(spp_stack1) <- names(spp_rasters1_masked)  # ang, cor, ...

spp_stack2 <- rast(spp_rasters2_masked)
names(spp_stack2) <- names(spp_rasters2_masked)

# Expected richness (Calabrese Eq. 2: sum of probabilities)
richness_mean1 <- app(spp_stack1, fun = sum, na.rm = TRUE)
richness_mean2 <- app(spp_stack2, fun = sum, na.rm = TRUE)

# Optional: variance of richness (Calabrese Eq. 3: Σ p(1–p))
richness_var1 <- app(
  spp_stack1,
  fun = function(x) sum(x * (1 - x), na.rm = TRUE)
)

rich_zero_na1 <- ifel(richness_mean1 < 1, NA, richness_mean1)

richness_var2 <- app(
  spp_stack2,
  fun = function(x) sum(x * (1 - x), na.rm = TRUE)
)

rich_zero_na2 <- ifel(richness_mean2 < 1, NA, richness_mean2)

# Plotting stacked richness -----------------------------------------------
# Great Lakes shapefiles for making pretty maps and cropping
great_lakes <- vect('C:/Users/terre/Documents/Acadia/Malus Project/maps/great lakes/combined great lakes/')
NA_ext <- ext(-180, -30, 5, 90) # Set spatial extent of analysis to NA in Western Hemisphere, approximate north of Panama

ca_mx_codes <- c("CA","MX")
us_code <- c("US")
base_path <- "./maps/base_maps/" # path to GADM files

# map to download/load GADM level-1 maps for all countries, returns list of SpatVectors
maps_list <- map(ca_mx_codes, ~gadm(country = .x, level = 0, resolution = 2, path = base_path))

us_map_0 <- gadm(country = us_code, level = 0, resolution = 2, path = base_path)
us_map_1 <- gadm(country = us_code, level = 1, resolution = 2, path = base_path)
us_map_noHawaii <- us_map_1 %>% tidyterra::filter(NAME_1 != "Hawaii") # I want all the US states except Hawawii
us_map_0 <- terra::intersect(us_map_noHawaii, us_map_0) %>% crop(NA_ext) # drop Hawaii from US country map plus crop Alaska archipelago at 180th parallel.
us_map_0 <- terra::aggregate(us_map_0, fact = 2, disolve = TRUE) # dissolve into one SpatVector rather than different state polygons
# Combine all SpatVectors into one
all_countries_map <- do.call(rbind, c(maps_list, us_map_0)) # combine other countries and US less Hawaii


pal1 <- hcl.colors(8, "Viridis") # There is max of 8 richness for main Vaccinium spp
pal2 <- hcl.colors(5, "viridis") # This is a max of 5 richness for Corymbosum complex


# Plot historical species richness of Vaccinium   
png(file = "./figures/stacked_richness/stacked_vaccinium_richness_hist.png", width = 1600, height = 2000, res = 300)

plot(rich_zero_na1,
     col = pal1,
     main = "Predicted Vaccinium richness (Historical)",
     colNA = "white")   # NA cells plotted as white

plot(all_countries_map, col = 'transparent', border = 'black', add = TRUE)
plot(great_lakes,  col = 'transparent', border = 'black', add = TRUE)

dev.off()

# Plot historical species richness of Croum   
png(file = "./figures/stacked_richness/stacked_corymbosum_richness_hist.png", width = 1600, height = 2000, res = 300)

plot(rich_zero_na2,
     col = pal2,
     main = "Predicted V. corymbosum \n complex richness (Historical)",
     colNA = "white", # NA cells plotted as white
     xlim = c(-110, -20),
     ylim = c(20, 60))   

plot(all_countries_map, col = 'transparent', border = 'black', add = TRUE)
plot(great_lakes,  col = 'transparent', border = 'black', add = TRUE)

dev.off()