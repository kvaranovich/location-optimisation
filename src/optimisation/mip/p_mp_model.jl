"""
optimise_p_mp_model(node_data, p::Int, m::Int, n::Int, metric::String, q::Int, save_distance_matrix::Bool)

Optimises p-mp model

# Arguments
- `distance_matrix::Array{Float64,2}`: distance matrix between also nodes combinations
- `p::Int`: Number of facilities
- `m::Array{Int64,1}`: Set of candidate locations for facilities
- `n::Array{Int64,1}`: Set of demand points
- `h::Array{Int64,1}`: Set of weight for demand points
- `q::Int`: Number of coverage required for each facility

# Value
Function returns a dictionary of the following objects
- `final_nodes::Vector{Int}` - an array of nodes ids of final locations
- `t::Float64` - the time in seconds it took to run an optimisation
- `obj2` - Objective value from the MIP model

# Examples
```julia-repl
optimise_p_mp_model(distance_matrix, 9, 400, 400, 1, 1)
```
"""

include("../../utils.jl")

function optimise_p_mp_model(distance_matrix::Union{Array{Float64,2}, Array{Int,2}}, p::Int, m::Array{Int64,1}, n::Array{Int64,1}, h::Array{Int64,1}, q::Int)
    logger("Defining a JuMP Model", 1)
    model = Model(Gurobi.Optimizer)

    set_optimizer_attribute(model, "NodeFileStart", 0.5) #Dane o wierzcholkach MIP zapisywane do pliku
    set_optimizer_attribute(model, "Threads", 1) #Dane o wierzcholkach MIP zapisywane do pliku

    M = length(m)
    N = length(n)

    @variable(model, y[1:M], Bin) # 1 if facility is sited at location "i"
    @variable(model, z[1:M, 1:N], Bin) # 1 demand j is assigned to a facility at location "i"

    @objective(model, Min, sum(h[j]*distance_matrix[i,j]*z[i,j] for i in 1:M, j in 1:N))

    @constraint(model, sum(y[i] for i in 1:M) == p)
    @constraint(model, eq3[j = 1:N], sum(z[i, j] for i in 1:M) == q)
    @constraint(model, con[i = 1:M, j = 1:N], z[i,j] <= y[i])

    logger("Starting Optimisation")
    t = @elapsed JuMP.optimize!(model)
    logger("Finished Optimisation. Total Time: " * string(t))

    JuMP.value.(y)
    JuMP.value.(z)
    final_nodes = m[convert(Array{Bool}, JuMP.value.(y))]
    final_nodes = convert(Array{Int,1}, final_nodes)

    vals = [Symbol(x) for x in "N" .* string.(1:N)]
    #demand_assignment = DataFrame(convert(Array{Int}, JuMP.value.(z)), :auto)
    #rename!(demand_assignment, vals)
    #demand_assignment = hcat("M" .* string.(1:M), demand_assignment)

    #obj = estimate_amb_layout_goodness(final_nodes, mx)
    #obj2 = objective_value(model)


    return Dict(
            "final_nodes" => final_nodes,
            "t" => t#,
            #"obj2" => obj2,
            #"demand_assignment" => demand_assignment
        )
end
