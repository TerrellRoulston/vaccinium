# Top ---------------------------------------------------------------------
# Downloading GBIF data for North American Vaccinum species
library(tidyverse) # data management, grammar
library(rgbif) # access GBIF data

getwd()

# Download occurrence data from GBIF

# GBIF user info
user='terrell_roulston'
pwd='Malus123!'
email='terrellroulston@gmail.com'

# Taxon IDs ---------------------------------------------------------------
# Vaccinium angustifolium	2882868
# Vaccinium corymbosum	2882849, 4174438 (Vaccinium corymbodendron), 2882837 (Vaccinium caesariense)
# Vaccinium myrtilloides	2882880
# Vaccinium pallidum	2882895, 8032646 (Vaccinium vacillans)
# Vaccinium hirsutum	2882824
# Vaccinium darrowii	2882908
# Vaccinium virgatum	2882884
# Vaccinium tenellum	2882847
# Vaccinium myrsinites	2882937
# Vaccinium boreale	8147903
# Vaccinium macrocarpon	2882841
# Vaccinium oxycoccos	2882940, 8344892 (Vaccinium microcarpum)
# Vaccinium cespitosum	2882861
# Vaccinium membranaceum Douglas ex Torr.,  Vaccinium membranaceum Douglas ex Hook.	2882875, 9060377
# Vaccinium deliciosum	2882961
# Vaccinium myrtillus	2882833
# Vaccinium parvifolium	2882910
# Vaccinium ovalifolium	2882894
# Vaccinium scoparium	8383191
# Vaccinium uliginosum	8073364, 4172817 (Vaccinium gaultheriodes)
# Vaccinium stamineum	2882913
# Vaccinium ovatum	2882838
# Vaccinium arboreum	2882828
# Vaccinium crassifolium	2882960
# Vaccinium erythrocarpum	2882844
# Vaccinium vitis-idaea	2882835

# Species abbreviations ---------------------------------------------------
# angustifolium - ang
# corymbosum - cor
# myrtilloides - myr
# pallidum - pal
# hirsutum - hir
# darrowii - dar
# virgatum - vir
# tenellum - ten
# myrsinites - mys
# boreale - bor
# macrocarpon - mac
# oxycoccos - oxy
# cespitosum - ces
# membranaceum - mem
# deliciosum - del
# myrtillus - mtu
# parvifolium - par
# ovalifolium - ova
# scoparium - sco
# uliginosum - uli
# stamineum - sta
# ovatum - ovt
# arboreum - arb
# crassifolium - cra
# erythrocarpum - ery
# vitis-idaea - vid

# V. angustifolium download -----------------------------------------------
taxonKey <- 2882868
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
# Use 'pred()' if there is a single argument, or 'pred_in()' if there are multiple
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)


getwd() # check your working directory (wd)
setwd("../occ_data/raw/") # set wd to a location where you want to save the csv file.
download_ang <- occ_download_get(down_code[1], overwrite = TRUE)

# V. corymbosum download --------------------------------------------------
taxonKey <- c(2882849, 4174438, 2882837) # note: includes Vaccinium corymbodendron and Vaccinium caesariense
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates 
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_cor <- occ_download_get(down_code[1], overwrite = TRUE)

# V. myrtilloides download ------------------------------------------------
taxonKey <- 2882880
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_myr <- occ_download_get(down_code[1], overwrite = TRUE)

# V. pallidum download ----------------------------------------------------
taxonKey <- c(2882895, 8032646) # note: includes Vaccinium vacillans
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_pal <- occ_download_get(down_code[1], overwrite = TRUE)

# V. hirsutum download ----------------------------------------------------
taxonKey <- 2882824
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_hir <- occ_download_get(down_code[1], overwrite = TRUE)


# V. darrowii download ----------------------------------------------------
taxonKey <- 2882908
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_dar <- occ_download_get(down_code[1], overwrite = TRUE)


# V. virgatum download ----------------------------------------------------
taxonKey <- 2882884
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_vir <- occ_download_get(down_code[1], overwrite = TRUE)

# V. tenellum download ----------------------------------------------------
taxonKey <- 2882847
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_ten <- occ_download_get(down_code[1], overwrite = TRUE)

# V. myrsinites download --------------------------------------------------
taxonKey <- 2882937
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_mys <- occ_download_get(down_code[1], overwrite = TRUE)

# V. boreale download -----------------------------------------------------
taxonKey <- 8147903
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_bor <- occ_download_get(down_code[1], overwrite = TRUE)

# V. macrocarpon download -------------------------------------------------
taxonKey <- 2882841
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_mac <- occ_download_get(down_code[1], overwrite = TRUE)

# V. oxycoccos download ---------------------------------------------------
taxonKey <- c(2882940, 8344892) # Note: includes Vaccinium microcarpum
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_oxy <- occ_download_get(down_code[1], overwrite = TRUE)

# V. cespitosum download --------------------------------------------------
taxonKey <- 2882861
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_ces <- occ_download_get(down_code[1], overwrite = TRUE)

# V. membranaceum download ------------------------------------------------
taxonKey <- c(2882875, 9060377) # Note: includes Vaccinium microcarpum
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_mem <- occ_download_get(down_code[1], overwrite = TRUE)

# V. deliciosum download --------------------------------------------------
taxonKey <- 2882961
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_del <- occ_download_get(down_code[1], overwrite = TRUE)

# V. myrtillus download ---------------------------------------------------
taxonKey <- 2882833
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_mtu <- occ_download_get(down_code[1], overwrite = TRUE)

# V. parvifolium download -------------------------------------------------
taxonKey <- 2882910
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_par <- occ_download_get(down_code[1], overwrite = TRUE)

# V. ovalifolium download -------------------------------------------------
taxonKey <- 2882894
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_ova <- occ_download_get(down_code[1], overwrite = TRUE)

# V. scoparium download ---------------------------------------------------
taxonKey <- 8383191
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_sco <- occ_download_get(down_code[1], overwrite = TRUE)

# V. uliginosum download --------------------------------------------------
taxonKey <- c(8073364, 4172817) #Note: includes Vaccinium gaultheriodes
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_uli <- occ_download_get(down_code[1], overwrite = TRUE)

# V. stamineum download ---------------------------------------------------
taxonKey <- 2882913
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_sta <- occ_download_get(down_code[1], overwrite = TRUE)

# V. ovatum download ------------------------------------------------------
taxonKey <- 2882838
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_ovt <- occ_download_get(down_code[1], overwrite = TRUE)

# V. arboreum download ----------------------------------------------------
taxonKey <- 2882828
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_arb <- occ_download_get(down_code[1], overwrite = TRUE)

# V. crassifolium download ------------------------------------------------
taxonKey <- 2882960
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_cra <- occ_download_get(down_code[1], overwrite = TRUE)

# V. erythrocarpum download -----------------------------------------------
taxonKey <- 2882844
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_ery <- occ_download_get(down_code[1], overwrite = TRUE)

# V. vitis-idaea download -------------------------------------------------
taxonKey <- 2882835
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

# Download data
down_code = occ_download(
  pred("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)

getwd() # check your working directory (wd)
setwd("./occ_data/raw/") # set wd to a location where you want to save the csv file.
download_vid <- occ_download_get(down_code[1], overwrite = TRUE)




