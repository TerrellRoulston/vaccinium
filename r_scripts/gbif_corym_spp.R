# Top ---------------------------------------------------------------------
# Terrell Roulston
# February 4th, 2026
# This script is for downloading and visualizing occurrence data of operational taxons < Vaccinium corymbosum
# Some of the species or subspecies in the V. corybosum complex are currently treated as V corymbosum on GBIF
# but are still accessible using unique taxon keys
# The challenge is that many of the occurrences listed as V. corymbosum following Vander Kloet 1980, 1988 
# means that these operational taxons are lost within that grouped occurrence data

# Libraries
library(tidyverse) # data management, grammar
library(rgbif) # access GBIF data

# GBIF creditionals
source("./r_scripts/gbif_login.R")
##The above script is in .gitignore for ease of development
##It contains only the below code
#   user ='REDACTED',
#   pwd ='REDACTED',
#   email ='REDACTED'

# Subspecies --------------------------------------------------------------
# I am going to download V. corymbosum again, but alone as the taxon, I added two other taxa to the previous downloaded
# cor2 - Vaccinium corymbosum - 2882849
# cot - Vaccinium constablaei - 2882854
# ash - Vaccinium ashei - 2882888
# vir - Vaccinium virgatum (syn. Vaccinium amoenum) - 2882884, 2882890
# ell - Vaccinium elliottii - 2882911
# for - Vaccinium formosum (syn. Vaccinium australe) - 2882935, 2882936
# cae - Vaccinium caesariense - 2882837
# sim - Vaccinium simulatum - 2882962
# fus - Vaccinium fuscatum (syn. Vaccinium arkansanum, Vaccinium atrococcum) - 2882965, 2882966, 2882967


# Vaccinium corymbosum download -------------------------------------------
taxonKey <- 2882849
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

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
download_cor2 <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_cor2 <- occ_download_import(download_cor2) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_cor2, file = './occ_data/raw/corym_sub/occ_cor2.csv') # save the download file under a clean new name
file.remove(download_cor2) # delete the old ugly-named GBIF file

# Vaccinium constablaei download ------------------------------------------
taxonKey <- 2882854
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

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
download_cot <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_cot <- occ_download_import(download_cot) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_cot, file = './occ_data/raw/corym_sub/occ_cot.csv') # save the download file under a clean new name
file.remove(download_cot) # delete the old ugly-named GBIF file

# Vaccinium ashei download ------------------------------------------------
taxonKey <- 2882888
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

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
download_ash <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_ash <- occ_download_import(download_ash) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ash, file = './occ_data/raw/corym_sub/occ_ash.csv') # save the download file under a clean new name
file.remove(download_ash) # delete the old ugly-named GBIF file

# Vaccinium virgatum download ---------------------------------------------
taxonKey <- c(2882884, 2882890) # note: includes Vaccinium amoenum
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

# Download data
# # Use 'pred()' if there is a single argument, or 'pred_in()' if there are multiple
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)
download_vir <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_vir <- occ_download_import(download_vir) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_vir, file = './occ_data/raw/corym_sub/occ_vir.csv') # save the download file under a clean new name
file.remove(download_vir) # delete the old ugly-named GBIF file

# Vaccinium elliottii download --------------------------------------------
taxonKey <- 2882911
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

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
download_ell <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_ell <- occ_download_import(download_ell) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_ell, file = './occ_data/raw/corym_sub/occ_ell.csv') # save the download file under a clean new name
file.remove(download_ell) # delete the old ugly-named GBIF file


# Vaccinium formosum download ---------------------------------------------
taxonKey <- c(2882935, 2882936) # note: includes Vaccinium australe
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

# Download data
# # Use 'pred()' if there is a single argument, or 'pred_in()' if there are multiple
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)
download_for <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_for <- occ_download_import(download_for) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_for, file = './occ_data/raw/corym_sub/occ_for.csv') # save the download file under a clean new name
file.remove(download_for) # delete the old ugly-named GBIF file

# Vaccinium caesariense download ------------------------------------------
taxonKey <- 2882837
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

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
download_cae <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_cae <- occ_download_import(download_cae) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_cae, file = './occ_data/raw/corym_sub/occ_cae.csv') # save the download file under a clean new name
file.remove(download_cae) # delete the old ugly-named GBIF file

# Vaccinium simulatum download --------------------------------------------
taxonKey <- 2882962
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

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
download_sim <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_sim <- occ_download_import(download_sim) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_sim, file = './occ_data/raw/corym_sub/occ_sim.csv') # save the download file under a clean new name
file.remove(download_sim) # delete the old ugly-named GBIF file

# Vaccinium fuscatum download ---------------------------------------------
taxonKey <- c(2882965, 2882966, 2882967) # note: includes Vaccinium arkansanum, Vaccinium atrococcum
basisOfRecord <- c('PRESERVED_SPECIMEN', 'HUMAN_OBSERVATION', 'OCCURRENCE', 'MATERIAL_SAMPLE', 'LIVING_SPECIMEN') 
hasCoordinates <- TRUE # limit to records with coordinates
country_codes <- c("CA", "US") # limit to Canada and USA

# Download data
# # Use 'pred()' if there is a single argument, or 'pred_in()' if there are multiple
down_code = occ_download(
  pred_in("taxonKey", taxonKey),
  pred_in("basisOfRecord", basisOfRecord),
  pred("hasCoordinate", hasCoordinates),
  pred_in("country", country_codes),
  format = "DWCA",
  user=user, pwd=pwd, email=email)

# Wait for download to finish
occ_download_wait(down_code)
download_fus <- occ_download_get(down_code[1], overwrite = TRUE, path = './occ_data/raw/corym_sub/')
df_fus <- occ_download_import(download_fus) #import the download, which is actually a tsv and now csv as indicated...
write.csv(df_fus, file = './occ_data/raw/corym_sub/occ_fus.csv') # save the download file under a clean new name
file.remove(download_fus) # delete the old ugly-named GBIF file
