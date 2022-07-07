generate_scenarios_iterative <- function() {
  require(dplyr)
  
  location <- "winnipeg"
  p <- 1:25
  r <- c(100.0, 200.0, 300.0)
  ruin_random <- c(0.0, 0.25, 0.5, 0.75)
  seed <- 1:1
  
  scenarios <- expand.grid(p, r, ruin_random, seed)
  colnames(scenarios) <- c("p", "r", "ruin_random", "seed")
  
  scenarios_commands <- scenarios %>% 
    transmute(
      command = paste0(
        "julia src/cmd/iter.jl ",
        " --location ", location,
        " --p ", p,
        " --r ", r,
        " --ruin_random ", ruin_random,
        " --seed ", seed
      )
    )
  
  write.table(scenarios_commands, "scenarios/iterative.txt",
              row.names = FALSE, col.names = FALSE, quote = TRUE)
}

generate_scenarios_hier_iterative <- function() {
  require(dplyr)
  
  location <- "winnipeg"
  p <- 1:25
  r <- c(400.0, 800.0, 1200.0)
  ruin_random <- c(0.0, 0.25, 0.5, 0.75)
  seed <- 1:1
  
  scenarios <- expand.grid(p, r, ruin_random, seed)
  colnames(scenarios) <- c("p", "r", "ruin_random", "seed")
  
  scenarios_commands <- scenarios %>% 
    transmute(
      command = paste0(
        "julia src/cmd/hier_iter.jl ",
        " --location ", location,
        " --p ", p,
        " --r ", r,
        " --ruin_random ", ruin_random,
        " --seed ", seed
      )
    )
  
  write.table(scenarios_commands, "scenarios/hier_iterative.txt",
              row.names = FALSE, col.names = FALSE, quote = TRUE)
}

generate_scenarios_p_mp <- function() {
  require(dplyr)
  
  location <- "winnipeg_agg_9"
  p <- 1:25
  #m <- c(1000, 1500, 2000, 2500)
  #n <- c(1000, 2000, 4000)
  m <- 0
  n <- 0
  q <- 1
  seed <- 1:1
  
  scenarios <- expand.grid(p, m, n, q, seed)
  colnames(scenarios) <- c("p", "m", "n", "q", "seed")
  
  scenarios_commands <- scenarios %>% 
    transmute(
      command = paste0(
        "julia src/cmd/p_mp.jl ",
        " --location ", location,
        " --p ", p,
        " --m ", m,
        " --n ", n,
        " --q ", q,
        " --seed ", seed
      )
    )

    file_name <- paste0("scenarios/p_mp_", location, "_", seed, ".txt")
  
  write.table(scenarios_commands, file_name,
              row.names = FALSE, col.names = FALSE, quote = TRUE)
}

generate_scenarios_mclp <- function() {
  require(dplyr)
  
  location <- "winnipeg_agg_9"
  p <- 1:25
  #m <- c(1000, 1500, 2000, 2500)
  #n <- c(1000, 2000, 4000)
  m <- 0
  n <- 0
  q <- 1
  r <- 300.0
  seed <- 1:1
  
  scenarios <- expand.grid(p, m, n, q, r, seed)
  colnames(scenarios) <- c("p", "m", "n", "q", "r", "seed")
  
  scenarios_commands <- scenarios %>% 
    transmute(
      command = paste0(
        "julia src/cmd/mclp.jl ",
        " --location ", location,
        " --p ", p,
        " --m ", m,
        " --n ", n,
        " --q ", q,
        " --r ", r,
        " --seed ", seed
      )
    )

  file_name <- paste0("scenarios/mclp_", location, "_", seed, ".txt")
  
  write.table(scenarios_commands, file_name,
              row.names = FALSE, col.names = FALSE, quote = TRUE)
}

#generate_scenarios_iterative()
#generate_scenarios_hier_iterative()
generate_scenarios_p_mp()
generate_scenarios_mclp()
