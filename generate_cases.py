"""Generate case_001.jl through case_032.jl from template and parameter table."""
import re

# Case parameters: (case, type, k_rock, rho_c_rock, depth, Q_abs, m_dot, spacing)
cases = [
    (1,  "1x1", 2.1, 1700000, 1100, 170000, 5, 0),
    (2,  "1x1", 2.4, 2400000, 2300, 260000, 5, 0),
    (3,  "1x1", 2.8, 2000000, 1500, 390000, 5, 0),
    (4,  "1x1", 3.2, 2600000, 2000, 210000, 5, 0),
    (5,  "1x1", 3.6, 1900000, 1200, 330000, 5, 0),
    (6,  "1x1", 4.4, 2200000, 2500, 180000, 5, 0),
    (7,  "1x1", 2.0, 2100000, 1800, 400000, 5, 0),
    (8,  "1x1", 3.9, 1600000, 1400, 240000, 5, 0),
    (9,  "1x1", 2.6, 2500000, 2100, 350000, 5, 0),
    (10, "1x1", 4.1, 2000000, 1600, 290000, 5, 0),
    (11, "1x1", 3.0, 1800000, 2400, 320000, 5, 0),
    (12, "1x1", 4.5, 2600000, 1000, 150000, 5, 0),
    (13, "2x2", 2.2, 2000000, 1200, 250000, 5, 25),
    (14, "2x2", 2.8, 2000000, 2000, 380000, 5, 35),
    (15, "2x2", 3.5, 2000000, 1500, 180000, 5, 60),
    (16, "2x2", 4.3, 2000000, 2400, 320000, 5, 45),
    (17, "2x2", 2.0, 2000000, 1800, 400000, 5, 20),
    (18, "2x2", 3.1, 2000000, 1100, 210000, 5, 70),
    (19, "2x2", 3.8, 2000000, 2500, 260000, 5, 30),
    (20, "2x2", 4.5, 2000000, 1600, 350000, 5, 55),
    (21, "2x2", 2.6, 2000000, 2200, 170000, 5, 40),
    (22, "2x2", 3.3, 2000000, 1300, 300000, 5, 65),
    (23, "2x2", 4.0, 2000000, 2100, 240000, 5, 28),
    (24, "2x2", 2.4, 2000000, 1400, 330000, 5, 50),
    (25, "1x1", 2.1, 1700000, 1100, 170000, 5, 0),
    (26, "1x1", 3.2, 2600000, 2000, 210000, 5, 0),
    (27, "1x1", 3.6, 1900000, 1200, 330000, 5, 0),
    (28, "1x1", 4.4, 2200000, 2500, 180000, 5, 0),
    (29, "2x2", 2.8, 2000000, 2000, 380000, 5, 35),
    (30, "2x2", 3.5, 2000000, 1500, 180000, 5, 60),
    (31, "2x2", 4.5, 2000000, 1600, 350000, 5, 55),
    (32, "2x2", 2.0, 2000000, 1800, 400000, 5, 20),
]

# Read the template
with open("case_001.jl", "r", encoding="utf-8") as f:
    template = f.read()

for case_num, case_type, k_rock, rho_c_rock, depth, Q, m_dot, spacing in cases:
    content = template

    # Use regex to replace the value before each # CHANGED comment, regardless of current value
    # Line 22: k_rock
    content = re.sub(
        r"^(\s+)[\d.eE+\-]+,(\s+# k_rock .* # CHANGED)",
        rf"\g<1>{k_rock},\2",
        content, count=1, flags=re.MULTILINE,
    )

    # Line 23: rho_c_rock
    content = re.sub(
        r"^(\s+)[\d.eE+\-]+,(\s+# rho_c_rock .* # CHANGED)",
        rf"\g<1>{rho_c_rock},\2",
        content, count=1, flags=re.MULTILINE,
    )

    # Line 37: borehole_spacing
    content = re.sub(
        r"^(borehole_spacing = )[\d.]+(\s+# CHANGED)",
        rf"\g<1>{spacing}\2",
        content, count=1, flags=re.MULTILINE,
    )

    # Line 46: depth
    content = re.sub(
        r"^(\s+)[\d.]+,(\s+# h - borehole depth .* # CHANGED)",
        rf"\g<1>{depth},\2",
        content, count=1, flags=re.MULTILINE,
    )

    # Line 103: Q
    content = re.sub(
        r"^(Q = )[\d.]+(\s+# heat extraction rate .* # CHANGED)",
        rf"\g<1>{Q}\2",
        content, count=1, flags=re.MULTILINE,
    )

    filename = f"case_{case_num:03d}.jl"
    with open(filename, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated {filename} ({case_type}, k={k_rock}, rho_c={rho_c_rock}, depth={depth}, Q={Q}, spacing={spacing})")

print("\nDone! Generated 32 case files.")

# =============================================================================
# Generate SLURM .sh files for each case
# =============================================================================
sh_template = """#!/bin/bash

# Request resources
#SBATCH -p mit_preemptable
#SBATCH -G h200:1
#SBATCH -c 4
#SBATCH -t 22:00:00
#SBATCH --requeue
#SBATCH -J {job_name}
#SBATCH -o simulation_%j.out
#SBATCH -e simulation_%j.err

# Run your simulation
julia {jl_file}
"""

for case_num, *_ in cases:
    job_name = f"case_{case_num:03d}"
    jl_file = f"case_{case_num:03d}.jl"
    sh_file = f"case_{case_num:03d}.sh"
    with open(sh_file, "w", encoding="utf-8", newline="\n") as f:
        f.write(sh_template.format(job_name=job_name, jl_file=jl_file).lstrip("\n"))
    print(f"Generated {sh_file}")

print("\nDone! Generated 32 .sh files.")

# =============================================================================
# Generate master submission script
# =============================================================================
with open("submit_all.sh", "w", encoding="utf-8", newline="\n") as f:
    f.write("#!/bin/bash\n")
    f.write("# Submit all 32 cases to SLURM\n\n")
    f.write("for i in $(seq -w 1 32); do\n")
    f.write('    echo "Submitting case_${i}..."\n')
    f.write('    sbatch "case_${i}.sh"\n')
    f.write("done\n")
    f.write('\necho "All jobs submitted!"\n')

print("Generated submit_all.sh")
