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


# Import suitability rasters ----------------------------------------------
sp_codes <- c(
  "ang", "cor", "myr", "pal", "hir", "dar", "vir", "ten", "mys", "bor",
  "mac", "oxy", "ces", "mem", "del", "mtu", "par", "ova", "sco", "uli",
  "sta", "arb", "cra", "ery", "vid"
)

# make a file path to read each species as its code
pred_files <- file.path(
  "sdm_output", "sdm_results",
  sp_codes,
  paste0(sp_codes, "_pred_hist.RDS")
)
names(pred_files) <- sp_codes  # so we can keep track


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
spp_rasters <- lapply(pred_files, read_pred_raster)


# Stack rasters! ----------------------------------------------------------

# Create a SpatRaster stack
spp_stack <- rast(spp_rasters)
names(spp_stack) <- names(spp_rasters)  # ang, cor, ...

# Expected richness (Calabrese Eq. 2: sum of probabilities)
richness_mean <- app(spp_stack, fun = sum, na.rm = TRUE)

# Optional: variance of richness (Calabrese Eq. 3: Σ p(1–p))
richness_var <- app(
  spp_stack,
  fun = function(x) sum(x * (1 - x), na.rm = TRUE)
)

rich_zero_na <- ifel(richness_mean < 1e-6, NA, richness_mean)

pal <- hcl.colors(10, "Viridis")

png(file = "./visualizations/vaccinium_richness_hist.png", width = 1600, height = 2000, res = 300)

plot(rich_zero_na,
     col = pal,
     main = "Expected Vaccinium richness (historical)",
     colNA = "white")   # NA cells plotted as white
dev.off()


