# 単純な強化学習のシミュレーション

library(tidyverse)

## ------- データ保存の関数 -------

writeToCSV <- function(output_df) {
  
  # 保存先のディレクトリの作成
  current_time <- format(Sys.time(), "%Y%m%d%H%M%S")
  sim_output_dir <- paste0("DummyData_RL_", current_time)
  
  sim_output_path <- here("Data", "DummyData_RL", sim_output_dir)
  dir.create(sim_output_path, recursive = TRUE)
  
  # このシミュレーションコードのコピー
  this_file <- here("Simulation_Code", "generate_DummyData_RL.R")
  file.copy(from = this_file, to = here(sim_output_path, "generate_DummyData_RL.R"))
  
  # csvへ保存
  output_df %>% 
    readr::write_csv(path = here(sim_output_path, "RL_trial.csv"))
  
}



## ------- パラメータの設定 -------

### 課題のパラメータ

### Binary：Option1_p_rewardで1、1 - Option1_p_rewardで0

trial_N <- 50

Option1_p_reward <- 0.7
Option2_p_reward <- 0.3

### 個体のパラメータ

alpha <- c(0.1, 0.3, 0.5, 0.7, 0.9)
beta <- c(0.5, 1.0, 1.5, 2.0, 2.5)

params_set <- # パラメータの全ての組み合わせをdfにする
  tidyr::crossing(
    alpha = alpha,
    beta = beta
  ) %>% 
  dplyr::mutate(
    ID = 1:nrow(.)
  )

Prob_Choices <- matrix(0, nrow = nrow(params_set), ncol = trial_N)

Choices <- matrix(0, nrow = nrow(params_set), ncol = trial_N)

Qvalues <- array(0, dim = c(nrow(params_set), trial_N + 1, 2)) 
# Qvalues[, t, 1] がoption 1, Qvalues[, t, 1]がoption 2

Rewards <- matrix(0, nrow = nrow(params_set), ncol = trial_N)


## ------ シミュレーションの実行 -------

## Note: 行列で全ての個体をまとめて処理した方が速いけど、
##  わかりやすさ重視で、forループで、ひとり一人実行していく

for (agent_i in 1:nrow(params_set)) {
  
  alpha_i <- params_set %>% dplyr::slice(agent_i) %>% dplyr::pull(alpha) 
  beta_i <- params_set %>% dplyr::slice(agent_i) %>% dplyr::pull(beta) 
  
  for (trial_i in 1:trial_N) {
    
    ## choice
    Prob_Choices[agent_i, trial_i] <- 1 / (1 + exp(-beta_i*( Qvalues[agent_i, trial_i, 1] - Qvalues[agent_i, trial_i, 2] )))
    
    Choices[agent_i, trial_i] <- as.integer(rbernoulli(n = 1, p = Prob_Choices[agent_i, trial_i]))[1]
    
    if (Choices[agent_i, trial_i] == 0) {
      Choices[agent_i, trial_i] <- 2 # convert choice 0 -> choice 2
    }
    
    ## get reward
    if (Choices[agent_i, trial_i] == 1) {
      
      Rewards[agent_i, trial_i] <- as.integer(rbernoulli(n = 1, p = Option1_p_reward))
      
    } else if (Choices[agent_i, trial_i] == 2) {
      
      Rewards[agent_i, trial_i] <- as.integer(rbernoulli(n = 1, p = Option2_p_reward))
      
    } else {
      
      print("Error. See Choices.")
      
    }
    
    ## update Qvalue
    ### update Qvalue of the chosen option
    Qvalues[agent_i, trial_i + 1, Choices[agent_i, trial_i]] <- 
      Qvalues[agent_i, trial_i, Choices[agent_i, trial_i]] + alpha_i * (Rewards[agent_i, trial_i] - Qvalues[agent_i, trial_i, Choices[agent_i, trial_i]])
    
    ### keep Qvalue of the unchosen option
    Qvalues[agent_i, trial_i + 1, 3 - Choices[agent_i, trial_i]] <- 
      Qvalues[agent_i, trial_i, 3 - Choices[agent_i, trial_i]]
    
  }

}

Qvalues <- Qvalues[, -(trial_N + 1), ] # delete last column


## ------ データの保存 --------

output_df <-
  params_set %>% 
  tidyr::crossing(., trial = 1:trial_N) %>% 
  dplyr::mutate(
    Q1 = t(Qvalues[, , 1]) %>% as.vector(.),
    Q2 = t(Qvalues[, , 2]) %>% as.vector(.),
    Prob = t(Prob_Choices) %>% as.vector(.),
    Choice = t(Choices) %>% as.vector(.),
    Reward = t(Rewards) %>% as.vector(.)
  )

writeToCSV(output_df)

