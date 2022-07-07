"""
optimise_p_mp_model(node_data, p::Int, m::Int, n::Int, metric::String, q::Int, R::Float64)

Optimises p-mp model

# Arguments
- `distance_matrix::Array{Float64,2}`: distance matrix between also nodes combinations
- `p::Int`: Number of facilities
- `m::Array{Int64,1}`: Set of candidate locations for facilities
- `n::Array{Int64,1}`: Set of demand points
- `h::Array{Int64,1}`: Set of weight for demand points
- `q::Int`: Number of coverage required for each facility
- `R::Float64`: Radius of required coverage

# Value
Function returns a dictionary of the following objects
- `final_nodes::Vector{Int}` - an array of nodes ids of final locations
- `t::Float64` - the time in seconds it took to run an optimisation
- `obj2` - Objective value from the MIP model

# Examples
```julia-repl
optimise_p_mp_model(node_data, 9, 400, 400, "time", 1, 1, false)
```
"""

function optimise_mclp_model(distance_matrix::Union{Array{Float64,2}, Array{Int,2}}, p::Int, m::Array{Int64,1}, n::Array{Int64,1}, h::Array{Int64,1}, q::Int, r::Float64)
    logger("Defining a JuMP Model", 1)
    Q_ij = distance_matrix .<= r #facility i covers target locations j

    model = Model(Gurobi.Optimizer)

    set_optimizer_attribute(model, "NodeFileStart", 0.5) #Dane o wierzcholkach MIP zapisywane do pliku
    set_optimizer_attribute(model, "Threads", 1) #Dane o wierzcholkach MIP zapisywane do pliku

    M = length(m)
    N = length(n)

    @variable(model, y[1:M], Bin) # constraint 9; 1 if facility is sited at location "i"
    @variable(model, z[1:N], Bin) # constraint 9; 1 demand j is assigned to a facility at location "i"

    @objective(model, Max, sum(h[j]*z[j] for j in 1:N))

    @constraint(model, sum(y[i] for i in 1:M) == p) #constraint 7

    for j = 1:N
        @constraint(model, sum(Q_ij[i,j]*y[i] for i in 1:M) >= q*z[j]) #constraint 8
    end

    t = @elapsed JuMP.optimize!(model)

    JuMP.value.(y)
    JuMP.value.(z)
    final_nodes = m[convert(Array{Bool}, JuMP.value.(y))]
    final_nodes = convert(Array{Int,1}, final_nodes)

    #n_suppliers = [sum(Q_ij[i,j]*value(y[i]) for i in 1:M) for j in 1:N]
    #n_suppliers = DataFrame(n_suppliers = Int.(n_suppliers))
    #vals = [Symbol(x) for x in "N" .* string.(1:N)]
    #demand_assignment = DataFrame(is_assigned = convert(Array{Int}, JuMP.value.(z)))

    #obj = estimate_amb_layout_goodness(final_nodes, mx)
    #obj2 = objective_value(model)


    return Dict(
            "final_nodes" => final_nodes,
            "t" => t#,
            #"obj2" => obj2,
            #"demand_assignment" => demand_assignment,
            #"n_suppliers" => n_suppliers
        )
end
