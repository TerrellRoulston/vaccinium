# Top ---------------------------------------------------------------------
# Downloading GBIF data for North American Vaccinum species
library(tidyverse) # data management, grammar
library(rgbif) # access GBIF data


## The following is needed only the first time the data is downloaded from GBIF. 
## Make sure to save the created object


# FUNCTIONS ------------------------------------------------------
# This is functionality added by Thomas to speed up GBIF downloads.
# I personally think although not as sexy its better to keep them seperate because this creates a list of dataframes and I rather objects remain seperate (because lists of objects hurt my brain)
# I keep his functions here as future functionality that could be implemented in the pipeline.

#In general, this series of functions will build up to do the following
#Take a dataframe of taxons and associated keys
#Download their data from gbiff, put that data in named sub directories and create a 4xn dataframe with it all

#The first 4 fctns act as building blocks for comprehensive download and file mgmt

#The 5th calls these building blocks and creates a list with all important data for one species

#The 6th then maps this to every species in a dataframe



#Create a new sub directory
#Return relative path to that subDir
# create_and_return_path <- function(newSubDir) {
#   
#   dir.create(file.path('./occ_data', newSubDir)) #file.path() allows you to specify relative paths no matter OS
#   
#   paste0('./occ_data/', newSubDir) %>% 
#     return()
# }
# 
# 
# #Send a request to download data of specified taxon
# #Return a unique code associated with that download request
# request_gbif_occ_download <- function(taxonKey, basisOfRecord, countryCodes) {
#   
#   occ_download(
#     pred("taxonKey", taxonKey),
#     pred_in("basisOfRecord", basisOfRecord),
#     pred("hasCoordinate", TRUE),
#     pred_in("country", countryCodes),
#     format = "SIMPLE_CSV", #I noticed you downloaded as DWCA in this analysis, adjust as needed
#     user = gbif_credentials$user, 
#     pwd = gbif_credentials$pwd, 
#     email = gbif_credentials$email
#   ) 
#   #returns: downCode
# }
# 
# 
# #Take unique downCode and a directory, then, after waiting for prep, download then extract all files to that dir
# wait_execute_extract_gbif_occ_download <- function(downCode, newDir) {
#   
#   occ_download_wait(downCode[1]) 
#   
#   occ_download_get(downCode[1], path = newDir, overwrite = TRUE) %>% 
#     occ_download_import(downCode[1], path = newDir)
#   #returns: tibble of occ data
# }
# 
# 
# #Call all above functions
# #Create a relative path, request a download, then execute that download
# comprehensive_gbif_occ_download <- function(taxonKey, epithet, basisOfRecord, countryCodes) {
#   
#   newDirPath <- create_and_return_path(epithet)
#   
#   downCode <- taxonKey %>% 
#     request_gbif_occ_download(basisOfRecord, countryCodes)
#   
#   occDf <-   
#     wait_execute_extract_gbif_occ_download(downCode, newDirPath)
#   
#   list(
#     occDf = occDf,
#     downCode = downCode
#   )
# }
# 
# 
# #Perform a comprehensive download, create a list of important related info
# download_and_collect_receipts <- function(taxonKey, epithet, basisOfRecord, countryCodes) {
#   download <- comprehensive_gbif_occ_download(taxonKey, epithet, basisOfRecord, countryCodes)
#   
#   list(
#     epithet = epithet,
#     taxonKey = taxonKey,
#     gbiffOcc = download$occDf,
#     downCode = download$downCode
#   )
# }
# 
# #Take a bunch of taxons, download them all
# #Function takes a dataframe of n species and keys, then, for each one, performs a comprehensive download
# #taxonKeys should be a n by 2 dataframe
# # taxonKeys[1] = str: epithet
# # taxonKeys[2] = int: gbiff taxon key
# map_gbif_download_to_taxon_key_df <- function(taxonKeys, basisOfRecord, countryCodes) {
#   
#   taxonKeys %>% 
#     pmap(\(epithet, taxonKey, downCodes) { #for every epithet and key in the dataframe
#       download_and_collect_receipts(taxonKey, epithet, basisOfRecord, countryCodes)  #download record, create list, associate with downCode 
#     })
#   #returns: list of receipt lists
# }
# 
# #clean up data produced by above map function
# list_of_lists_to_df <- function(df) {
#   df %>% 
#     enframe(name = "row_id") %>% 
#     unnest_wider(value) %>%
#     select(-row_id)
# }


#still need 2 more functions:

#export_all_taxons_to_global_env()
  #take created dataframe of all species, create per sepcies object names, put occ dfs in global env

#import_taxons()
  #take previously downloaded data, bring it into df

# GBIF user info
# user='REDACTED'
# pwd='REDACTED'
# email='REDACTED'

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

# SCRIPT ------------------------------------------------------------------
source("./r_scripts/gbif_login.R")
##The above script is in .gitignore for ease of development
##It contains only the below code
#   user ='REDACTED',
#   pwd ='REDACTED',
#   email ='REDACTED'


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
download_ang <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_ang <- occ_download_import(download_ang) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ang, file = './occ_data/raw/occ_ang.csv') # save the download file under a clean new name
file.remove(download_ang) # delete the old ugly-named GBIF file

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
download_cor <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_cor <- occ_download_import(download_cor) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_cor, file = './occ_data/raw/occ_cor.csv') # save the download file under a clean new name
file.remove(download_cor) # delete the old ugly-named GBIF file

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
download_myr <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
df_myr <- occ_download_import(download_myr) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_myr, file = './occ_data/raw/occ_myr.csv') # save the download file under a clean new name
file.remove(download_myr) # delete the old ugly-named GBIF file

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
df_pal <- occ_download_import(download_pal) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_pal, file = './occ_data/raw/occ_pal.csv') # save the download file under a clean new name
file.remove(download_pal) # delete the old ugly-named GBIF file

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
df_hir <- occ_download_import(download_hir) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_hir, file = './occ_data/raw/occ_hir.csv') # save the download file under a clean new name
file.remove(download_hir) # delete the old ugly-named GBIF file

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
df_dar <- occ_download_import(download_dar) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_dar, file = './occ_data/raw/occ_dar.csv') # save the download file under a clean new name
file.remove(download_dar) # delete the old ugly-named GBIF file

# V. virgatum download ----------------------------------------------------
# NOTE THAT IS ACTUALLY TREATED AS AS SYN OF CORYMBOSSUM IN FNA vol 9
# GBIF aslo treats as synonum. 
# I am keeping code here, and occurrence files but will not model seperatetly...
# Sticking to accepted taxonomy...
# taxonKey <- 2882884
# basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
# hasCoordinates <- TRUE # limit to records with coordinates
# country_codes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico
# 
# # Download data
# down_code = occ_download(
#   pred("taxonKey", taxonKey),
#   pred_in("basisOfRecord", basisOfRecord),
#   pred("hasCoordinate", hasCoordinates),
#   pred_in("country", country_codes),
#   format = "DWCA",
#   user=user, pwd=pwd, email=email)
# 
# # Wait for download to finish
# occ_download_wait(down_code)
# download_vir <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/')
# df_vir <- occ_download_import(download_vir) #import the download, which is actually a tsv and now csv as indicated...
# write.csv(df_vir, file = './occ_data/raw/occ_vir.csv') # save the download file under a clean new name
# file.remove(download_vir) # delete the old ugly-named GBIF file

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
df_ten <- occ_download_import(download_ten) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ten, file = './occ_data/raw/occ_ten.csv') # save the download file under a clean new name
file.remove(download_ten) # delete the old ugly-named GBIF file

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
df_mys <- occ_download_import(download_mys) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_mys, file = './occ_data/raw/occ_mys.csv') # save the download file under a clean new name
file.remove(download_mys) # delete the old ugly-named GBIF file

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
df_bor <- occ_download_import(download_bor) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_bor, file = './occ_data/raw/occ_bor.csv') # save the download file under a clean new name
file.remove(download_bor) # delete the old ugly-named GBIF file

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
df_mac <- occ_download_import(download_mac) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_mac, file = './occ_data/raw/occ_mac.csv') # save the download file under a clean new name
file.remove(download_mac) # delete the old ugly-named GBIF file

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
df_oxy <- occ_download_import(download_oxy) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_oxy, file = './occ_data/raw/occ_oxy.csv') # save the download file under a clean new name
file.remove(download_oxy) # delete the old ugly-named GBIF file

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
df_ces <- occ_download_import(download_ces) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ces, file = './occ_data/raw/occ_ces.csv') # save the download file under a clean new name
file.remove(download_ces) # delete the old ugly-named GBIF file

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
df_mem <- occ_download_import(download_mem) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_mem, file = './occ_data/raw/occ_mem.csv') # save the download file under a clean new name
file.remove(download_mem) # delete the old ugly-named GBIF file

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
df_del <- occ_download_import(download_del) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_del, file = './occ_data/raw/occ_del.csv') # save the download file under a clean new name
file.remove(download_del) # delete the old ugly-named GBIF file

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
df_mtu <- occ_download_import(download_mtu) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_mtu, file = './occ_data/raw/occ_mtu.csv') # save the download file under a clean new name
file.remove(download_mtu) # delete the old ugly-named GBIF file

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
df_par <- occ_download_import(download_par) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_par, file = './occ_data/raw/occ_par.csv') # save the download file under a clean new name
file.remove(download_par) # delete the old ugly-named GBIF file

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
df_ova <- occ_download_import(download_ova) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ova, file = './occ_data/raw/occ_ova.csv') # save the download file under a clean new name
file.remove(download_ova) # delete the old ugly-named GBIF file

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
df_sco <- occ_download_import(download_sco) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_sco, file = './occ_data/raw/occ_sco.csv') # save the download file under a clean new name
file.remove(download_sco) # delete the old ugly-named GBIF file

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
df_uli <- occ_download_import(download_uli) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_uli, file = './occ_data/raw/occ_uli.csv') # save the download file under a clean new name
file.remove(download_uli) # delete the old ugly-named GBIF file

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
df_sta <- occ_download_import(download_sta) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_sta, file = './occ_data/raw/occ_sta.csv') # save the download file under a clean new name
file.remove(download_sta) # delete the old ugly-named GBIF file

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
df_ovt <- occ_download_import(download_ovt) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ovt, file = './occ_data/raw/occ_ovt.csv') # save the download file under a clean new name
file.remove(download_ovt) # delete the old ugly-named GBIF file

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
df_arb <- occ_download_import(download_arb) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_arb, file = './occ_data/raw/occ_arb.csv') # save the download file under a clean new name
file.remove(download_arb) # delete the old ugly-named GBIF file

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
df_cra <- occ_download_import(download_cra) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_cra, file = './occ_data/raw/occ_cra.csv') # save the download file under a clean new name
file.remove(download_cra) # delete the old ugly-named GBIF file

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
df_ery <- occ_download_import(download_ery) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ery, file = './occ_data/raw/occ_ery.csv') # save the download file under a clean new name
file.remove(download_ery) # delete the old ugly-named GBIF file

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
df_vid <- occ_download_import(download_vid) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_vid, file = './occ_data/raw/occ_vid.csv') # save the download file under a clean new name
file.remove(download_vid) # delete the old ugly-named GBIF file

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



