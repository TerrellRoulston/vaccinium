R Script ReadME

The following is a quick description to explain the purpose of each script in this folder

gbif_occ.R # GBIF download for main Vaccinium spp, and old central American spp
gbif_corym_spp.R # GBIF download for the corymbossum complex species, see taxon keys
libraries.R # Load all nessicary lib depandancies, track which libs used (also see libs in scripts)
occ_clean.R # Clean GBIF occurrence data from main Vaccinium spp
occ_clean_corym_spp.R # Clean GBIF occurrence data for corymbosum complex spp
occ_richness_map.R # Exploratory map to show the spp richness in each raster cell of wclim strata
occ_thin.R # Thin the occurrence for all the main Vaccinium spp
occ_thin_corym_spp.R # Thin the occurrence data from corymbosum comlpex spp, note this is a more advanced version than copy and pasta
report_plots.R # WORK IN PROGRESS -- quick script for plotting results of SDMs for report
run_vac_maxent.R # script for remotely running SDMs on HPC for main Vaccinium spp
run_vac_maxent_corym_spp.R # Script for remotely running SDMs on HPC for corymbosum complex spp
sdm_predictions_mask.R # WROK IN PROGRESS -- script for masking SDM predictions to historical ecoregions and adjacent future suitable ecoregions
sdm_stack.R # Script for stacking SDMs to show expected richness for both main vaccinium and corymbosum complex
threshold_calc.R # Script for calculating suitability quantiles for thresholding SDM results
vacc_bg_cec # Script for extracting ecoregion for each spp, generating background points and cropping worldclim data to ecoregion extent
vacc_plot.R # DRAFT -- script for plotting SDM results
wclim_prep_CA_US_MX.R # cropping worldclim data to Canada US and Mexico