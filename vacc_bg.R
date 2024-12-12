# Top ---------------------------------------------------------------------
# Sample ecoregions to establish background (bg) extent
# Started Nov 20, 2024
library(tidyverse)
library(terra) 
library(predicts)
library(geodata)
library(ENMTools)
library(plotly) # 3D surface Kernel bivariate plots
library(MASS)

# Ecoregion prep ----------------------------------------------------------
# Download NA Ecoregion shapefile from: https://www.epa.gov/eco-research/ecoregions-north-america
# Load shapefile from local files
# Reusing files from Malus SDM

ecoNA <- vect(x = "C:/Users/terre/Documents/Acadia/Malus Project/maps/eco regions/na_cec_eco_l2/", layer = 'NA_CEC_Eco_Level2')
ecoNA <- project(ecoNA, 'WGS84') # project ecoregion vector to same coords ref as basemap

# (Down)Load basemaps -----------------------------------------------------
us_map <- gadm(country = 'USA', level = 1, resolution = 2,
               path = "./maps/base_maps/") #USA basemap w. States

# Load basemaps and wclim data --------------------------------------------
ca_map <- gadm(country = 'CA', level = 1, resolution = 2,
               path = './maps/base_maps/') #Canada basemap w. Provinces

mex_map <-gadm(country = 'MX', level = 1, resolution = 2,
               path = './maps/base_maps/') # Mexico basemap w. States

canUSMex_map <- rbind(us_map, ca_map, mex_map) # Combine Mexico, US and Canada vector map

wclim <- geodata::worldclim_global(var = 'bio', res = 2.5, version = '2.1', path = "./wclim_data/")

# Load occurrence data ----------------------------------------------------
occ_angThin <- readRDS(file = './occ_data/thinned/occ_angThin.Rdata')
occ_arbThin <- readRDS(file = './occ_data/thinned/occ_arbThin.Rdata')

# Extract ecogregions for each spp. ---------------------------------------
# V. angustifolium 
tm <- Sys.time()
eco_ang <- extract(ecoNA, occ_angThin)
eco_ang_code <- eco_ang$NA_L2CODE %>% unique() 
eco_ang_code <- eco_ang_code[!is.na(eco_ang_code) & eco_ang_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_ang <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_ang_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_ang, file = './bg_data/eco_regions/ecoNA_ang.Rdata') # save Ecoregions for downstream

# V. arboreum 
tm <- Sys.time()
eco_arb <- extract(ecoNA, occ_arbThin)
eco_arb_code <- eco_arb$NA_L2CODE %>% unique() 
eco_arb_code <- eco_arb_code[!is.na(eco_arb_code) & eco_arb_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_arb <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_arb_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_arb, file = './bg_data/eco_regions/ecoNA_arb.Rdata') # save Ecoregions for downstream

# V. boreale 
tm <- Sys.time()
eco_bor <- extract(ecoNA, occ_borThin)
eco_bor_code <- eco_bor$NA_L2CODE %>% unique() 
eco_bor_code <- eco_bor_code[!is.na(eco_bor_code) & eco_bor_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_bor <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_bor_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_bor, file = './bg_data/eco_regions/ecoNA_bor.Rdata') # save Ecoregions for downstream

# V. cespitosum 
tm <- Sys.time()
eco_ces <- extract(ecoNA, occ_cesThin)
eco_ces_code <- eco_ces$NA_L2CODE %>% unique() 
eco_ces_code <- eco_ces_code[!is.na(eco_ces_code) & eco_ces_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_ces <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_ces_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_ces, file = './bg_data/eco_regions/ecoNA_ces.Rdata') # save Ecoregions for downstream

# V. corymbosum 
tm <- Sys.time()
eco_cor <- extract(ecoNA, occ_corThin)
eco_cor_code <- eco_cor$NA_L2CODE %>% unique() 
eco_cor_code <- eco_cor_code[!is.na(eco_cor_code) & eco_cor_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_cor <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_cor_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_cor, file = './bg_data/eco_regions/ecoNA_cor.Rdata') # save Ecoregions for downstream

# V. crassifolium 
tm <- Sys.time()
eco_cra <- extract(ecoNA, occ_craThin)
eco_cra_code <- eco_cra$NA_L2CODE %>% unique() 
eco_cra_code <- eco_cra_code[!is.na(eco_cra_code) & eco_cra_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_cra <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_cra_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_cra, file = './bg_data/eco_regions/ecoNA_cra.Rdata') # save Ecoregions for downstream

# V. darrowii 
tm <- Sys.time()
eco_dar <- extract(ecoNA, occ_darThin)
eco_dar_code <- eco_dar$NA_L2CODE %>% unique() 
eco_dar_code <- eco_dar_code[!is.na(eco_dar_code) & eco_dar_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_dar <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_dar_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_dar, file = './bg_data/eco_regions/ecoNA_dar.Rdata') # save Ecoregions for downstream

# V. deliciosum 
tm <- Sys.time()
eco_del <- extract(ecoNA, occ_delThin)
eco_del_code <- eco_del$NA_L2CODE %>% unique() 
eco_del_code <- eco_del_code[!is.na(eco_del_code) & eco_del_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_del <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_del_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_del, file = './bg_data/eco_regions/ecoNA_del.Rdata') # save Ecoregions for downstream

# V. erythrocarpum 
tm <- Sys.time()
eco_ery <- extract(ecoNA, occ_eryThin)
eco_ery_code <- eco_ery$NA_L2CODE %>% unique() 
eco_ery_code <- eco_ery_code[!is.na(eco_ery_code) & eco_ery_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_ery <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_ery_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_ery, file = './bg_data/eco_regions/ecoNA_ery.Rdata') # save Ecoregions for downstream

# V. hirsutum 
tm <- Sys.time()
eco_hir <- extract(ecoNA, occ_hirThin)
eco_hir_code <- eco_hir$NA_L2CODE %>% unique() 
eco_hir_code <- eco_hir_code[!is.na(eco_hir_code) & eco_hir_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_hir <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_hir_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_hir, file = './bg_data/eco_regions/ecoNA_hir.Rdata') # save Ecoregions for downstream

# V. macrocarpon 
tm <- Sys.time()
eco_mac <- extract(ecoNA, occ_macThin)
eco_mac_code <- eco_mac$NA_L2CODE %>% unique() 
eco_mac_code <- eco_mac_code[!is.na(eco_mac_code) & eco_mac_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_mac <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_mac_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_mac, file = './bg_data/eco_regions/ecoNA_mac.Rdata') # save Ecoregions for downstream

# V. membranaceum 
tm <- Sys.time()
eco_mem <- extract(ecoNA, occ_memThin)
eco_mem_code <- eco_mem$NA_L2CODE %>% unique() 
eco_mem_code <- eco_mem_code[!is.na(eco_mem_code) & eco_mem_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_mem <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_mem_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_mem, file = './bg_data/eco_regions/ecoNA_mem.Rdata') # save Ecoregions for downstream

# V. myrsinites 
tm <- Sys.time()
eco_mys <- extract(ecoNA, occ_mysThin)
eco_mys_code <- eco_mys$NA_L2CODE %>% unique() 
eco_mys_code <- eco_mys_code[!is.na(eco_mys_code) & eco_mys_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_mys <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_mys_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_mys, file = './bg_data/eco_regions/ecoNA_mys.Rdata') # save Ecoregions for downstream

# V. myrtilloides 
tm <- Sys.time()
eco_myr <- extract(ecoNA, occ_myrThin)
eco_myr_code <- eco_myr$NA_L2CODE %>% unique() 
eco_myr_code <- eco_myr_code[!is.na(eco_myr_code) & eco_myr_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_myr <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_myr_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_myr, file = './bg_data/eco_regions/ecoNA_myr.Rdata') # save Ecoregions for downstream

# V. myrtillus 
tm <- Sys.time()
eco_mtu <- extract(ecoNA, occ_mtuThin)
eco_mtu_code <- eco_mtu$NA_L2CODE %>% unique() 
eco_mtu_code <- eco_mtu_code[!is.na(eco_mtu_code) & eco_mtu_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_mtu <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_mtu_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_mtu, file = './bg_data/eco_regions/ecoNA_mtu.Rdata') # save Ecoregions for downstream

# V. ovalifolium 
tm <- Sys.time()
eco_ova <- extract(ecoNA, occ_ovaThin)
eco_ova_code <- eco_ova$NA_L2CODE %>% unique() 
eco_ova_code <- eco_ova_code[!is.na(eco_ova_code) & eco_ova_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_ova <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_ova_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_ova, file = './bg_data/eco_regions/ecoNA_ova.Rdata') # save Ecoregions for downstream

#STOPPED HERE
# V. ovatum 
tm <- Sys.time()
eco_ovt <- extract(ecoNA, occ_ovtThin)
eco_ovt_code <- eco_ovt$NA_L2CODE %>% unique() 
eco_ovt_code <- eco_ovt_code[!is.na(eco_ovt_code) & eco_ovt_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_ovt <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_ovt_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_ovt, file = './bg_data/eco_regions/ecoNA_ovt.Rdata') # save Ecoregions for downstream

# V. oxycoccos 
tm <- Sys.time()
eco_oxy <- extract(ecoNA, occ_oxyThin)
eco_oxy_code <- eco_oxy$NA_L2CODE %>% unique() 
eco_oxy_code <- eco_oxy_code[!is.na(eco_oxy_code) & eco_oxy_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_oxy <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_oxy_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_oxy, file = './bg_data/eco_regions/ecoNA_oxy.Rdata') # save Ecoregions for downstream

# V. pallidum 
tm <- Sys.time()
eco_pal <- extract(ecoNA, occ_palThin)
eco_pal_code <- eco_pal$NA_L2CODE %>% unique() 
eco_pal_code <- eco_pal_code[!is.na(eco_pal_code) & eco_pal_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_pal <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_pal_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_pal, file = './bg_data/eco_regions/ecoNA_pal.Rdata') # save Ecoregions for downstream

# V. parvifolium 
tm <- Sys.time()
eco_par <- extract(ecoNA, occ_parThin)
eco_par_code <- eco_par$NA_L2CODE %>% unique() 
eco_par_code <- eco_par_code[!is.na(eco_par_code) & eco_par_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_par <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_par_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_par, file = './bg_data/eco_regions/ecoNA_par.Rdata') # save Ecoregions for downstream

# V. scoparium 
tm <- Sys.time()
eco_sco <- extract(ecoNA, occ_scoThin)
eco_sco_code <- eco_sco$NA_L2CODE %>% unique() 
eco_sco_code <- eco_sco_code[!is.na(eco_sco_code) & eco_sco_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_sco <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_sco_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_sco, file = './bg_data/eco_regions/ecoNA_sco.Rdata') # save Ecoregions for downstream

# V. stamineum 
tm <- Sys.time()
eco_sta <- extract(ecoNA, occ_staThin)
eco_sta_code <- eco_sta$NA_L2CODE %>% unique() 
eco_sta_code <- eco_sta_code[!is.na(eco_sta_code) & eco_sta_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_sta <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_sta_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_sta, file = './bg_data/eco_regions/ecoNA_sta.Rdata') # save Ecoregions for downstream

# V. tenellum 
tm <- Sys.time()
eco_ten <- extract(ecoNA, occ_tenThin)
eco_ten_code <- eco_ten$NA_L2CODE %>% unique() 
eco_ten_code <- eco_ten_code[!is.na(eco_ten_code) & eco_ten_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_ten <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_ten_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_ten, file = './bg_data/eco_regions/ecoNA_ten.Rdata') # save Ecoregions for downstream

# V. virgatum 
tm <- Sys.time()
eco_vir <- extract(ecoNA, occ_virThin)
eco_vir_code <- eco_vir$NA_L2CODE %>% unique() 
eco_vir_code <- eco_vir_code[!is.na(eco_vir_code) & eco_vir_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_vir <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_vir_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_vir, file = './bg_data/eco_regions/ecoNA_vir.Rdata') # save Ecoregions for downstream

# V. vitis-idaea
tm <- Sys.time()
eco_vid <- extract(ecoNA, occ_vidThin)
eco_vid_code <- eco_vid$NA_L2CODE %>% unique() 
eco_vid_code <- eco_vid_code[!is.na(eco_vid_code) & eco_vid_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_vid <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_vid_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_vid, file = './bg_data/eco_regions/ecoNA_vid.Rdata') # save Ecoregions for downstream


# Load Ecoregions ---------------------------------------------------------
ecoNA_ang <- readRDS(file = "./bg_data/eco_regions/ecoNA_ang.Rdata")
ecoNA_arb <- readRDS(file = "./bg_data/eco_regions/ecoNA_arb.Rdata")
ecoNA_bor <- readRDS(file = "./bg_data/eco_regions/ecoNA_bor.Rdata")
ecoNA_ces <- readRDS(file = "./bg_data/eco_regions/ecoNA_ces.Rdata")
ecoNA_cor <- readRDS(file = "./bg_data/eco_regions/ecoNA_cor.Rdata")
ecoNA_cra <- readRDS(file = "./bg_data/eco_regions/ecoNA_cra.Rdata")
ecoNA_dar <- readRDS(file = "./bg_data/eco_regions/ecoNA_dar.Rdata")
ecoNA_del <- readRDS(file = "./bg_data/eco_regions/ecoNA_del.Rdata")
ecoNA_ery <- readRDS(file = "./bg_data/eco_regions/ecoNA_ery.Rdata")
ecoNA_hir <- readRDS(file = "./bg_data/eco_regions/ecoNA_hir.Rdata")
ecoNA_mac <- readRDS(file = "./bg_data/eco_regions/ecoNA_mac.Rdata")
ecoNA_mem <- readRDS(file = "./bg_data/eco_regions/ecoNA_mem.Rdata")
ecoNA_mys <- readRDS(file = "./bg_data/eco_regions/ecoNA_mys.Rdata")
ecoNA_mtu <- readRDS(file = "./bg_data/eco_regions/ecoNA_mtu.Rdata")


# Crop wclim layers to ecoregions -----------------------------------------
# V. angustifolium
wclim_ang <- terra::crop(wclim, ecoNA_ang, mask = T)
saveRDS(wclim_ang, file = './wclim_data/wclim_ang.Rdata')
wclim_arb <- terra::crop(wclim, ecoNA_arb, mask = T)
saveRDS(wclim_arb, file = './wclim_data/wclim_arb.Rdata')

# Sample background points ------------------------------------------------
set.seed(1337) # set a seed to ensure reproducible results

# V. angustifolium
ang_bg_vec <- spatSample(wclim_ang, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ang_bg_vec, file = './bg_data/ang_bg_vec.Rdata')
# plot(wclim_ang[[1]])
# points(ang_bg_vec, cex = 0.01)
arb_bg_vec <- spatSample(wclim_arb, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(arb_bg_vec, file = './bg_data/arb_bg_vec.Rdata')
plot(wclim_arb[[1]])
points(arb_bg_vec, cex = 0.01)
