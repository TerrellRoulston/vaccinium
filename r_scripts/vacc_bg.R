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
occ_borThin <- readRDS(file = './occ_data/thinned/occ_borThin.Rdata')
occ_cesThin <- readRDS(file = './occ_data/thinned/occ_cesThin.Rdata')
occ_corThin <- readRDS(file = './occ_data/thinned/occ_corThin.Rdata')
occ_craThin <- readRDS(file = './occ_data/thinned/occ_craThin.Rdata')
occ_darThin <- readRDS(file = './occ_data/thinned/occ_darThin.Rdata')
occ_delThin <- readRDS(file = './occ_data/thinned/occ_delThin.Rdata')
occ_eryThin <- readRDS(file = './occ_data/thinned/occ_eryThin.Rdata')
occ_hirThin <- readRDS(file = './occ_data/thinned/occ_hirThin.Rdata')
occ_macThin <- readRDS(file = './occ_data/thinned/occ_macThin.Rdata')
occ_memThin <- readRDS(file = './occ_data/thinned/occ_memThin.Rdata')
occ_mysThin <- readRDS(file = './occ_data/thinned/occ_mysThin.Rdata')
occ_myrThin <- readRDS(file = './occ_data/thinned/occ_myrThin.Rdata')
occ_mtuThin <- readRDS(file = './occ_data/thinned/occ_mtuThin.Rdata')
occ_ovaThin <- readRDS(file = './occ_data/thinned/occ_ovaThin.Rdata')
occ_ovtThin <- readRDS(file = './occ_data/thinned/occ_ovtThin.Rdata')
occ_oxyThin <- readRDS(file = './occ_data/thinned/occ_oxyThin.Rdata')
occ_palThin <- readRDS(file = './occ_data/thinned/occ_palThin.Rdata')
occ_parThin <- readRDS(file = './occ_data/thinned/occ_parThin.Rdata')
occ_scoThin <- readRDS(file = './occ_data/thinned/occ_scoThin.Rdata')
occ_staThin <- readRDS(file = './occ_data/thinned/occ_staThin.Rdata')
occ_tenThin <- readRDS(file = './occ_data/thinned/occ_tenThin.Rdata')
occ_uliThin <- readRDS(file = './occ_data/thinned/occ_uliThin.Rdata')
occ_virThin <- readRDS(file = './occ_data/thinned/occ_virThin.Rdata')
occ_vidThin <- readRDS(file = './occ_data/thinned/occ_vidThin.Rdata')

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

# V. uliginosum
tm <- Sys.time()
eco_uli <- extract(ecoNA, occ_uliThin)
eco_uli_code <- eco_uli$NA_L2CODE %>% unique() 
eco_uli_code <- eco_uli_code[!is.na(eco_uli_code) & eco_uli_code != '0.0']  #remove the 'water' '0.0' and NA ecoregions
ecoNA_uli <- terra::subset(ecoNA, ecoNA$NA_L2CODE %in% eco_uli_code) # subset eco region spat vector by the codes
elasped <- (Sys.time() - tm) %>% print()
saveRDS(ecoNA_uli, file = './bg_data/eco_regions/ecoNA_uli.Rdata') # save Ecoregions for downstream

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
ecoNA_arb <- readRDS(file = "./bg_data/eco_regions/ecoNA_arb.Rdata")
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
ecoNA_myr <- readRDS(file = "./bg_data/eco_regions/ecoNA_myr.Rdata")
ecoNA_mtu <- readRDS(file = "./bg_data/eco_regions/ecoNA_mtu.Rdata") 
ecoNA_ova <- readRDS(file = "./bg_data/eco_regions/ecoNA_ova.Rdata") 
ecoNA_ovt <- readRDS(file = "./bg_data/eco_regions/ecoNA_ovt.Rdata")
ecoNA_oxy <- readRDS(file = "./bg_data/eco_regions/ecoNA_oxy.Rdata")
ecoNA_pal <- readRDS(file = "./bg_data/eco_regions/ecoNA_pal.Rdata")
ecoNA_par <- readRDS(file = "./bg_data/eco_regions/ecoNA_par.Rdata")
ecoNA_sco <- readRDS(file = "./bg_data/eco_regions/ecoNA_sco.Rdata")
ecoNA_sta <- readRDS(file = "./bg_data/eco_regions/ecoNA_sta.Rdata")
ecoNA_ten <- readRDS(file = "./bg_data/eco_regions/ecoNA_ten.Rdata")
ecoNA_uli <- readRDS(file = "./bg_data/eco_regions/ecoNA_uli.Rdata")
ecoNA_vir <- readRDS(file = "./bg_data/eco_regions/ecoNA_vir.Rdata")
ecoNA_vid <- readRDS(file = "./bg_data/eco_regions/ecoNA_vid.Rdata")


# Crop wclim layers to ecoregions -----------------------------------------
wclim_ang <- terra::crop(wclim, ecoNA_ang, mask = T)
saveRDS(wclim_ang, file = './wclim_data/wclim_ang.Rdata')
wclim_arb <- terra::crop(wclim, ecoNA_arb, mask = T)
saveRDS(wclim_arb, file = './wclim_data/wclim_arb.Rdata')
wclim_bor <- terra::crop(wclim, ecoNA_bor, mask = T)
saveRDS(wclim_bor, file = './wclim_data/wclim_bor.Rdata')
wclim_ces <- terra::crop(wclim, ecoNA_ces, mask = T)
saveRDS(wclim_ces, file = './wclim_data/wclim_ces.Rdata')
wclim_cor <- terra::crop(wclim, ecoNA_cor, mask = T)
saveRDS(wclim_cor, file = './wclim_data/wclim_cor.Rdata')
wclim_cra <- terra::crop(wclim, ecoNA_cra, mask = T)
saveRDS(wclim_cra, file = './wclim_data/wclim_cra.Rdata')
wclim_dar <- terra::crop(wclim, ecoNA_dar, mask = T)
saveRDS(wclim_dar, file = './wclim_data/wclim_dar.Rdata')
wclim_del <- terra::crop(wclim, ecoNA_del, mask = T)
saveRDS(wclim_del, file = './wclim_data/wclim_del.Rdata')
wclim_ery <- terra::crop(wclim, ecoNA_ery, mask = T)
saveRDS(wclim_ery, file = './wclim_data/wclim_ery.Rdata')
wclim_hir <- terra::crop(wclim, ecoNA_hir, mask = T)
saveRDS(wclim_hir, file = './wclim_data/wclim_hir.Rdata')
wclim_mac <- terra::crop(wclim, ecoNA_mac, mask = T)
saveRDS(wclim_mac, file = './wclim_data/wclim_mac.Rdata')
wclim_mem <- terra::crop(wclim, ecoNA_mem, mask = T)
saveRDS(wclim_mem, file = './wclim_data/wclim_mem.Rdata')
wclim_mys <- terra::crop(wclim, ecoNA_mys, mask = T)
saveRDS(wclim_mys, file = './wclim_data/wclim_mys.Rdata')
wclim_myr <- terra::crop(wclim, ecoNA_myr, mask = T)
saveRDS(wclim_myr, file = './wclim_data/wclim_myr.Rdata')
wclim_mtu <- terra::crop(wclim, ecoNA_mtu, mask = T)
saveRDS(wclim_mtu, file = './wclim_data/wclim_mtu.Rdata')
wclim_ova <- terra::crop(wclim, ecoNA_ova, mask = T)
saveRDS(wclim_ova, file = './wclim_data/wclim_ova.Rdata')
wclim_ovt <- terra::crop(wclim, ecoNA_ovt, mask = T)
saveRDS(wclim_ovt, file = './wclim_data/wclim_ovt.Rdata')
wclim_oxy <- terra::crop(wclim, ecoNA_oxy, mask = T)
saveRDS(wclim_oxy, file = './wclim_data/wclim_oxy.Rdata')
wclim_pal <- terra::crop(wclim, ecoNA_pal, mask = T)
saveRDS(wclim_pal, file = './wclim_data/wclim_pal.Rdata')
wclim_par <- terra::crop(wclim, ecoNA_par, mask = T)
saveRDS(wclim_par, file = './wclim_data/wclim_par.Rdata')
wclim_sco <- terra::crop(wclim, ecoNA_sco, mask = T)
saveRDS(wclim_sco, file = './wclim_data/wclim_sco.Rdata')
wclim_sta <- terra::crop(wclim, ecoNA_sta, mask = T)
saveRDS(wclim_sta, file = './wclim_data/wclim_sta.Rdata')
wclim_ten <- terra::crop(wclim, ecoNA_ten, mask = T)
saveRDS(wclim_ten, file = './wclim_data/wclim_ten.Rdata')
wclim_uli <- terra::crop(wclim, ecoNA_uli, mask = T)
saveRDS(wclim_uli, file = './wclim_data/wclim_uli.Rdata')
wclim_vir <- terra::crop(wclim, ecoNA_vir, mask = T)
saveRDS(wclim_vir, file = './wclim_data/wclim_vir.Rdata')
wclim_vid <- terra::crop(wclim, ecoNA_vid, mask = T)
saveRDS(wclim_vid, file = './wclim_data/wclim_vid.Rdata')
# Sample background points ------------------------------------------------
set.seed(1337) # set a seed to ensure reproducible results

# plot(wclim_ang[[1]])
# points(ang_bg_vec, cex = 0.01)

ang_bg_vec <- spatSample(wclim_ang, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ang_bg_vec, file = './bg_data/ang_bg_vec.Rdata')
arb_bg_vec <- spatSample(wclim_arb, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(arb_bg_vec, file = './bg_data/arb_bg_vec.Rdata')
bor_bg_vec <- spatSample(wclim_bor, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(bor_bg_vec, file = './bg_data/bor_bg_vec.Rdata')
ces_bg_vec <- spatSample(wclim_ces, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ces_bg_vec, file = './bg_data/ces_bg_vec.Rdata')
cor_bg_vec <- spatSample(wclim_cor, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(cor_bg_vec, file = './bg_data/cor_bg_vec.Rdata')
cra_bg_vec <- spatSample(wclim_cra, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(cra_bg_vec, file = './bg_data/cra_bg_vec.Rdata')
dar_bg_vec <- spatSample(wclim_dar, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(dar_bg_vec, file = './bg_data/dar_bg_vec.Rdata')
del_bg_vec <- spatSample(wclim_del, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(del_bg_vec, file = './bg_data/del_bg_vec.Rdata')
ery_bg_vec <- spatSample(wclim_ery, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ery_bg_vec, file = './bg_data/ery_bg_vec.Rdata')
hir_bg_vec <- spatSample(wclim_hir, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(hir_bg_vec, file = './bg_data/hir_bg_vec.Rdata')
mac_bg_vec <- spatSample(wclim_mac, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mac_bg_vec, file = './bg_data/mac_bg_vec.Rdata')
mem_bg_vec <- spatSample(wclim_mem, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mem_bg_vec, file = './bg_data/mem_bg_vec.Rdata')
mys_bg_vec <- spatSample(wclim_mys, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mys_bg_vec, file = './bg_data/mys_bg_vec.Rdata')
myr_bg_vec <- spatSample(wclim_myr, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(myr_bg_vec, file = './bg_data/myr_bg_vec.Rdata')
mtu_bg_vec <- spatSample(wclim_mtu, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mtu_bg_vec, file = './bg_data/mtu_bg_vec.Rdata')
ova_bg_vec <- spatSample(wclim_ova, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ova_bg_vec, file = './bg_data/ova_bg_vec.Rdata')
ovt_bg_vec <- spatSample(wclim_ovt, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ovt_bg_vec, file = './bg_data/ovt_bg_vec.Rdata')
oxy_bg_vec <- spatSample(wclim_oxy, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(oxy_bg_vec, file = './bg_data/oxy_bg_vec.Rdata')
pal_bg_vec <- spatSample(wclim_pal, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(pal_bg_vec, file = './bg_data/pal_bg_vec.Rdata')
par_bg_vec <- spatSample(wclim_par, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(par_bg_vec, file = './bg_data/par_bg_vec.Rdata')
sco_bg_vec <- spatSample(wclim_sco, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(sco_bg_vec, file = './bg_data/sco_bg_vec.Rdata')
sta_bg_vec <- spatSample(wclim_sta, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(sta_bg_vec, file = './bg_data/sta_bg_vec.Rdata')
ten_bg_vec <- spatSample(wclim_ten, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ten_bg_vec, file = './bg_data/ten_bg_vec.Rdata')
uli_bg_vec <- spatSample(wclim_uli, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(uli_bg_vec, file = './bg_data/uli_bg_vec.Rdata')
vir_bg_vec <- spatSample(wclim_vir, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(vir_bg_vec, file = './bg_data/vir_bg_vec.Rdata')
vid_bg_vec <- spatSample(wclim_vid, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(vid_bg_vec, file = './bg_data/vid_bg_vec.Rdata')
