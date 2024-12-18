#!/bin/bash
#SBATCH --array=0-23              # Array size (24 tasks, 0-23)
#SBATCH --ntasks=1                 # MAKE SURE ITS ONE NODE
#SBATCH --cpus-per-task=8          # 8 CPUs per task
#SBATCH --mem-per-cpu=6G           # 6 GB per CPU  = 32 GB per task
#SBATCH --time=2:00:00             # 2 hour time limit
#SBATCH --mail-user=terrell.roulston@acadiau.ca   # Send email updates to you or someone else
#SBATCH --mail-type=ALL          # send an email in all cases (job started, job ended, job aborted)
#SBATCH --output=logs/maxent_%A_%a.out  # Array job ID (%A) and task ID (%a)
#SBATCH --error=logs/maxent_%A_%a.err   # Error file

module load StdEnv/2023 r/4.4.0
export R_LIBS=/project/6074193/mig_lab/bin/RPackages

# List all species that will be arrayed as seperate tasks
species=("bor" "ces" "cor" "cra" "dar" "del" "ery" "hir" "mac" "mem" "mys" "myr" "mtu" "ova" "ovt" "oxy" "pal" "par" "sco" "sta" "ten" "uli" "vir" "vid")

# Ensure the task ID is valid
if [ $SLURM_ARRAY_TASK_ID -ge ${#species[@]} ]; then
  echo "Error: SLURM_ARRAY_TASK_ID exceeds species array size"
  exit 1
fi

# Get the species name for this task
species_name=${species[$SLURM_ARRAY_TASK_ID]}

# Log the species being processed
echo "Processing species: $species_name"

# Run R script with the species name as an argument
Rscript run_vac_maxent.R $species_name