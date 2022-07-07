"""
    create_distance_trees (mx::MapData, metric)

Calculate the distance between all combinations of the nodes in MapData object.
If `metric` = `distance`, `nodes_within_driving_distance` from OpenStreetMapX
is used to calculate the distances based on the weights of the edges. If
`metric` = `time`, `nodes_within_driving_time` is used to calculate times.
The result is a dictionary, where the key is the node id, and the value is
a set of two arrays - the first containing nodes id, and the second containing
distances to these respective nodes.

This function is used to created a distance matrix for pmp and mclp optimisation
model.

# Examples
```julia-repl
julia> create_distance_trees(mx, "time")
julia> create_distance_trees(mx, "distance")
```
"""
function create_distance_trees(mx, metric)
    all_nodes = collect(keys(mx.v))
    node_data = Dict{Int64,Tuple{Array{Int64,1},Array{Float64,1}}}()

    if metric in ["distance"]
        y = nodes_within_driving_distance
    elseif metric == "time"
        y = nodes_within_driving_time
    else
        error("Only metric = \"distance\" or metric = \"time\" is allowed")
    end

    for node in all_nodes
        nd_data = y(mx, [node], 999999.99)
        push!(node_data, node => nd_data)
    end

    return node_data
end

"""
    build_distance_matrix_graph(nodes1, nodes2, node_data)

Calculate the distance between all combinations of the nodes in MapData object.
If `metric` = `distance`, `nodes_within_driving_distance` from OpenStreetMapX
is used to calculate the distances based on the weights of the edges. If
`metric` = `time`, `nodes_within_driving_time` is used to calculate times.
The result is a dictionary, where the key is the node id, and the value is
a set of two arrays - the first containing nodes id, and the second containing
distances to these respective nodes.

This function is used to created a distance matrix for pmp and mclp optimisation
model.

# Examples
```julia-repl
julia> create_distance_trees(mx, "time")
julia> create_distance_trees(mx, "distance")
```
"""
function build_distance_matrix_graph(nodes1, nodes2, node_data)
    m = length(nodes1)
    n = length(nodes2)
    D_ij = Array{Float64}(undef, m, n)

    for i in 1:m
        for j in 1:n
            node1 = nodes1[i]
            node2_idx = findfirst(x -> x == nodes2[j], node_data[node1][1])
            D_ij[i,j] = node_data[node1][2][node2_idx]
        end
    end

    return Int.(round.(D_ij))
end
