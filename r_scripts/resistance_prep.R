# Resistence layer preperation
# Resistance = (1 / suitability) × landcover multiplier
# Landcover layer from CEC https://www.cec.org/north-american-environmental-atlas/land-cover-30m-2020/
# 


# Libraries ---------------------------------------------------------------
library(tidyverse)
library(terra)

# Load in the CEC land classification -------------------------------------

land_cats_30m <- rast("C:/Users/terre/Documents/Acadia/Vaccinium/map_data/land_cover_2020v2_30m_tif/land_cover_2020v2_30m_tif/NA_NALCMS_landcover_2020v2_30m/data/NA_NALCMS_landcover_2020v2_30m.tif")

#dev.off()
#plot(land_cats_30m)
 
?resample 

levels(land_cats_30m)


# Set resistance values (0-100) for land categories  ----------------------
resistance_lookup <- data.frame(
  Value = c(0:19),
  Resistance = c(
    NA,   # 0 = unclassified
    
    2,    # 1 Needleleaf forest
    2,    # 2 Taiga forest
    3,    # 3 Tropical evergreen forest
    3,    # 4 Tropical deciduous forest
    2,    # 5 Temperate deciduous forest
    2,    # 6 Mixed forest
    
    3,    # 7 Tropical shrubland
    1,    # 8 Temperate shrubland
    
    15,   # 9 Tropical grassland
    10,   # 10 Temperate grassland
    
    5,    # 11 Polar shrubland
    10,   # 12 Polar grassland
    50,   # 13 Polar barren
    
    1,    # 14 Wetland
    
    50,   # 15 Cropland
    
    75,   # 16 Barren land
    
    100,  # 17 Urban
    100,   # 18 Water
    100   # 19 Snow and ice
  )
)

# Create matrix with two columns to feed the classifier
rcl <- as.matrix(resistance_lookup[, c("Value", "Resistance")])

resistance_rast <- classify(
  land_cats_30m,
  rcl = rcl
)

writeRaster(resistance_rast, filename = './connectivity_inputs/resistance_classes_rast.tif', overwrite = T)


# Aggregate landscape classes to lower res of clim rast -------------------
# Bc the landscape class is 30m while wclim raster is 2.5 arc mins need to aggregate cells to match
# Going to average the resitstance values...
# Using aggregate with a factor dividing climate/classes

# Import one of the climate rasters

cor2_hist <- readRDS('./sdm_output/sdm_output_feb_10_2026/masked/cor2/cor2_hist_mask.rds')

fact <- round(res(cor2_hist)[1] / res(resistance_rast)[1])

resistance_coarse <- resample(
  resistance_rast,
  method = 'mean',
  na.rm = TRUE
)

same.crs(cor2_hist, resistance_rast) # F

crs(resistance_rast)
