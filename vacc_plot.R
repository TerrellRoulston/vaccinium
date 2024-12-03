# Top ---------------------------------------------------------------------
# Plotting results of MaxEnt SDM results
# Terrell Roulston
# Started Nov 20, 2024

library(tidyverse) # Grammar and data management
library(terra) # Spatial Data package


# Load occurence data and maps --------------------------------------------
occ_angThin <- readRDS(file = './occ_data/thinned/occ_angThin.Rdata') # V. angustifolium
occ_angPankajThin <- readRDS(file = './occ_data/thinned/occ_angPankajThin.Rdata')

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


# Load habitat predictions and thresholds ---------------------------------
# V. angustifolium
# Predictions
ang_pred_hist <- readRDS(file = './sdm_output/ang_pred_hist.Rdata')
ang_pred_ssp245_30 <- readRDS(file = './sdm_output/ang_pred_ssp245_30.Rdata')
ang_pred_ssp245_50 <- readRDS(file = './sdm_output/ang_pred_ssp245_50.Rdata')
ang_pred_ssp245_70 <- readRDS(file = './sdm_output/ang_pred_ssp245_70.Rdata')
ang_pred_ssp585_30 <- readRDS(file = './sdm_output/ang_pred_ssp585_30.Rdata')
ang_pred_ssp585_50 <- readRDS(file = './sdm_output/ang_pred_ssp585_50.Rdata')
ang_pred_ssp585_70 <- readRDS(file = './sdm_output/ang_pred_ssp585_70.Rdata')
# Thresholds
angPred_threshold_1 <- readRDS(file = './sdm_output/thresholds/angPred_threshold_1.Rdata')
angPred_threshold_10 <- readRDS(file = './sdm_output/thresholds/angPred_threshold_10.Rdata')
angPred_threshold_50 <- readRDS(file = './sdm_output/thresholds/angPred_threshold_50.Rdata')

# V. angustifolium with Pankaj
# Predictions
angPankaj_pred_hist <- readRDS(file = './sdm_output/angPankaj_pred_hist.Rdata')
angPankaj_pred_ssp245_30 <- readRDS(file = './sdm_output/angPankaj_pred_ssp245_30.Rdata')
angPankaj_pred_ssp245_50 <- readRDS(file = './sdm_output/angPankaj_pred_ssp245_50.Rdata')
angPankaj_pred_ssp245_70 <- readRDS(file = './sdm_output/angPankaj_pred_ssp245_70.Rdata')
angPankaj_pred_ssp585_30 <- readRDS(file = './sdm_output/angPankaj_pred_ssp585_30.Rdata')
angPankaj_pred_ssp585_50 <- readRDS(file = './sdm_output/angPankaj_pred_ssp585_50.Rdata')
angPankaj_pred_ssp585_70 <- readRDS(file = './sdm_output/angPankaj_pred_ssp585_70.Rdata')
# Thresholds
angPankajPred_threshold_1 <- readRDS(file = './sdm_output/thresholds/angPankajPred_threshold_1.Rdata')
angPankajPred_threshold_10 <- readRDS(file = './sdm_output/thresholds/angPankajPred_threshold_10.Rdata')
angPankajPred_threshold_50 <- readRDS(file = './sdm_output/thresholds/angPankajPred_threshold_50.Rdata')


# Project to Lambert Conformal Conic --------------------------------------
projLam <- "+proj=lcc +lat_1=49 +lat_2=77 +lat_0=49 +lon_0=-95 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"
# Great lakes
great_lakes.lcc <- project(great_lakes, projLam)

# Can/US border
can_us_border.lcc <- project(can_us_border, projLam)

# Occurrences
occ_angThin.lcc <- project(occ_angThin, projLam)
occ_angPankajThin.lcc <- project(occ_angPankajThin, projLam)

# Predictions
# V. angustifolium
ang_pred_hist.lcc <- project(ang_pred_hist, projLam)
ang_pred_ssp245_30.lcc <- project(ang_pred_ssp245_30, projLam)
ang_pred_ssp245_50.lcc <- project(ang_pred_ssp245_50, projLam)
ang_pred_ssp245_70.lcc <- project(ang_pred_ssp245_70, projLam)
ang_pred_ssp585_30.lcc <- project(ang_pred_ssp585_30, projLam)
ang_pred_ssp585_50.lcc <- project(ang_pred_ssp585_50, projLam)
ang_pred_ssp585_70.lcc <- project(ang_pred_ssp585_70, projLam)

# V. angustifolium with Pankej
angPankaj_pred_hist.lcc <- project(angPankaj_pred_hist, projLam)
angPankaj_pred_ssp245_30.lcc <- project(angPankaj_pred_ssp245_30, projLam)
angPankaj_pred_ssp245_50.lcc <- project(angPankaj_pred_ssp245_50, projLam)
angPankaj_pred_ssp245_70.lcc <- project(angPankaj_pred_ssp245_70, projLam)
angPankaj_pred_ssp585_30.lcc <- project(angPankaj_pred_ssp585_30, projLam)
angPankaj_pred_ssp585_50.lcc <- project(angPankaj_pred_ssp585_50, projLam)
angPankaj_pred_ssp585_70.lcc <- project(angPankaj_pred_ssp585_70, projLam)


# Plotting prep -----------------------------------------------------------
legend_labs <- c('Low Suitability', 'Moderate Suitability', 'High Suitability')
fill_cols <- c("#FFF7BC", "#FEC44F", "#D95F0E")
point_cols <- c('black', 'red')
point_labs <- c('GBIF', 'P. Bhowmik Collection')

# Plot a legend that can be saved on its own
plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
legend('top', horiz = T, xpd = NA, title = c(as.expression(bquote(bold('Habitat Suitability')))), legend = legend_labs, fill = fill_cols, cex = 3)
legend('bottom', horiz = T, xpd = NA, title = c(as.expression(bquote(bold('Occurrence Collection')))), legend = point_labs, col = point_cols, cex = 3,  pch = 16)


# V. angustifolium Plotting -----------------------------------------------
ang.xlim <- c(-1*10^6, 3.1*10^6)
ang.ylim <- c(-2*10^6, 2*10^6)

# Plot species occurrences
terra::plot(ang_pred_hist.lcc , col = c('#E8E8E8', '#E8E8E8'),
            background = 'lightskyblue1',
            legend = F, 
            xlim = ang.xlim, ylim = ang.ylim, 
            main = "V. angustifolium Occurrences",
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(can_us_border.lcc, add = T)
terra::points(occThin_ang.lcc)

# Plot historical distribtion 
terra::plot(ang_pred_hist.lcc > angPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'),
            background = 'lightskyblue1',
            legend = F, 
            xlim = ang.xlim, ylim = ang.ylim, 
            main = NULL,
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(1, 1, 1, 1))
terra::plot(ang_pred_hist.lcc > angPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(ang_pred_hist.lcc > angPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black', cex = 1.25)


# SSP245
# 2030

terra::plot(ang_pred_ssp245_30.lcc > angPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',
            xlim = ang.xlim, ylim = ang.ylim, 
            main = '2030',
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(ang_pred_ssp245_30.lcc > angPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(ang_pred_ssp245_30.lcc > angPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)

# 2050

terra::plot(ang_pred_ssp245_50.lcc > angPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',
            xlim = ang.xlim, ylim = ang.ylim, 
            main = '2050',
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(ang_pred_ssp245_50.lcc > angPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(ang_pred_ssp245_50.lcc > angPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)

# 2070

terra::plot(ang_pred_ssp245_70.lcc > angPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',
            xlim = ang.xlim, ylim = ang.ylim, 
            main = '2070',
            cex.main = 3,
            axes= F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(ang_pred_ssp245_70.lcc > angPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(ang_pred_ssp245_70.lcc > angPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)

#SSP 585
# 2030

terra::plot(ang_pred_ssp585_30.lcc > angPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',             
            xlim = ang.xlim, ylim = ang.ylim, 
            main = NULL,
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(1, 1, 1, 1))
terra::plot(ang_pred_ssp585_30.lcc > angPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(ang_pred_ssp585_30.lcc > angPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black', cex = 1.25)


# 2050

terra::plot(ang_pred_ssp585_50.lcc > angPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',             
            xlim = ang.xlim, ylim = ang.ylim, 
            main = '2050',
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(ang_pred_ssp585_50.lcc > angPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(ang_pred_ssp585_50.lcc > angPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)

# 2070

terra::plot(ang_pred_ssp585_70.lcc > angPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',             
            xlim = ang.xlim, ylim = ang.ylim, 
            main = NULL,
            cex.main = 3,
            axes= F,
            box = T,
            mar = c(1, 1, 1, 1))
terra::plot(ang_pred_ssp585_70.lcc > angPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(ang_pred_ssp585_70.lcc > angPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black', cex = 1.25)


# V. angustifolium Plotting with PB data ----------------------------------
angPankaj.xlim <- c(-1*10^6, 3.1*10^6)
angPankaj.ylim <- c(-2*10^6, 2*10^6)

# Plot species occurrences
terra::plot(angPankaj_pred_hist.lcc , col = c('#E8E8E8', '#E8E8E8'),
            background = 'lightskyblue1',
            legend = F, 
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = "V. angustifolium with Pankaj Occurrences",
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black', cex = 3)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'pankaj'), col = 'red', cex = 3)


# Plot historical distribtion 
terra::plot(angPankaj_pred_hist.lcc > angPankajPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'),
            background = 'lightskyblue1',
            legend = F, 
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = NULL,
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(1, 1, 1, 1))
terra::plot(angPankaj_pred_hist.lcc > angPankajPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(angPankaj_pred_hist.lcc > angPankajPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black', cex = 1.25)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'pankaj'), col = 'red', cex = 1.25)


# SSP245
# 2030

terra::plot(angPankaj_pred_ssp245_30.lcc > angPankajPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = '2030',
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(angPankaj_pred_ssp245_30.lcc > angPankajPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(angPankaj_pred_ssp245_30.lcc > angPankajPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)

# 2050

terra::plot(angPankaj_pred_ssp245_50.lcc > angPankajPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = '2050',
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(angPankaj_pred_ssp245_50.lcc > angPankajPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(angPankaj_pred_ssp245_50.lcc > angPankajPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black')
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'pankaj'), col = 'blue')


# 2070

terra::plot(angPankaj_pred_ssp245_70.lcc > angPankajPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = '2070',
            cex.main = 3,
            axes= F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(angPankaj_pred_ssp245_70.lcc > angPankajPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(angPankaj_pred_ssp245_70.lcc > angPankajPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)

# 2030

terra::plot(angPankaj_pred_ssp585_30.lcc > angPankajPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',             
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = NULL,
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(1, 1, 1, 1))
terra::plot(angPankaj_pred_ssp585_30.lcc > angPankajPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(angPankaj_pred_ssp585_30.lcc > angPankajPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black', cex = 1.25)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'pankaj'), col = 'red', cex = 1.25)

# 2050

terra::plot(angPankaj_pred_ssp585_50.lcc > angPankajPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',             
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = '2050',
            cex.main = 3,
            axes = F,
            box = T,
            mar = c(5, 5, 5, 5))
terra::plot(angPankaj_pred_ssp585_50.lcc > angPankajPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(angPankaj_pred_ssp585_50.lcc > angPankajPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)

# 2070

terra::plot(angPankaj_pred_ssp585_70.lcc > angPankajPred_threshold_1, col = c('#E8E8E8', '#FFF7BC'), legend = F, 
            background = 'lightskyblue1',             
            xlim = angPankaj.xlim, ylim = angPankaj.ylim, 
            main = NULL,
            cex.main = 3,
            axes= F,
            box = T,
            mar = c(1, 1, 1, 1))
terra::plot(angPankaj_pred_ssp585_70.lcc > angPankajPred_threshold_10, col = c(NA, '#FEC44F'), add = T, legend = F)
terra::plot(angPankaj_pred_ssp585_70.lcc > angPankajPred_threshold_50, col = c(NA, '#D95F0E'), add = T, legend = F)
terra::plot(can_us_border.lcc, add = T)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'gbif'), col = 'black', cex = 1.25)
terra::points(subset(occ_angPankajThin.lcc, occ_angPankajThin.lcc$source == 'pankaj'), col = 'red', cex = 1.25)


