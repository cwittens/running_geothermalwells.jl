#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 22:00:00
#SBATCH --requeue
#SBATCH -J case_015
#SBATCH -o case_015_%j.out
#SBATCH -e case_015_%j.err

# Run your simulation
julia case_015.jl
