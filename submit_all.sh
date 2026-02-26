#!/bin/bash
# Submit all 32 cases to SLURM

for i in $(seq 1 8) $(seq 13 20) $(seq 25 32); do
    padded=$(printf "%03d" $i)
    echo "Submitting case_${padded}..."
    sbatch "case_${padded}.sh"
done

echo "All jobs submitted!"