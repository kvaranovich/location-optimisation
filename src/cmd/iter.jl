include("../utils.jl")
logger("Commmand Line Interface definition")
using ArgParse

function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table! s begin
    "--location"
      help = "name of folder, representing a city)"
      arg_type = String
      required = true
    "--p"
      help = "number of facilities, e.g. [4, 9, 16]"
      arg_type = Int
      required = true
    "--r"
      help = """radius of reachable nodes around each ambulance to consider at
      each optimization step. The higher the radius, the longer is optimization
      time. Examples: [100.00, 150.00, 175.00] for time and [1000.00, 2000.00, 3000.00]"""
	  arg_type = Float64
      required = true
    "--ruin_random"
      help = """% of potential moves to randomly destroy at each iteration. In
      general, leads to better computing time at a cost of worse results. It
      is not recommended to set it higher than 0.5. Setting parameter to 0.0
      means that no potential moves are destroyed, i.e. all moves are considered"""
      arg_type = Float64
      required = true
	"--seed"
	  help = "random seed for reproducing results"
	  arg_type = Int
	  required = true
  end

  return parse_args(s)
end

args = parse_commandline()


logger("Importing modules")
using CSV
using DataFrames
using Dates
using GLM
using JLD
using Statistics
using OpenStreetMapX
using Random
using StatsBase
using JSON
include("../optimisation/iterative/optimisation.jl")


# Input parameters processing
logger("Input parameters and data input")
const MODEL = "iter"
const P = args["p"] #number of facilities
const R = args["r"] #radius of local search
const LOCATION = args["location"]

const PATH_OSM = "osm_maps/" * LOCATION * "/map.osm"
const RUIN_RANDOM = args["ruin_random"]
const N_GLOBAL_RANDOM_TRIES = 100
const SEED = args["seed"]
const PATH_OUT = (
    "out/"  * MODEL * "_" * LOCATION * "_p"*string(P) * "_r"*string(Int(round(R)))
    * "_ruin"*string(RUIN_RANDOM) * "_seed"*string(SEED) * ".json"
)
Random.seed!(SEED)

# Input Data
logger("Reading OSM data")
mx = get_map_data(PATH_OSM, use_cache=true, road_levels=Set(1:5), trim_to_connected_graph = true);
#initial_nodes = generate_random_locations(mx, P)
initial_nodes = get_best_of_n_random_locations(mx, P, N_GLOBAL_RANDOM_TRIES)


# Optimisation
logger("Starting Optimisation")

t = @elapsed opt_loc = location_optimization_radius(mx, initial_nodes, 500, "time", RUIN_RANDOM, R)
results = Dict(
    "t"=>t,
    "final_nodes"=>opt_loc[1][end],
    "obj"=>opt_loc[2][end]
)

logger("Finished Optimisation. Total Time: " * string(t))


# Saving Output
logger("Saving Output")

out = merge(
    args,
    results,
    Dict(
        "created_at"=>Dates.now(),
        "model"=>MODEL,
        "m"=>length(mx.v),
        "n"=>length(mx.v),
    )
)

open(PATH_OUT,"w") do f
    JSON.print(f, out, 4)
end

logger("Finished Processing")
