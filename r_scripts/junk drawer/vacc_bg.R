# Top ---------------------------------------------------------------------
# Sample ecoregions to establish background (bg) extent
# Started Nov 20, 2024
library(tidyverse)
library(terra)
library(tidyterra)
library(kgc) # Ecoregions around the world

# Ecoregion prep ----------------------------------------------------------
### Because we are expanding occurrence beyond Canada, US and Mexico I am using a different dataset for ecoregions
### Koppen-Greigger Climate Zones
### Closely mirror the NA ecoregion EPA map actually... might be the same?
### Use kcg package


# Use worldclim as the strata to sample the background area of environments
wclim <- geodata::worldclim_global(var = 'bio', res = 2.5, version = '2.1', path = "./wclim_data/")

# Downloaded KG climate zone raster from this source:
# https://koeppen-geiger.vu-wien.ac.at/present.htm

kg_rast <- terra::rast("./maps/kg_climate/KG_1986-2010.grd") # load raster data

# Need to name the climate regions
# Note: this is much easier to do in terra and the R example on the webpage uses an outdated <raster> pkg workflow
levels(kg_rast) <- data.frame(ID = 1:32,
                              climate = c('Af','Am','As','Aw','BSh','BSk','BWh','BWk',
                                        'Cfa','Cfb','Cfc','Csa','Csb','Csc','Cwa','Cwb','Cwc',
                                        'Dfa','Dfb','Dfc','Dfd','Dsa','Dsb','Dsc','Dsd',
                                        'Dwa','Dwb','Dwc','Dwd','EF','ET','Ocean'))

# Now reproject the map onto the same CRS as the occurrence data
kg_rast <- project(kg_rast, "+proj=longlat +datum=WGS84", method = 'near')

# Load occurrence data ----------------------------------------------------
occ_angThin <- readRDS(file = './occ_data/thinned/occ_angThin.rds')
occ_arbThin <- readRDS(file = './occ_data/thinned/occ_arbThin.rds')
occ_borThin <- readRDS(file = './occ_data/thinned/occ_borThin.rds')
occ_cesThin <- readRDS(file = './occ_data/thinned/occ_cesThin.rds')
occ_corThin <- readRDS(file = './occ_data/thinned/occ_corThin.rds')
occ_craThin <- readRDS(file = './occ_data/thinned/occ_craThin.rds')
occ_darThin <- readRDS(file = './occ_data/thinned/occ_darThin.rds')
occ_delThin <- readRDS(file = './occ_data/thinned/occ_delThin.rds')
occ_eryThin <- readRDS(file = './occ_data/thinned/occ_eryThin.rds')
occ_hirThin <- readRDS(file = './occ_data/thinned/occ_hirThin.rds')
occ_macThin <- readRDS(file = './occ_data/thinned/occ_macThin.rds')
occ_memThin <- readRDS(file = './occ_data/thinned/occ_memThin.rds')
occ_mysThin <- readRDS(file = './occ_data/thinned/occ_mysThin.rds')
occ_myrThin <- readRDS(file = './occ_data/thinned/occ_myrThin.rds')
occ_mtuThin <- readRDS(file = './occ_data/thinned/occ_mtuThin.rds')
occ_ovaThin <- readRDS(file = './occ_data/thinned/occ_ovaThin.rds')
occ_ovtThin <- readRDS(file = './occ_data/thinned/occ_ovtThin.rds')
occ_oxyThin <- readRDS(file = './occ_data/thinned/occ_oxyThin.rds')
occ_palThin <- readRDS(file = './occ_data/thinned/occ_palThin.rds')
occ_parThin <- readRDS(file = './occ_data/thinned/occ_parThin.rds')
occ_scoThin <- readRDS(file = './occ_data/thinned/occ_scoThin.rds')
occ_staThin <- readRDS(file = './occ_data/thinned/occ_staThin.rds')
occ_tenThin <- readRDS(file = './occ_data/thinned/occ_tenThin.rds')
occ_uliThin <- readRDS(file = './occ_data/thinned/occ_uliThin.rds')
# occ_virThin <- readRDS(file = './occ_data/thinned/occ_virThin.rds') # dropped because its included in V. corymbosum
occ_leuThin <- readRDS(file = './occ_data/thinned/occ_leuThin.rds')
occ_conThin <- readRDS(file = './occ_data/thinned/occ_conThin.rds')
occ_steThin <- readRDS(file = './occ_data/thinned/occ_steThin.rds')
occ_shaThin <- readRDS(file = './occ_data/thinned/occ_shaThin.rds')
occ_gemThin <- readRDS(file = './occ_data/thinned/occ_gemThin.rds')
occ_crdThin <- readRDS(file = './occ_data/thinned/occ_crdThin.rds')
occ_cosThin <- readRDS(file = './occ_data/thinned/occ_cosThin.rds')
occ_selThin <- readRDS(file = './occ_data/thinned/occ_selThin.rds')
occ_kunThin <- readRDS(file = './occ_data/thinned/occ_kunThin.rds')

# Chuck them in a list 
# Note I reorder in alphabetical order, compared to earlier scripts
occ_list <- list(
  ang = occ_angThin,
  arb = occ_arbThin,
  bor = occ_borThin,
  ces = occ_cesThin,
  con = occ_conThin,
  cor = occ_corThin,
  cos = occ_cosThin,
  cra = occ_craThin,
  crd = occ_crdThin,
  dar = occ_darThin,
  del = occ_delThin,
  ery = occ_eryThin,
  gem = occ_gemThin,
  hir = occ_hirThin,
  kun = occ_kunThin,
  leu = occ_leuThin,
  mac = occ_macThin,
  mem = occ_memThin,
  mtu = occ_mtuThin,
  myr = occ_myrThin,
  mys = occ_mysThin,
  ova = occ_ovaThin,
  ovt = occ_ovtThin,
  oxy = occ_oxyThin,
  pal = occ_palThin,
  par = occ_parThin,
  sco = occ_scoThin,
  sel = occ_selThin,
  sha = occ_shaThin,
  sta = occ_staThin,
  ste = occ_steThin,
  ten = occ_tenThin,
  uli = occ_uliThin,
  vid = occ_vidThin
)

# Extract coordinates from SpatVectors ------------------------------------
# KG lookup expects df with 3 columns in order: site, long, late
# Using species code as holder for site, will drop...
# Building helper function to take list of occ vectors and convert to df for lookupCZ

make_koppen_input <- function(occ_sv) {
  coords <- terra::crds(occ_sv, df = TRUE) # convert SpatVector to df
  
  coords %>% dplyr::mutate(
      rndCoord.lon = kgc::RoundCoordinates(x), # czlookup expects rounded coordinates
      rndCoord.lat = kgc::RoundCoordinates(y)
    ) %>%
    
    # Keep only Site ID + rounded coordinates
    dplyr::mutate(
      Site = paste0("pt", dplyr::row_number()), .before = rndCoord.lon # add "site IDs" as czlookup expects that in first col, just the number of pts
    ) %>%
    dplyr::select(Site, rndCoord.lon, rndCoord.lat) %>%
    tidyr::drop_na() # drop an NAs
}

# create list of dataframes of species coordiates with 'site' placeholders as the n number of points
# use helper function and occurrence list to create list of coordinates df 
occ_coords <- lapply(occ_list, make_koppen_input)

# Extract KG climate reginos for each spp. --------------------------------

# Start!
# tm <- Sys.time() # Time how long this takes, I think it will be faster than the old workflow because its raster based now
# Took ~ 4 mins! Much much faster

# V. angustifolium 
tm <- Sys.time()
kg_ang <- LookupCZ(occ_coords$ang) # Look up KG climate zones
kg_ang <- as.character(kg_ang) # convert to character, from factor
kg_ang <- unique(kg_ang) # return unique codes
kg_ang <- kg_ang[kg_ang != "Climate Zone info missing"] # drop code for missing info...
mask_ang <- kg_rast$climate %in% kg_ang # subset kg clim categories that contain occurrences to mask wclim data
mask_ang[mask_ang == 0] <- NA # turn 0s into NAs so it behaves as a mask
kg_ang_rast <- terra::mask(kg_rast$climate, mask_ang) # apply mask to climate layer
saveRDS(kg_ang_rast, file = './bg_data/clim_regions/kg_ang_rast.rds') # save climate regions raster for downstream
elasped <- (Sys.time() - tm) %>% print()

# V. arboreum
kg_arb <- LookupCZ(occ_coords$arb)
kg_arb <- as.character(kg_arb)
kg_arb <- unique(kg_arb) 
kg_arb[kg_arb != "Climate Zone info missing"]
saveRDS(kg_arb, file = './bg_data/clim_regions/kg_arb.rds') 

# V. boreale
kg_bor <- LookupCZ(occ_coords$bor)
kg_bor <- as.character(kg_bor)
kg_bor <- unique(kg_bor) 
kg_bor[kg_bor != "Climate Zone info missing"]
saveRDS(kg_bor, file = './bg_data/clim_regions/kg_bor.rds')

# V. cespitosum
kg_ces <- LookupCZ(occ_coords$ces)
kg_ces <- as.character(kg_ces)
kg_ces <- unique(kg_ces) 
kg_ces[kg_ces != "Climate Zone info missing"]
saveRDS(kg_ces, file = './bg_data/clim_regions/kg_ces.rds')

# V. confertum
kg_con <- LookupCZ(occ_coords$con)
kg_con <- as.character(kg_con)
kg_con <- unique(kg_con) 
kg_con[kg_con != "Climate Zone info missing"]
saveRDS(kg_con, file = './bg_data/clim_regions/kg_con.rds')

# V. corymbosum
kg_cor <- LookupCZ(occ_coords$cor)
kg_cor <- as.character(kg_cor)
kg_cor <- unique(kg_cor) 
kg_cor[kg_cor != "Climate Zone info missing"]
saveRDS(kg_cor, file = './bg_data/clim_regions/kg_cor.rds')

# V. consanguineum
kg_cos <- LookupCZ(occ_coords$cos)
kg_cos <- as.character(kg_cos)
kg_cos <- unique(kg_cos) 
kg_cos[kg_cos != "Climate Zone info missing"]
saveRDS(kg_cos, file = './bg_data/clim_regions/kg_cos.rds')

# V. crassifolium
kg_cra <- LookupCZ(occ_coords$cra)
kg_cra <- as.character(kg_cra)
kg_cra <- unique(kg_cra) 
kg_cra[kg_cra != "Climate Zone info missing"]
saveRDS(kg_cra, file = './bg_data/clim_regions/kg_cra.rds')

# V. cordifolium
kg_crd <- LookupCZ(occ_coords$crd)
kg_crd <- as.character(kg_crd)
kg_crd <- unique(kg_crd) 
kg_crd[kg_crd != "Climate Zone info missing"]
saveRDS(kg_crd, file = './bg_data/clim_regions/kg_crd.rds')

# V. darrowii
kg_dar <- LookupCZ(occ_coords$dar)
kg_dar <- as.character(kg_dar)
kg_dar <- unique(kg_dar) 
kg_dar[kg_dar != "Climate Zone info missing"]
saveRDS(kg_dar, file = './bg_data/clim_regions/kg_dar.rds')

# V. deliciosum
kg_del <- LookupCZ(occ_coords$del)
kg_del <- as.character(kg_del)
kg_del <- unique(kg_del) 
kg_del[kg_del != "Climate Zone info missing"]
saveRDS(kg_del, file = './bg_data/clim_regions/kg_del.rds')

# V. erythrocarpum
kg_ery <- LookupCZ(occ_coords$ery)
kg_ery <- as.character(kg_ery)
kg_ery <- unique(kg_ery) 
kg_ery[kg_ery != "Climate Zone info missing"]
saveRDS(kg_ery, file = './bg_data/clim_regions/kg_ery.rds')

# V. geminiflorum
kg_gem <- LookupCZ(occ_coords$gem)
kg_gem <- as.character(kg_gem)
kg_gem <- unique(kg_gem) 
kg_gem[kg_gem != "Climate Zone info missing"]
saveRDS(kg_gem, file = './bg_data/clim_regions/kg_gem.rds')

# V. hirsutum
kg_hir <- LookupCZ(occ_coords$hir)
kg_hir <- as.character(kg_hir)
kg_hir <- unique(kg_hir) 
kg_hir[kg_hir != "Climate Zone info missing"]
saveRDS(kg_hir, file = './bg_data/clim_regions/kg_hir.rds')

# V. kunthianum
kg_kun <- LookupCZ(occ_coords$kun)
kg_kun <- as.character(kg_kun)
kg_kun <- unique(kg_kun) 
kg_kun[kg_kun != "Climate Zone info missing"]
saveRDS(kg_kun, file = './bg_data/clim_regions/kg_kun.rds')

# V. leucanthum
kg_leu <- LookupCZ(occ_coords$leu)
kg_leu <- as.character(kg_leu)
kg_leu <- unique(kg_leu) 
kg_leu[kg_leu != "Climate Zone info missing"]
saveRDS(kg_leu, file = './bg_data/clim_regions/kg_leu.rds')

# V. macrocarpon
kg_mac <- LookupCZ(occ_coords$mac)
kg_mac <- as.character(kg_mac)
kg_mac <- unique(kg_mac) 
kg_mac[kg_mac != "Climate Zone info missing"]
saveRDS(kg_mac, file = './bg_data/clim_regions/kg_mac.rds')

# V. membranaceum
kg_mem <- LookupCZ(occ_coords$mem)
kg_mem <- as.character(kg_mem)
kg_mem <- unique(kg_mem) 
kg_mem[kg_mem != "Climate Zone info missing"]
saveRDS(kg_mem, file = './bg_data/clim_regions/kg_mem.rds')

# V. myrtillus
kg_mtu <- LookupCZ(occ_coords$mtu)
kg_mtu <- as.character(kg_mtu)
kg_mtu <- unique(kg_mtu) 
kg_mtu[kg_mtu != "Climate Zone info missing"]
saveRDS(kg_mtu, file = './bg_data/clim_regions/kg_mtu.rds')

# V. myrtilloides
kg_myr <- LookupCZ(occ_coords$myr)
kg_myr <- as.character(kg_myr)
kg_myr <- unique(kg_myr) 
kg_myr[kg_myr != "Climate Zone info missing"]
saveRDS(kg_myr, file = './bg_data/clim_regions/kg_myr.rds')

# V. myrsinites
kg_mys <- LookupCZ(occ_coords$mys)
kg_mys <- as.character(kg_mys)
kg_mys <- unique(kg_mys) 
kg_mys[kg_mys != "Climate Zone info missing"]
saveRDS(kg_mys, file = './bg_data/clim_regions/kg_mys.rds')

# V. ovalifolium
kg_ova <- LookupCZ(occ_coords$ova)
kg_ova <- as.character(kg_ova)
kg_ova <- unique(kg_ova) 
kg_ova[kg_ova != "Climate Zone info missing"]
saveRDS(kg_ova, file = './bg_data/clim_regions/kg_ova.rds')

# V. ovatum
kg_ovt <- LookupCZ(occ_coords$ovt)
kg_ovt <- as.character(kg_ovt)
kg_ovt <- unique(kg_ovt) 
kg_ovt[kg_ovt != "Climate Zone info missing"]
saveRDS(kg_ovt, file = './bg_data/clim_regions/kg_ovt.rds')

# V. oxycoccos
kg_oxy <- LookupCZ(occ_coords$oxy)
kg_oxy <- as.character(kg_oxy)
kg_oxy <- unique(kg_oxy) 
kg_oxy[kg_oxy != "Climate Zone info missing"]
saveRDS(kg_oxy, file = './bg_data/clim_regions/kg_oxy.rds')

# V. pallidum
kg_pal <- LookupCZ(occ_coords$pal)
kg_pal <- as.character(kg_pal)
kg_pal <- unique(kg_pal) 
kg_pal[kg_pal != "Climate Zone info missing"]
saveRDS(kg_pal, file = './bg_data/clim_regions/kg_pal.rds')

# V. parvifolium
kg_par <- LookupCZ(occ_coords$par)
kg_par <- as.character(kg_par)
kg_par <- unique(kg_par) 
kg_par[kg_par != "Climate Zone info missing"]
saveRDS(kg_par, file = './bg_data/clim_regions/kg_par.rds')

# V. scoparium
kg_sco <- LookupCZ(occ_coords$sco)
kg_sco <- as.character(kg_sco)
kg_sco <- unique(kg_sco) 
kg_sco[kg_sco != "Climate Zone info missing"]
saveRDS(kg_sco, file = './bg_data/clim_regions/kg_sco.rds')

# V. selerianum
kg_sel <- LookupCZ(occ_coords$sel)
kg_sel <- as.character(kg_sel)
kg_sel <- unique(kg_sel) 
kg_sel[kg_sel != "Climate Zone info missing"]
saveRDS(kg_sel, file = './bg_data/clim_regions/kg_sel.rds')

# V. shastense
kg_sha <- LookupCZ(occ_coords$sha)
kg_sha <- as.character(kg_sha)
kg_sha <- unique(kg_sha) 
kg_sha[kg_sha != "Climate Zone info missing"]
saveRDS(kg_sha, file = './bg_data/clim_regions/kg_sha.rds')

# V. stamineum
kg_sta <- LookupCZ(occ_coords$sta)
kg_sta <- as.character(kg_sta)
kg_sta <- unique(kg_sta) 
kg_sta[kg_sta != "Climate Zone info missing"]
saveRDS(kg_sta, file = './bg_data/clim_regions/kg_sta.rds')

# V. stenophyllum
kg_ste <- LookupCZ(occ_coords$ste)
kg_ste <- as.character(kg_ste)
kg_ste <- unique(kg_ste) 
kg_ste[kg_ste != "Climate Zone info missing"]
saveRDS(kg_ste, file = './bg_data/clim_regions/kg_ste.rds')

# V. tenellum
kg_ten <- LookupCZ(occ_coords$ten)
kg_ten <- as.character(kg_ten)
kg_ten <- unique(kg_ten) 
kg_ten[kg_ten != "Climate Zone info missing"]
saveRDS(kg_ten, file = './bg_data/clim_regions/kg_ten.rds')

# V. uliginosum
kg_uli <- LookupCZ(occ_coords$uli)
kg_uli <- as.character(kg_uli)
kg_uli <- unique(kg_uli) 
kg_uli[kg_uli != "Climate Zone info missing"]
saveRDS(kg_uli, file = './bg_data/clim_regions/kg_uli.rds')

# V. vitis-idaea
kg_vid <- LookupCZ(occ_coords$vid)
kg_vid <- as.character(kg_vid)
kg_vid <- unique(kg_vid) 
kg_vid[kg_vid != "Climate Zone info missing"]
saveRDS(kg_vid, file = './bg_data/clim_regions/kg_vid.rds')

# elasped <- (Sys.time() - tm) %>% print()

# Load Ecoregions ---------------------------------------------------------
# Only run if needing to reload the climate region codes
# kg_ang <- readRDS("./bg_data/clim_regions/kg_ang.rds")
# kg_arb <- readRDS("./bg_data/clim_regions/kg_arb.rds")
# kg_bor <- readRDS("./bg_data/clim_regions/kg_bor.rds")
# kg_ces <- readRDS("./bg_data/clim_regions/kg_ces.rds")
# kg_con <- readRDS("./bg_data/clim_regions/kg_con.rds")
# kg_cor <- readRDS("./bg_data/clim_regions/kg_cor.rds")
# kg_cos <- readRDS("./bg_data/clim_regions/kg_cos.rds")
# kg_cra <- readRDS("./bg_data/clim_regions/kg_cra.rds")
# kg_crd <- readRDS("./bg_data/clim_regions/kg_crd.rds")
# kg_dar <- readRDS("./bg_data/clim_regions/kg_dar.rds")
# kg_del <- readRDS("./bg_data/clim_regions/kg_del.rds")
# kg_ery <- readRDS("./bg_data/clim_regions/kg_ery.rds")
# kg_gem <- readRDS("./bg_data/clim_regions/kg_gem.rds")
# kg_hir <- readRDS("./bg_data/clim_regions/kg_hir.rds")
# kg_kun <- readRDS("./bg_data/clim_regions/kg_kun.rds")
# kg_leu <- readRDS("./bg_data/clim_regions/kg_leu.rds")
# kg_mac <- readRDS("./bg_data/clim_regions/kg_mac.rds")
# kg_mem <- readRDS("./bg_data/clim_regions/kg_mem.rds")
# kg_mtu <- readRDS("./bg_data/clim_regions/kg_mtu.rds")
# kg_myr <- readRDS("./bg_data/clim_regions/kg_myr.rds")
# kg_mys <- readRDS("./bg_data/clim_regions/kg_mys.rds")
# kg_ova <- readRDS("./bg_data/clim_regions/kg_ova.rds")
# kg_ovt <- readRDS("./bg_data/clim_regions/kg_ovt.rds")
# kg_oxy <- readRDS("./bg_data/clim_regions/kg_oxy.rds")
# kg_pal <- readRDS("./bg_data/clim_regions/kg_pal.rds")
# kg_par <- readRDS("./bg_data/clim_regions/kg_par.rds")
# kg_sco <- readRDS("./bg_data/clim_regions/kg_sco.rds")
# kg_sel <- readRDS("./bg_data/clim_regions/kg_sel.rds")
# kg_sha <- readRDS("./bg_data/clim_regions/kg_sha.rds")
# kg_sta <- readRDS("./bg_data/clim_regions/kg_sta.rds")
# kg_ste <- readRDS("./bg_data/clim_regions/kg_ste.rds")
# kg_ten <- readRDS("./bg_data/clim_regions/kg_ten.rds")
# kg_uli <- readRDS("./bg_data/clim_regions/kg_uli.rds")
# kg_vid <- readRDS("./bg_data/clim_regions/kg_vid.rds")


# Crop wclim layers to ecoregions -----------------------------------------
wclim_ang <- terra::crop(wclim, ecoNA_ang, mask = T)
saveRDS(wclim_ang, file = './wclim_data/wclim_ang.rds')
wclim_arb <- terra::crop(wclim, ecoNA_arb, mask = T)
saveRDS(wclim_arb, file = './wclim_data/wclim_arb.rds')
wclim_bor <- terra::crop(wclim, ecoNA_bor, mask = T)
saveRDS(wclim_bor, file = './wclim_data/wclim_bor.rds')
wclim_ces <- terra::crop(wclim, ecoNA_ces, mask = T)
saveRDS(wclim_ces, file = './wclim_data/wclim_ces.rds')
wclim_cor <- terra::crop(wclim, ecoNA_cor, mask = T)
saveRDS(wclim_cor, file = './wclim_data/wclim_cor.rds')
wclim_cra <- terra::crop(wclim, ecoNA_cra, mask = T)
saveRDS(wclim_cra, file = './wclim_data/wclim_cra.rds')
wclim_dar <- terra::crop(wclim, ecoNA_dar, mask = T)
saveRDS(wclim_dar, file = './wclim_data/wclim_dar.rds')
wclim_del <- terra::crop(wclim, ecoNA_del, mask = T)
saveRDS(wclim_del, file = './wclim_data/wclim_del.rds')
wclim_ery <- terra::crop(wclim, ecoNA_ery, mask = T)
saveRDS(wclim_ery, file = './wclim_data/wclim_ery.rds')
wclim_hir <- terra::crop(wclim, ecoNA_hir, mask = T)
saveRDS(wclim_hir, file = './wclim_data/wclim_hir.rds')
wclim_mac <- terra::crop(wclim, ecoNA_mac, mask = T)
saveRDS(wclim_mac, file = './wclim_data/wclim_mac.rds')
wclim_mem <- terra::crop(wclim, ecoNA_mem, mask = T)
saveRDS(wclim_mem, file = './wclim_data/wclim_mem.rds')
wclim_mys <- terra::crop(wclim, ecoNA_mys, mask = T)
saveRDS(wclim_mys, file = './wclim_data/wclim_mys.rds')
wclim_myr <- terra::crop(wclim, ecoNA_myr, mask = T)
saveRDS(wclim_myr, file = './wclim_data/wclim_myr.rds')
wclim_mtu <- terra::crop(wclim, ecoNA_mtu, mask = T)
saveRDS(wclim_mtu, file = './wclim_data/wclim_mtu.rds')
wclim_ova <- terra::crop(wclim, ecoNA_ova, mask = T)
saveRDS(wclim_ova, file = './wclim_data/wclim_ova.rds')
wclim_ovt <- terra::crop(wclim, ecoNA_ovt, mask = T)
saveRDS(wclim_ovt, file = './wclim_data/wclim_ovt.rds')
wclim_oxy <- terra::crop(wclim, ecoNA_oxy, mask = T)
saveRDS(wclim_oxy, file = './wclim_data/wclim_oxy.rds')
wclim_pal <- terra::crop(wclim, ecoNA_pal, mask = T)
saveRDS(wclim_pal, file = './wclim_data/wclim_pal.rds')
wclim_par <- terra::crop(wclim, ecoNA_par, mask = T)
saveRDS(wclim_par, file = './wclim_data/wclim_par.rds')
wclim_sco <- terra::crop(wclim, ecoNA_sco, mask = T)
saveRDS(wclim_sco, file = './wclim_data/wclim_sco.rds')
wclim_sta <- terra::crop(wclim, ecoNA_sta, mask = T)
saveRDS(wclim_sta, file = './wclim_data/wclim_sta.rds')
wclim_ten <- terra::crop(wclim, ecoNA_ten, mask = T)
saveRDS(wclim_ten, file = './wclim_data/wclim_ten.rds')
wclim_uli <- terra::crop(wclim, ecoNA_uli, mask = T)
saveRDS(wclim_uli, file = './wclim_data/wclim_uli.rds')
wclim_vir <- terra::crop(wclim, ecoNA_vir, mask = T)
saveRDS(wclim_vir, file = './wclim_data/wclim_vir.rds')
wclim_vid <- terra::crop(wclim, ecoNA_vid, mask = T)
saveRDS(wclim_vid, file = './wclim_data/wclim_vid.rds')
# Sample background points ------------------------------------------------
set.seed(1337) # set a seed to ensure reproducible results

# plot(wclim_ang[[1]])
# points(ang_bg_vec, cex = 0.01)

ang_bg_vec <- spatSample(wclim_ang, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ang_bg_vec, file = './bg_data/ang_bg_vec.rds')
arb_bg_vec <- spatSample(wclim_arb, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(arb_bg_vec, file = './bg_data/arb_bg_vec.rds')
bor_bg_vec <- spatSample(wclim_bor, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(bor_bg_vec, file = './bg_data/bor_bg_vec.rds')
ces_bg_vec <- spatSample(wclim_ces, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ces_bg_vec, file = './bg_data/ces_bg_vec.rds')
cor_bg_vec <- spatSample(wclim_cor, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(cor_bg_vec, file = './bg_data/cor_bg_vec.rds')
cra_bg_vec <- spatSample(wclim_cra, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(cra_bg_vec, file = './bg_data/cra_bg_vec.rds')
dar_bg_vec <- spatSample(wclim_dar, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(dar_bg_vec, file = './bg_data/dar_bg_vec.rds')
del_bg_vec <- spatSample(wclim_del, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(del_bg_vec, file = './bg_data/del_bg_vec.rds')
ery_bg_vec <- spatSample(wclim_ery, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ery_bg_vec, file = './bg_data/ery_bg_vec.rds')
hir_bg_vec <- spatSample(wclim_hir, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(hir_bg_vec, file = './bg_data/hir_bg_vec.rds')
mac_bg_vec <- spatSample(wclim_mac, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mac_bg_vec, file = './bg_data/mac_bg_vec.rds')
mem_bg_vec <- spatSample(wclim_mem, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mem_bg_vec, file = './bg_data/mem_bg_vec.rds')
mys_bg_vec <- spatSample(wclim_mys, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mys_bg_vec, file = './bg_data/mys_bg_vec.rds')
myr_bg_vec <- spatSample(wclim_myr, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(myr_bg_vec, file = './bg_data/myr_bg_vec.rds')
mtu_bg_vec <- spatSample(wclim_mtu, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(mtu_bg_vec, file = './bg_data/mtu_bg_vec.rds')
ova_bg_vec <- spatSample(wclim_ova, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ova_bg_vec, file = './bg_data/ova_bg_vec.rds')
ovt_bg_vec <- spatSample(wclim_ovt, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ovt_bg_vec, file = './bg_data/ovt_bg_vec.rds')
oxy_bg_vec <- spatSample(wclim_oxy, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(oxy_bg_vec, file = './bg_data/oxy_bg_vec.rds')
pal_bg_vec <- spatSample(wclim_pal, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(pal_bg_vec, file = './bg_data/pal_bg_vec.rds')
par_bg_vec <- spatSample(wclim_par, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(par_bg_vec, file = './bg_data/par_bg_vec.rds')
sco_bg_vec <- spatSample(wclim_sco, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(sco_bg_vec, file = './bg_data/sco_bg_vec.rds')
sta_bg_vec <- spatSample(wclim_sta, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(sta_bg_vec, file = './bg_data/sta_bg_vec.rds')
ten_bg_vec <- spatSample(wclim_ten, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(ten_bg_vec, file = './bg_data/ten_bg_vec.rds')
uli_bg_vec <- spatSample(wclim_uli, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(uli_bg_vec, file = './bg_data/uli_bg_vec.rds')
vir_bg_vec <- spatSample(wclim_vir, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(vir_bg_vec, file = './bg_data/vir_bg_vec.rds')
vid_bg_vec <- spatSample(wclim_vid, 10000, 'random', na.rm = T, as.points = T) #ignore NA values
saveRDS(vid_bg_vec, file = './bg_data/vid_bg_vec.rds')
