# Top ---------------------------------------------------------------------
# Downloading GBIF data for North American Vaccinum species
library(tidyverse) # data management, grammar
library(rgbif) # access GBIF data

getwd()

# Download occurrence data from GBIF

# GBIF user info
user='REDACTED'
pwd='REDACTED'
email='REDACTED'

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
# SPECIES ADDED LATER (from south of US)
# Vaccinium leucanthum 4171440
# Vaccinium confertum 7328893
# Vaccinium stenophyllum 4167742
# Vaccinium shastense 7936270 (California endemic)
# Vaccinium geminiflorum 2882930
# Vaccinium cordifolium 4174484
# Vaccinium consanguineum 7328886
# Vaccinium selerianum 4168278
# Vaccinium kunthianum 4171763


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
# ADDED
# leucanthum - leu
# confertum - con
# stenophyllum - ste
# shastense - sha
# geminiflorum - gem
# cordifolium - crd
# consanguineum - cos
# selerianum - sel
# kunthianum - kun

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



setwd("../occ_data/raw/") # set wd to a location where you want to save the csv file.
download_ang <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/', path = './occ_data/raw/')

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

download_cor <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/', path = './occ_data/raw/')

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

download_myr <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/', path = './occ_data/raw/')

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



download_pal <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_hir <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')


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



download_dar <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')


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



download_vir <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_ten <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_mys <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_bor <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_mac <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_oxy <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_ces <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_mem <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_del <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_mtu <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_par <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_ova <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_sco <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_uli <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_sta <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_ovt <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_arb <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_cra <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_ery <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

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



download_vid <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')

# V. leucanthum download --------------------------------------------------
taxonKey <- 4171440
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_leu <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_leu <- occ_download_import(download_leu) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_leu, file = './occ_data/raw/occ_leu.csv') # save the download file under a clean new name
file.remove(download_leu) # delete the old ugly-named GBIF file
# V. confertum download --------------------------------------------------
taxonKey <- 7328893
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_con <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_con <- occ_download_import(download_con) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_con, file = './occ_data/raw/occ_con.csv') # save the download file under a clean new name
file.remove(download_con) # delete the old ugly-named GBIF file
# V. stenophyllum download ------------------------------------------------
taxonKey <- 4167742
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_ste <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_ste <- occ_download_import(download_ste) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ste, file = './occ_data/raw/occ_ste.csv') # save the download file under a clean new name
file.remove(download_ste) # delete the old ugly-named GBIF file
# V. shastense download ---------------------------------------------------
taxonKey <- 7936270
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_sha <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_sha <- occ_download_import(download_sha) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_sha, file = './occ_data/raw/occ_sha.csv') # save the download file under a clean new name
file.remove(download_sha) # delete the old ugly-named GBIF file
# V. geminiflorum download ------------------------------------------------
taxonKey <- 2882930
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_gem <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_gem <- occ_download_import(download_gem) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_gem, file = './occ_data/raw/occ_gem.csv') # save the download file under a clean new name
file.remove(download_gem) # delete the old ugly-named GBIF file
# V. cordifolium download -------------------------------------------------
taxonKey <- 4174484
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_crd <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_crd <- occ_download_import(download_crd) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_crd, file = './occ_data/raw/occ_crd.csv') # save the download file under a clean new name
file.remove(download_crd) # delete the old ugly-named GBIF file
# V. consanguineum download -----------------------------------------------
taxonKey <- 7328886
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_cos <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_cos <- occ_download_import(download_cos) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_cos, file = './occ_data/raw/occ_cos.csv') # save the download file under a clean new name
file.remove(download_cos) # delete the old ugly-named GBIF file
# V. selerianum download --------------------------------------------------
taxonKey <- 4168278
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_sel <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_sel <- occ_download_import(download_sel) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_sel, file = './occ_data/raw/occ_sel.csv') # save the download file under a clean new name
file.remove(download_sel) # delete the old ugly-named GBIF file
# V. kunthianum download --------------------------------------------------
taxonKey <- 4171763
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA","US","MX","GT","HN","SV","NI","CR","PA") # limit to Canada, USA and Mexico and other Mesoamerica countries

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
download_kun <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_kun <- occ_download_import(download_kun) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_kun, file = './occ_data/raw/occ_kun.csv') # save the download file under a clean new name
file.remove(download_kun) # delete the old ugly-named GBIF file




