#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 48:00:00
#SBATCH --requeue
#SBATCH -J case_022
#SBATCH -o case_022_%j.out
#SBATCH -e case_022_%j.err

# Run your simulation
julia case_022.jl
