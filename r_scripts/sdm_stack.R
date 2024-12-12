# Quick notes for stacking SDMs
# Compute individual SDM for each species

# Reference:
# Calabrese, J. M., Certain, G., Kraan, C., & Dormann, C. F. (2014). 
#Stacking species distribution models and adjusting bias by linking them to macroecological models. 
#Global Ecology and Biogeography, 23(1), 99–112. https://doi.org/10.1111/geb.12102

# Example parameters
set.seed(123)  # For reproducibility
J <- 100       # Number of sites (10x10 grid assumed)
K <- 20        # Number of species

# Simulate occurrence probabilities for each species at each site
P <- matrix(runif(J * K, min = 0, max = 1), nrow = J, ncol = K)
colnames(P) <- paste0("Species_", 1:K)
rownames(P) <- paste0("Site_", 1:J)

# Expected species richness (sum of probabilities for each site)
expected_richness <- rowSums(P)

# Variance of species richness at each site
richness_variance <- rowSums(P * (1 - P))

# Combine results into a data frame
richness_results <- data.frame(
  Site = rownames(P),
  Expected_Richness = expected_richness,
  Variance = richness_variance
)

# Reshape the expected richness and variance into 10x10 matrices
richness_matrix <- matrix(expected_richness, nrow = 10, ncol = 10, byrow = TRUE)
variance_matrix <- matrix(richness_variance, nrow = 10, ncol = 10, byrow = TRUE)

library(raster)

# Create empty raster templates for expected richness and variance
richness_raster <- raster(nrows = 10, ncols = 10, xmn = 0, xmx = 10, ymn = 0, ymx = 10)
variance_raster <- raster(nrows = 10, ncols = 10, xmn = 0, xmx = 10, ymn = 0, ymx = 10)

# Assign values from matrices to raster objects
values(richness_raster) <- as.vector(richness_matrix)
values(variance_raster) <- as.vector(variance_matrix)

# Set CRS (optional, can set to any relevant CRS, e.g., WGS84)
crs(richness_raster) <- "+proj=longlat +datum=WGS84"
crs(variance_raster) <- "+proj=longlat +datum=WGS84"

# Plot the expected species richness raster
plot(richness_raster, main = "Expected Species Richness")

# Plot the variance of species richness raster
plot(variance_raster, main = "Variance of Species Richness")

# NOTE THESE WOULD BE REPLACED BY PROBABILIY VALUES FROM SDMs

# Something like this?
# Assuming you have a list of rasters, each representing a species' occurrence probability
species_rasters <- list(species1_raster, species2_raster, ..., speciesK_raster)

# Stack all species rasters into a single raster stack
raster_stack <- stack(species_rasters)

# Sum across all layers to get expected species richness per cell
expected_richness <- calc(raster_stack, sum)

# Plot the expected species richness map
plot(expected_richness, main = "Expected Species Richness Across North America")