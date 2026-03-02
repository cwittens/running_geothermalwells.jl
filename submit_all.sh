#!/bin/bash
# Submit all 32 cases to SLURM

for i in $(seq -w 1 32); do
    echo "Submitting case_${i}..."
    sbatch "case_${i}.sh"
done

echo "All jobs submitted!"
