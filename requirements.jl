using Pkg

dependencies = [
    "ArgParse",
    "DataFrames",
	"CSV",
	"Plots",
	"OpenStreetMapX",
	"Gurobi",
	"JuMP",
	"RCall",
	"StatsBase",
    "JLD",
    "JSON"
]

Pkg.add(dependencies)
