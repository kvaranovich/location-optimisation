include("search_space.jl")
include("../metrics.jl")

function generate_random_locations(mx::MapData, p::Int)
    initial_nodes = sample(collect(keys(mx.v)), p, replace=false)
    return initial_nodes
end

function get_best_of_n_random_locations(mx::MapData, p::Int, n_tries::Int)
    positions = []
    objectives = []

    for i in 1:n_tries
        pos_i = generate_random_locations(mx, p)
        obj_i = get_objective(pos_i, mx)
        append!(positions, [pos_i])
        append!(objectives, obj_i)
    end

    best_objective_i = argmin(objectives)
    best_positions = positions[best_objective_i]

    return best_positions
end

function optimization_step(mx::MapData, initial_positions::Vector{Int},
    metric="time", space_search_function::Function = find_possible_movements_radius,
    ruin_random = 0.0; kwargs...)

    if metric in ["distance", "eucledian"]
        y = nodes_within_driving_distance
    elseif metric == "time"
        y = nodes_within_driving_time
    else
        error("Only metric = \"distance\" or metric = \"time\" is allowed")
    end

    possible_moves = space_search_function(mx, initial_positions, y; kwargs...)
    idx = sample([true, false], Weights([1-ruin_random, ruin_random]), length(possible_moves))
    possible_moves = possible_moves[idx]

    estimates_after_move = []
    for move in possible_moves
        NODES = copy(initial_positions)
        filter!(x -> x!=move[1], NODES)
        append!(NODES, move[2])
        EST = get_objective(NODES, mx)
        append!(estimates_after_move, EST)
    end

    best_time_i = argmin(estimates_after_move)
    best_time = minimum(estimates_after_move)

    improved_positions = copy(initial_positions)
    filter!(x -> x!=possible_moves[best_time_i][1], improved_positions)
    append!(improved_positions, possible_moves[best_time_i][2])

    return improved_positions, best_time
end

function location_optimization_radius(mx::MapData, initial_positions::Vector{Int},
    N_ITER = 100, metric = "time", ruin_random = 0.0, r = 150.0)

    LAST_NODES = copy(initial_positions)
    NODES = []
    TIMES = []

    for i in 1:N_ITER
        println(i)
        CURR_NODES, CURR_TIME = optimization_step(mx, LAST_NODES, metric, find_possible_movements_radius, ruin_random; r = r)

        if i > 1
            if CURR_TIME >= TIMES[end]
                println("Found local minimum. Stopping.")
                break
            end
        end

        append!(NODES, [CURR_NODES])
        append!(TIMES, CURR_TIME)
        LAST_NODES = CURR_NODES
        #println(CURR_TIME)
    end

    return NODES, TIMES
end
