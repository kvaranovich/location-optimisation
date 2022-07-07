function find_neighbour_nodes(mx::MapData, node::Int)
    edges_with_nodes = [n for n in mx.e if node in n]
    flattened_nodes = collect(Iterators.flatten(edges_with_nodes))
    nodes = unique(flattened_nodes[flattened_nodes.!=node])
    return nodes
end

function find_possible_movements_neighbours(mx::MapData, positions::Vector{Int})
    ORIGIN_DESTINATION = []
    for AMB in positions
        adj_nodes = collect(Iterators.product(AMB, find_neighbour_nodes(mx, AMB)))
        append!(ORIGIN_DESTINATION, adj_nodes)
    end
    return ORIGIN_DESTINATION
end

function find_possible_movements_radius(mx::MapData, positions::Vector{Int}, y; r::Float64 = 150.0)
    ORIGIN_DESTINATION = []

    for (index, value) in enumerate(positions)
        nodes, times = y(mx, [value], r)
        origin_destination = collect(Iterators.product(value, nodes, index))
        append!(ORIGIN_DESTINATION, origin_destination)
    end

    return ORIGIN_DESTINATION
end
