#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 12:00:00
#SBATCH --requeue
#SBATCH -J no_z_diffusion_test
#SBATCH -o no_z_diffusion_test_%j.out
#SBATCH -e no_z_diffusion_test_%j.err

# Run your simulation
julia no_z_diffusion_test.jl