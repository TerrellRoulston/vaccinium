#!/bin/bash

#SBATCH --job-name=resistance_project
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=4:00:00
#SBATCH --mail-user=terrell.roulston@acadiau.ca
#SBATCH --mail-type=ALL
#SBATCH --output=logs/resistance_project_%j.out
#SBATCH --error=logs/resistance_project_%j.err

# Stop immediately if any command fails
set -euo pipefail

# -------------------------------------------------------------------------
# Load R and set package library
# -------------------------------------------------------------------------

module load StdEnv/2023 r/4.5.0

export R_LIBS=/project/6074193/mig_lab/bin/RPackages_4_5_0

# -------------------------------------------------------------------------
# Permanent file paths
# -------------------------------------------------------------------------

INPUT_RESISTANCE="/project/6074193/mig_lab/vac_sdm/connectivity_inputs/landcover_resistance_30m.tif"

INPUT_TEMPLATE="/project/6074193/mig_lab/vac_sdm/connectivity_inputs/wclim_template.tif"

OUTPUT_DIR="/project/6074193/mig_lab/vac_sdm/connectivity_inputs"

R_SCRIPT="/project/6074193/mig_lab/vac_sdm/run_project_resistance.R"

# -------------------------------------------------------------------------
# Create directories
# -------------------------------------------------------------------------

mkdir -p logs
mkdir -p "${OUTPUT_DIR}"

mkdir -p "${SLURM_TMPDIR}/input"
mkdir -p "${SLURM_TMPDIR}/output"
mkdir -p "${SLURM_TMPDIR}/terra_temp"

# -------------------------------------------------------------------------
# Log job information
# -------------------------------------------------------------------------

echo "============================================================"
echo "Resistance raster projection"
echo "============================================================"
echo "Job ID: ${SLURM_JOB_ID}"
echo "Node: $(hostname)"
echo "Start time: $(date)"
echo "CPUs requested: ${SLURM_CPUS_PER_TASK}"
echo "Memory requested: 128 GB"
echo "Scratch directory: ${SLURM_TMPDIR}"
echo

echo "Scratch disk space:"
df -h "${SLURM_TMPDIR}"
echo

# -------------------------------------------------------------------------
# Confirm required files exist
# -------------------------------------------------------------------------

if [ ! -f "${INPUT_RESISTANCE}" ]; then
    echo "ERROR: Resistance raster not found:"
    echo "${INPUT_RESISTANCE}"
    exit 1
fi

if [ ! -f "${INPUT_TEMPLATE}" ]; then
    echo "ERROR: WorldClim template not found:"
    echo "${INPUT_TEMPLATE}"
    exit 1
fi

if [ ! -f "${R_SCRIPT}" ]; then
    echo "ERROR: R script not found:"
    echo "${R_SCRIPT}"
    exit 1
fi

# -------------------------------------------------------------------------
# Copy input files to node-local scratch
# -------------------------------------------------------------------------

echo "Copying resistance raster to node-local scratch..."

cp "${INPUT_RESISTANCE}" \
   "${SLURM_TMPDIR}/input/landcover_resistance_30m.tif"

echo "Copying WorldClim template to node-local scratch..."

cp "${INPUT_TEMPLATE}" \
   "${SLURM_TMPDIR}/input/wclim_template.tif"

echo "Input files copied successfully."
echo

ls -lh "${SLURM_TMPDIR}/input"
echo

# -------------------------------------------------------------------------
# Define temporary paths
# -------------------------------------------------------------------------

SCRATCH_RESISTANCE="${SLURM_TMPDIR}/input/landcover_resistance_30m.tif"

SCRATCH_TEMPLATE="${SLURM_TMPDIR}/input/wclim_template.tif"

SCRATCH_OUTPUT="${SLURM_TMPDIR}/output/land_resistance_coarse.tif"

# -------------------------------------------------------------------------
# Run R processing script
# -------------------------------------------------------------------------

echo "Starting R raster projection at $(date)"
echo

Rscript "${R_SCRIPT}" \
    "${SCRATCH_RESISTANCE}" \
    "${SCRATCH_TEMPLATE}" \
    "${SCRATCH_OUTPUT}" \
    "${SLURM_TMPDIR}/terra_temp" \
    "${SLURM_CPUS_PER_TASK}"

echo
echo "R processing completed at $(date)"

# -------------------------------------------------------------------------
# Confirm output exists
# -------------------------------------------------------------------------

if [ ! -f "${SCRATCH_OUTPUT}" ]; then
    echo "ERROR: Expected output was not created:"
    echo "${SCRATCH_OUTPUT}"
    exit 1
fi

echo
echo "Scratch output:"
ls -lh "${SCRATCH_OUTPUT}"

# -------------------------------------------------------------------------
# Copy completed output to permanent project storage
# -------------------------------------------------------------------------

echo
echo "Copying output to permanent storage..."

cp "${SCRATCH_OUTPUT}" \
   "${OUTPUT_DIR}/land_resistance_coarse.tif"

echo
echo "Permanent output:"
ls -lh "${OUTPUT_DIR}/land_resistance_coarse.tif"

# -------------------------------------------------------------------------
# Final job information
# -------------------------------------------------------------------------

echo
echo "Scratch disk space after processing:"
df -h "${SLURM_TMPDIR}"

echo
echo "============================================================"
echo "Job completed successfully"
echo "End time: $(date)"
echo "Output: ${OUTPUT_DIR}/land_resistance_coarse.tif"
echo "============================================================"