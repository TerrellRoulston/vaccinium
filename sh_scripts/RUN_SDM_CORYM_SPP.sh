#!/bin/bash
#SBATCH --array=0-8                # Array size (9 tasks, 0-8, corymbosum complex spp)
#SBATCH --ntasks=1                 # One node per task
#SBATCH --cpus-per-task=8          # 8 CPUs per task
#SBATCH --mem-per-cpu=4G           # 32 GB per task
#SBATCH --time=4:00:00             # 4 hour time limit
#SBATCH --mail-user=terrell.roulston@acadiau.ca
#SBATCH --mail-type=ALL
#SBATCH --output=logs/maxent_corym_%A_%a.out
#SBATCH --error=logs/maxent_corym_%A_%a.err

module load StdEnv/2023 r/4.5.0
export R_LIBS=/project/6074193/mig_lab/bin/RPackages_4_5_0

# Corymbosum complex species (subspecies workflow)
species=("ash" "cae" "cor2" "cot" "ell" "for" "fus" "sim" "vir")

# Ensure the task ID is valid
if [ $SLURM_ARRAY_TASK_ID -ge ${#species[@]} ]; then
  echo "Error: SLURM_ARRAY_TASK_ID exceeds species array size"
  exit 1
fi

# Get the species name for this task
species_name=${species[$SLURM_ARRAY_TASK_ID]}

# Log the species being processed
echo "Processing corymbosum-complex species: $species_name"

# Run R script with the species name as an argument
Rscript run_vac_maxent_corym_spp.R $species_name
