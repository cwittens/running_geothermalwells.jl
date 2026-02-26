#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 22:00:00
#SBATCH --requeue
#SBATCH -J case_027
#SBATCH -o simulation_%j.out
#SBATCH -e simulation_%j.err

# Run your simulation
julia case_027.jl
