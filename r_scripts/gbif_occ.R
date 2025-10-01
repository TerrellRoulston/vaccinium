# Top ---------------------------------------------------------------------
# Downloading GBIF data for North American Vaccinum species
library(tidyverse) # data management, grammar
library(rgbif) # access GBIF data


## The following is needed only the first time the data is downloaded from GBIF. 
## Make sure to save the created object


# FUNCTIONS ------------------------------------------------------

#In general, this series of functions will build up to do the following
#Take a dataframe of taxons and associated keys
#Download their data from gbiff, put that data in named sub directories and create a 4xn dataframe with it all

#The first 4 fctns act as building blocks for comprehensive download and file mgmt

#The 5th calls these building blocks and creates a list with all important data for one species

#The 6th then maps this to every species in a dataframe



#Create a new sub directory
#Return relative path to that subDir
create_and_return_path <- function(newSubDir) {
  
  dir.create(file.path('./occ_data', newSubDir)) #file.path() allows you to specify relative paths no matter OS
  
  paste0('./occ_data/', newSubDir) %>% 
    return()
}


#Send a request to download data of specified taxon
#Return a unique code associated with that download request
request_gbif_occ_download <- function(taxonKey, basisOfRecord, countryCodes) {
  
  occ_download(
    pred("taxonKey", taxonKey),
    pred_in("basisOfRecord", basisOfRecord),
    pred("hasCoordinate", TRUE),
    pred_in("country", countryCodes),
    format = "SIMPLE_CSV", #I noticed you downloaded as DWCA in this analysis, adjust as needed
    user = gbif_credentials$user, 
    pwd = gbif_credentials$pwd, 
    email = gbif_credentials$email
  ) 
  #returns: downCode
}


#Take unique downCode and a directory, then, after waiting for prep, download then extract all files to that dir
wait_execute_extract_gbif_occ_download <- function(downCode, newDir) {
  
  occ_download_wait(downCode[1]) 
  
  occ_download_get(downCode[1], path = newDir, overwrite = TRUE) %>% 
    occ_download_import(downCode[1], path = newDir)
  #returns: tibble of occ data
}


#Call all above functions
#Create a relative path, request a download, then execute that download
comprehensive_gbif_occ_download <- function(taxonKey, epithet, basisOfRecord, countryCodes) {
  
  newDirPath <- create_and_return_path(epithet)
  
  downCode <- taxonKey %>% 
    request_gbif_occ_download(basisOfRecord, countryCodes)
  
  occDf <-   
    wait_execute_extract_gbif_occ_download(downCode, newDirPath)
  
  list(
    occDf = occDf,
    downCode = downCode
  )
}


#Perform a comprehensive download, create a list of important related info
download_and_collect_receipts <- function(taxonKey, epithet, basisOfRecord, countryCodes) {
  download <- comprehensive_gbif_occ_download(taxonKey, epithet, basisOfRecord, countryCodes)
  
  list(
    epithet = epithet,
    taxonKey = taxonKey,
    gbiffOcc = download$occDf,
    downCode = download$downCode
  )
}

#Take a bunch of taxons, download them all
#Function takes a dataframe of n species and keys, then, for each one, performs a comprehensive download
#taxonKeys should be a n by 2 dataframe
# taxonKeys[1] = str: epithet
# taxonKeys[2] = int: gbiff taxon key
map_gbif_download_to_taxon_key_df <- function(taxonKeys, basisOfRecord, countryCodes) {
  
  taxonKeys %>% 
    pmap(\(epithet, taxonKey, downCodes) { #for every epithet and key in the dataframe
      download_and_collect_receipts(taxonKey, epithet, basisOfRecord, countryCodes)  #download record, create list, associate with downCode 
    })
  #returns: list of receipt lists
}

#clean up data produced by above map function
list_of_lists_to_df <- function(df) {
  df %>% 
    enframe(name = "row_id") %>% 
    unnest_wider(value) %>%
    select(-row_id)
}


#still need 2 more functions:

#export_all_taxons_to_global_env()
  #take created dataframe of all species, create per sepcies object names, put occ dfs in global env

#import_taxons()
  #take previously downloaded data, bring it into df


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

# SCRIPT ------------------------------------------------------------------
#Ensure relative working directory is ./vaccinium

source("scripts/gbif_login.R")
##The above script is in .gitignore for ease of development
##It contains only the below code
##Instantiate the gbif_credentials list as you see fit

# gbif_credentials <- list(
#   user ='REDACTED',
#   pwd ='REDACTED',
#   email ='REDACTED'
# )


basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN')
countryCodes <- c("CA", "US", "MX") # limit to Canada, USA and Mexico

taxonKeys <- 
  tribble(
    ~epithet, ~taxonKey,
    'ang', 2882868,
    '...'
  )

OccDataList <- taxonKeys %>%
  map_gbif_download_to_taxon_key_df(basisOfRecord, countryCodes)

OccDataDF <- OccDataList %>% 
  list_of_lists_to_df()



