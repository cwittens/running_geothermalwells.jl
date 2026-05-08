#!/bin/bash

# Request resources
#SBATCH -p mit_normal_gpu
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 6:00:00
#SBATCH --requeue
#SBATCH -J array_study_01
#SBATCH -o array_study_01_%j.out
#SBATCH -e array_study_01_%j.err

# Run your simulation
julia array_study_01.jl
