function get_objective(facility_location_nodes:: Vector{Int}, mx::MapData)
    ranges_nodes, ranges_times = OpenStreetMapX.nodes_within_driving_time(mx, facility_location_nodes, 999999.9)
    mean(ranges_times)
end

"""
    c1_c5_metrics(node_data, positions::Vector{Int}, metric, R::Float64, Q::Int)

Calculates C1:C5 metrics:
- C1 - Mean Distance to Primary
- C2 - Mean Distance to Primary and Backup
- C3 - Mean Distance to Backup(s)
- C4 - Ratio of demand points covered with both primary and backup coverage
within a range threshold
- C5 - Ratio of demand points covered with at least primary coverage within
range threshold

# Arguments
- `node_data`: distance trees for each node
- `positions::Vector{Int}`: List of nodes inidicating positions of facilities
- `R::Float64`: range threshold, i.e. coverage of one facility
- `Q::Int`: required number of coverage for each demand node

# Examples
```julia-repl
c1, c2, c3, c4, c5 = c1_c5_metrics(mx, positions, "time", 500, 2)
```
"""

function c1_c5_metrics(node_data, positions::Vector{Int}, R::Float64, Q::Int)
    n = length(positions)
    metrics_df = DataFrame(node = collect(keys(node_data)))


    for (ind, val) in enumerate(positions)
        amb_i, dist_i = ["amb_", "dist_"] .* string(ind)
        col_names = ["node", amb_i, dist_i]

        one_node_df = DataFrame(node = node_data[val][1],
                                amb = val,
                                dist = node_data[val][2])
        rename!(one_node_df, Symbol.(col_names))
        metrics_df = innerjoin(metrics_df, one_node_df, on = :node)
    end

    sub_df = metrics_df[:, Symbol.(string.("dist_", 1:n))]

    #Finding best distances
    best_dist = hcat([sort(Vector(r))[1:Q] for r in eachrow(sub_df)]...) |> transpose |> DataFrame
    rename!(best_dist, Symbol.(string.("best_",1:Q)))
    metrics_df = hcat(metrics_df, best_dist)

    #Finding how many times a demand point is covered
    covered_by_n = [sum(Vector(r) .<= R) for r in eachrow(sub_df)]
    metrics_df.covered_by_n = covered_by_n

    C1 = mean(metrics_df.best_1)
    C2 = mean(select(metrics_df, Symbol.("best_" .* string.(1:Q))) |> Matrix)
    if Q > 1
        C3 = mean(select(metrics_df, Symbol.("best_" .* string.(2:Q))) |> Matrix)
    else
        C3 = missing
    end
    C4 = mean(metrics_df.covered_by_n .>= 1)
    C5 = mean(metrics_df.covered_by_n .>= Q)

    return (C1, C2, C3, C4, C5)
end
