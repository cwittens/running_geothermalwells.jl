#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 48:00:00
#SBATCH --requeue
#SBATCH -J case_002
#SBATCH -o case_002_%j.out
#SBATCH -e case_002_%j.err

# Run your simulation
julia case_002.jl
