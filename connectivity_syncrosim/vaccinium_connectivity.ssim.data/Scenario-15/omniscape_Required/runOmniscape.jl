cd(raw"C:\Users\terre\Documents\R\vaccinium\connectivity_syncrosim\vaccinium_connectivity.ssim.data\Scenario-15\omniscape_Required")

using Pkg; Pkg.add(name="GDAL"); Pkg.add(name="Omniscape")
using Omniscape
run_omniscape("config.ini")