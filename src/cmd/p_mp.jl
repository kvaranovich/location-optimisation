include("../utils.jl")
logger("Commmand Line Interface definition")
using ArgParse


function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table! s begin
    "--location"
      help = "name of folder, representing a city"
      arg_type = String
      required = true
    "--p"
      help = "number of facilities, e.g. [4, 9, 16]"
      arg_type = Int
      required = true
    "--m"
      help = "number of candidate locations, e.g. [50, 100, 200, 400]"
      arg_type = Int
      required = true
    "--n"
      help = "number of demand points, e.g. [500, 1000, 1500, 2000]"
      arg_type = Int
      required = true
    "--q"
      help = "minimum number of coverage, e.g. [1, 2, 3]"
      arg_type = Int
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
using Statistics
using StatsBase
using DataFrames
using Dates
using CSV
using Random
using JLD
using JuMP
using Gurobi
using JSON

include("../optimisation/mip/p_mp_model.jl")

logger("Input parameters and data input")

const MODEL = "p_mp"
const M = args["m"] #number of candidate locations
const N = args["n"] #numer of demand locations
const P = args["p"] #number of facilities to place
const Q = args["q"] #minimum number of coverage required

const LOCATION = args["location"]
const PATH_DISTANCE_MATRIX = "osm_maps/" * LOCATION * "/distance_matrix.jld"
const PATH_NODE_IDS = "osm_maps/" * LOCATION * "/node_ids.jld"
const SEED = args["seed"]
const PATH_OUT = (
    "out/"  * MODEL * "_" * LOCATION * "_p"*string(P) * "_m"*string(M) * "_n"*string(N)
    * "_q"*string(Q) * "_seed"*string(SEED) * ".json"
)

Random.seed!(SEED)

if isfile(PATH_OUT)
    logger("Skipping file - Already Processed")
else
    #Input Data
    logger("Loading data")
    all_node_ids = load(PATH_NODE_IDS, "all_node_ids")
    distance_matrix = load(PATH_DISTANCE_MATRIX, "distance_matrix")

    #Sampling
    if M > 0 & N > 0
        m_idx = sample(1:length(all_node_ids), M, replace=false)
        n_idx = sample(1:length(all_node_ids), N, replace=false)
        m = all_node_ids[m_idx]
        n = all_node_ids[n_idx]
        h = repeat([1], N)

        sample_distance_matrix = distance_matrix[m_idx, n_idx] #Subsetting distance_matrix
        distance_matrix = nothing
        GC.gc()
    else
        # if m & n <=0 --> use the full distance_matrix
        sample_distance_matrix = distance_matrix
        m = all_node_ids
        n = all_node_ids
        h = repeat([1], length(n))
    end

    # Optimisation
    results = optimise_p_mp_model(sample_distance_matrix, P, m, n, h, Q)


    logger("Saving Output")

    out = merge(
        args,
        results,
        Dict("created_at"=>Dates.now(), "model"=>MODEL)
    )

    open(PATH_OUT,"w") do f
        JSON.print(f, out, 4)
    end

    logger("Finished Processing")
end
