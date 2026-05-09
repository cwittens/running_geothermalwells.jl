#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 48:00:00
#SBATCH --requeue
#SBATCH -J array_study_02
#SBATCH -o array_study_02_%j.out
#SBATCH -e array_study_02_%j.err

# Run your simulation
julia array_study_02.jl