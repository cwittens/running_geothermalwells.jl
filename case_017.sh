#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 22:00:00
#SBATCH --requeue
#SBATCH -J case_017
#SBATCH -o case_017_%j.out
#SBATCH -e case_017_%j.err

# Run your simulation
julia case_017.jl
