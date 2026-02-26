using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using GeothermalWells
using OrdinaryDiffEqStabilizedRK: ODEProblem, solve, ROCK2
using KernelAbstractions: CPU, adapt
using JLD2: @save, @load
using CUDA: CUDABackend

# Choose backend: CPU() for testing, or CUDABackend()/ROCBackend() for GPU
backend = CUDABackend()
Float_used = Float64

simulation_data_dir() = joinpath(@__DIR__, "simulation_data")
!isdir(simulation_data_dir()) && mkdir(simulation_data_dir())

# =============================================================================
# Material properties
# =============================================================================
materials = HomogenousMaterialProperties{Float_used}(
    2.6,                    # k_rock - thermal conductivity of rock [W/(m·K)]                      # CHANGED 
    2500000,                 # rho_c_rock - volumetric heat capacity [J/(m³·K)]                     # CHANGED
    0.59,                    # k_water [W/(m·K)]
    998 * 4179,              # rho_c_water [J/(m³·K)]
    52.7,                    # k_steel (outer pipe) [W/(m·K)]
    7850 * 475,              # rho_c_steel [J/(m³·K)] (estimated - not specified in paper)
    0.45,                    # k_insulating (polyethylene inner pipe) [W/(m·K)]
    941 * 1800,              # rho_c_insulating [J/(m³·K)] (estimated - not specified in paper)
    1.05,                    # k_backfill (grout) [W/(m·K)]
    995 * 1200               # rho_c_backfill (grout) [J/(m³·K)]
)

# =============================================================================
# Borehole geometry
# =============================================================================
borehole_spacing = 0                                             # CHANGED
XC = [-borehole_spacing / 2, borehole_spacing / 2]
YC = [-borehole_spacing / 2, borehole_spacing / 2]
unique!(XC)
unique!(YC)
boreholes2 = tuple(
    (Borehole{Float_used}(
        xc,                      # xc [m]
        yc,                      # yc [m]
        2100,                   # h - borehole depth [m]                                       # CHANGED 
        0.04337,                 # r_inner - inner radius of central pipe [m]
        0.00688,                 # t_inner - thickness of inner pipe wall [m]
        0.08085,                 # r_outer - inner radius of outer pipe [m]
        0.0081,                  # t_outer - thickness of outer pipe wall [m]
        0.108,                   # r_backfill - borehole radius [m]
        5,                       # ṁ - mass flow rate [kg/s]                                     
        0.0                      # insulation_depth [m] 
    ) for xc in XC, yc in YC)...
)



# =============================================================================
# Grid setup
# =============================================================================
# Domain boundaries
xmin, xmax, ymin, ymax, zmin, zmax = compute_domain(boreholes; buffer_x=100, buffer_y=100, buffer_z=200)


# Grid parameters
dx_fine = 0.0025      # fine spacing near borehole [m]
growth_factor = 1.3   # geometric growth rate
dx_max = 10.0         # maximum spacing far from borehole [m]
dz = 50.0             # vertical spacing [m]

# Create adaptive grids (fine near borehole, coarse far away)
gridx = create_adaptive_grid_1d(
    xmin=xmin, xmax=xmax,
    dx_fine=dx_fine, growth_factor=growth_factor, dx_max=dx_max,
    boreholes=boreholes, backend=backend, Float_used=Float_used, direction=:x
)

gridy = create_adaptive_grid_1d(
    xmin=ymin, xmax=ymax,
    dx_fine=dx_fine, growth_factor=growth_factor, dx_max=dx_max,
    boreholes=boreholes, backend=backend, Float_used=Float_used, direction=:y
)

gridz = create_uniform_gridz_with_borehole_depths(zmin=zmin, zmax=zmax, dz=dz, boreholes=boreholes, backend=backend)

println("Grid size: $(length(gridx)) x $(length(gridy)) x $(length(gridz))")

# =============================================================================
# Initial condition
# =============================================================================
# Linear thermal gradient: T(z) = T_surface + gradient * z
T0 = initial_condition_thermal_gradient(
    backend, Float_used, gridx, gridy, gridz;
    T_surface=10,     # surface temperature [°C]
    gradient=0.035    # thermal gradient [K/m]
);


# =============================================================================
# Inlet model
# =============================================================================
Q = 350000                             # heat extraction rate [W]                  # CHANGED 
c_water = 4179.0                     # specific heat of water [J/(kg·K)]
inlet_model = HeatExchangerInlet{Float_used}(Q / (borehole.ṁ * c_water))

# =============================================================================
# Create simulation cache
# =============================================================================
cache = create_cache(
    backend=backend,
    gridx=gridx,
    gridy=gridy,
    gridz=gridz,
    materials=materials,
    boreholes=boreholes,
    inlet_model=inlet_model
)

# =============================================================================
# Time integration
# =============================================================================
tspan = (0, 3600 * 24)# * 365 * 20)  # simulate for 20 years

prob = ODEProblem(rhs_diffusion_z!, T0, tspan, cache)

# Save solution at regular intervals
n_saves = 21  # save initial + 20 more times
saveat = range(tspan..., n_saves)
callback, saved_values = get_simulation_callback(
    saveat=saveat,
    print_every_n=100000
)

# Time step and solver
Δt = 80.0  # [s]

println("Simulating with Δt = $(Δt)s")

t_elapsed = @elapsed solve(
    prob,
    ROCK2(max_stages=100, eigen_est=eigen_estimator),
    save_everystep=false,
    callback=callback,
    adaptive=false,
    dt=Δt,
    maxiters=Int(1e10)
)

println("Simulation completed in $(t_elapsed) seconds")

cache_cpu = create_cache(
    backend=CPU(),
    gridx=gridx,
    gridy=gridy,
    gridz=gridz,
    materials=materials,
    boreholes=boreholes,
    inlet_model=inlet_model
)

@save joinpath(simulation_data_dir(), "$(splitext(basename(@__FILE__))[1]).jld2") saved_values Δt cache_cpu t_elapsed

