# Top ---------------------------------------------------------------------
# Plotting density map of thinned occurrence data
# Terrell Roulston
# September 2nd 2025


# Libraries ---------------------------------------------------------------
library(tidyverse)
library(terra)
library(geodata)
library(viridis)


# Load basemap data -------------------------------------------------------
## Country boundaries:
us_map_0 <- gadm(country = 'USA', level = 0, resolution = 2, path = "./maps/base_maps") 
ca_map_0 <- gadm(country = 'CA', level = 0, resolution = 2, path = './maps/base_maps') 
mex_map_0 <-gadm(country = 'MX', level = 0, resolution = 2, path = './maps/base_maps') 
gl_map_0  <-gadm(country = 'GL', level = 0, resolution = 2, path = './maps/base_maps') 

can_us_mex_border <- rbind(us_map_0, ca_map_0, mex_map_0)

caribbean_codes <- c("BS", "CU", "JM", "HT", "DO", "PR", "BM", "TC", "KY") # Caribbean codes
gadm_list <- lapply(caribbean_codes, function(code) {
  tryCatch(
    gadm(country = code, level = 0, path = './maps/base_maps'),  # Save to specified path
    error = function(e) NULL
  )
})
gadm_list <- gadm_list[!sapply(gadm_list, is.null)]
# Combine all downloaded boundaries into a single spatial object
car_map_0 <- do.call(rbind, gadm_list) # Spatvertor of Caribbean Islands

# Great Lakes shape files downloaded from the USGS (https://www.sciencebase.gov/catalog/item/530f8a0ee4b0e7e46bd300dd)
great_lakes <- vect("./maps/great_lakes/combined_great_lakes.shp")
great_lakes <- project(great_lakes, "WGS84")

## Project to Lambert Conformal Conic for pretty maps:

projLam <- "+proj=lcc +lat_1=49 +lat_2=77 +lat_0=49 +lon_0=-95 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

us_map_0.lcc <- project(us_map_0, projLam)
ca_map_0.lcc <- project(ca_map_0, projLam)
mex_map_0.lcc <- project(mex_map_0, projLam)
gl_map_0.lcc <- project(gl_map_0, projLam)
car_map_0.lcc <- project(car_map_0, projLam)
can_us_mex_border.lcc <- project(can_us_mex_border, projLam)
great_lakes.lcc <- project(great_lakes, projLam)



# Load worldclim layer ----------------------------------------------------
wclimNA <- readRDS('./wclim_data/wclim_NA/wclim.Rdata')
rast_template <- wclimNA[1] # grab the first layer of the wclim data as a template for rasterizing the occ vectors


# Load occ data -----------------------------------------------------------
occ_angThin <- readRDS('./occ_data/thinned/occ_angThin.Rdata')
occ_arbThin <- readRDS('./occ_data/thinned/occ_arbThin.Rdata')
occ_borThin <- readRDS('./occ_data/thinned/occ_borThin.Rdata')
occ_cesThin <- readRDS('./occ_data/thinned/occ_cesThin.Rdata')
occ_corThin <- readRDS('./occ_data/thinned/occ_corThin.Rdata')
occ_craThin <- readRDS('./occ_data/thinned/occ_craThin.Rdata')
occ_darThin <- readRDS('./occ_data/thinned/occ_darThin.Rdata')
occ_delThin <- readRDS('./occ_data/thinned/occ_delThin.Rdata')
occ_eryThin <- readRDS('./occ_data/thinned/occ_eryThin.Rdata')
occ_hirThin <- readRDS('./occ_data/thinned/occ_hirThin.Rdata')
occ_macThin <- readRDS('./occ_data/thinned/occ_macThin.Rdata')
occ_memThin <- readRDS('./occ_data/thinned/occ_memThin.Rdata')
occ_mtuThin <- readRDS('./occ_data/thinned/occ_mtuThin.Rdata')
occ_myrThin <- readRDS('./occ_data/thinned/occ_myrThin.Rdata')
occ_mysThin <- readRDS('./occ_data/thinned/occ_mysThin.Rdata')
occ_ovaThin <- readRDS('./occ_data/thinned/occ_ovaThin.Rdata')
occ_ovtThin <- readRDS('./occ_data/thinned/occ_ovtThin.Rdata')
occ_oxyThin <- readRDS('./occ_data/thinned/occ_oxyThin.Rdata')
occ_palThin <- readRDS('./occ_data/thinned/occ_palThin.Rdata')
occ_parThin <- readRDS('./occ_data/thinned/occ_parThin.Rdata')
occ_scoThin <- readRDS('./occ_data/thinned/occ_scoThin.Rdata')
occ_staThin <- readRDS('./occ_data/thinned/occ_staThin.Rdata')
occ_tenThin <- readRDS('./occ_data/thinned/occ_tenThin.Rdata')
occ_uliThin <- readRDS('./occ_data/thinned/occ_uliThin.Rdata')
occ_vidThin <- readRDS('./occ_data/thinned/occ_vidThin.Rdata')
occ_virThin <- readRDS('./occ_data/thinned/occ_virThin.Rdata')


# Prep for plotting -------------------------------------------------------
# Gatheroccurrence SpatVectors in the environment
# (all objects named like occ_*Thin from readRDS calls)
obj_names <- ls(pattern = "^occ_.*Thin$")
occ_list  <- setNames(lapply(obj_names, get), obj_names)

# template: one WorldClim layer at 2.5'
template <- wclimNA[[1]]

# rasterize each species in occ_list
rasters <- lapply(names(occ_list), function(nm) {
  v <- occ_list[[nm]]
  v$one <- 1
  r <- rasterize(v, template, field = "one", fun = "sum", background = NA)
  r <- clamp(r, 0, 1)        # presence/absence
  names(r) <- nm
  r
})

# stack them
stack <- rast(rasters)

# richness map = sum across species
richness <- app(stack, sum, na.rm = TRUE)

# quick plot
plot(can_us_mex_border)
plot(richness, main = "Species richness (occurrence-based, 2.5′)", col = viridis(n=7, option = 'H'), add = T)



