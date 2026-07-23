# Script for filtering occurrences at by counties
library(tidyverse)
library(terra)
library(tidyterra)
library(tigris) 


lu_counties <- tigris::list_counties(state = c("LOUISIANA"))
lu_counties_shp <- tigris::counties(state = c("LOUISIANA"))
subset_lu <- c("Lincoln Parish" , "Washington Parish")

lu_counties_shp_subset <-  lu_counties_shp %>% dplyr::filter(NAMELSAD %in% subset_lu)                                  

vi_counties <- tigris::list_counties(state = c("VIRGINIA"))
