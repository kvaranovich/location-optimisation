# Location Optimisation
Heuristics and algorithms for static and dynamic facility location optimisation.

Tags: location optimisation; p-mp problem; mclp problem; iterative location optimisation;

## From Command Line

### p-MP Model

```
julia src/cmd/p_mp.jl --location winnipeg --p 9 --m 500 --n 1000 --q 1 --seed 1
```

### MCLP Model

```
julia src/cmd/mclp.jl --location winnipeg --p 9 --m 500 --n 1000 --q 1 --r 600.0 --seed 1
```

### Iterative

```
julia src/cmd/iter.jl --location winnipeg --p 9 --r 100 --ruin_random 0.95 --seed 1
```

### Hierarchical-Iterative

```
julia src/cmd/hier_iter.jl --location winnipeg --p 9 --r 300 --ruin_random 0.95 --seed 1
```

## Batch Parallel Optimisation

```
Rscript.exe src/scenarios_generator.R
nohup cat scenarios/iterative.txt | xargs --max-args=1 --max-procs=5 bash src/wrapper.sh
nohup cat scenarios/hier_iterative.txt | xargs --max-args=1 --max-procs=5 bash src/wrapper.sh
nohup cat scenarios/p_mp.txt | xargs --max-args=1 --max-procs=5 bash src/wrapper.sh
nohup cat scenarios/mclp.txt | xargs --max-args=1 --max-procs=5 bash src/wrapper.sh
```