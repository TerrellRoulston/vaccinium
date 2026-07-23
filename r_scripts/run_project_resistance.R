library(terra)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 5) {
  stop(
    paste(
      "Expected five arguments:",
      "resistance raster,",
      "WorldClim template,",
      "output filename,",
      "terra temp directory,",
      "number of CPUs"
    )
  )
}

resistance_file <- args[1]
template_file   <- args[2]
output_file     <- args[3]
temp_dir        <- args[4]
n_cpus          <- as.integer(args[5])

dir.create(
  dirname(output_file),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  temp_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

terraOptions(
  tempdir = temp_dir,
  memfrac = 0.75,
  threads = n_cpus,
  progress = 1
)

cat("Resistance raster:", resistance_file, "\n")
cat("WorldClim template:", template_file, "\n")
cat("Output:", output_file, "\n")
cat("Terra temporary directory:", temp_dir, "\n")
cat("CPUs:", n_cpus, "\n")
cat("terra version:", as.character(packageVersion("terra")), "\n\n")

resistance_classes_rast <- rast(resistance_file)
wclim_template <- rast(template_file)

cat("Resistance raster:\n")
print(resistance_classes_rast)

cat("\nWorldClim template:\n")
print(wclim_template)

resistance_rast_coarse <- project(
  x = resistance_classes_rast,
  y = wclim_template,
  method = "mean",
  mask = FALSE,
  threads = TRUE,
  filename = output_file,
  overwrite = TRUE,
  wopt = list(
    datatype = "FLT4S",
    gdal = c(
      "COMPRESS=DEFLATE",
      "BIGTIFF=YES",
      "TILED=YES"
    )
  )
)

cat("\nCompleted raster:\n")
print(resistance_rast_coarse)

cat("\nOutput file information:\n")
print(file.info(output_file)[, c("size", "mtime")])

cat("\nProcessing completed successfully.\n")