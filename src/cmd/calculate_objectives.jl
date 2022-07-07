using JSON
using OpenStreetMapX
using JLD
using DataFrames
using Statistics

include("../../src/optimisation/metrics.jl")

const LOCATION = "winnipeg"
const PATH_OSM = "osm_maps/" * LOCATION * "/map.osm"
const PATH_DISTANCE_TREES = "osm_maps/" * LOCATION * "/trees.jld"
const PATH_RESULTS = "out"


mx = get_map_data(PATH_OSM, use_cache=true, road_levels=Set(1:5), trim_to_connected_graph = true);
node_data = load(PATH_DISTANCE_TREES, "node_data")
files = readdir("out", join=true)


for file in files
    println(file)
    sleep(0.25)
    #results = JSON.parsefile(file, use_mmap=false)
    results = JSON.parse(open(file))

    if !("obj" in keys(results))
        nodes = convert(Vector{Int}, results["final_nodes"])
        obj = get_objective(nodes, mx)
        results["obj"] = obj

        open(file,"w") do f
            JSON.print(f, results, 4)
        end
    end
end
