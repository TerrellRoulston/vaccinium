#!/bin/bash
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=256G
#SBATCH --output=hpc_test_sdm.out

module load StdEnv/2023 r/4.4.0
export R_LIBS=/project/6074193/mig_lab/bin/RPackages

Rscript hpc_test_sdm.R > script.log 2>&1
echo "R script finished running."