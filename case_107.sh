#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 48:00:00
#SBATCH --requeue
#SBATCH -J case_107
#SBATCH -o case_107_%j.out
#SBATCH -e case_107_%j.err

# Run your simulation
julia case_107.jl
