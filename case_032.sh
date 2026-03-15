#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 48:00:00
#SBATCH --requeue
#SBATCH -J case_032
#SBATCH -o case_032_%j.out
#SBATCH -e case_032_%j.err

# Run your simulation
julia case_032.jl
