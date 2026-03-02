#!/bin/bash
# Submit all 32 cases to SLURM

for i in $(seq -w 1 32); do
    echo "Submitting case_${i}..."
    sbatch "case_${i}.sh"
done

echo "All jobs submitted!"

for i in $(seq 1 12) $(seq 25 28); do
    padded=$(printf "%03d" $i)
    echo "Submitting case_${padded}..."
    sbatch "case_${padded}.sh"
    sleep 20
done

echo "All 1x1 jobs submitted!"

for i in $(seq 13 20) $(seq 29 32); do
    padded=$(printf "%03d" $i)
    echo "Submitting case_${padded}..."
    sbatch "case_${padded}.sh"
    sleep 20
done

echo "All 2x2 jobs submitted!"