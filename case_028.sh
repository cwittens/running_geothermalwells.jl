#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 48:00:00
#SBATCH --requeue
#SBATCH -J case_028
#SBATCH -o case_028_%j.out
#SBATCH -e case_028_%j.err

# Run your simulation
julia case_028.jl
