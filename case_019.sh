#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 22:00:00
#SBATCH --requeue
#SBATCH -J case_019
#SBATCH -o case_019_%j.out
#SBATCH -e case_019_%j.err

# Run your simulation
julia case_019.jl
