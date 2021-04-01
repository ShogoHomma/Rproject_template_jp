# 単純な強化学習のシミュレーション

library(tidyverse)

## ------- データ保存の関数 -------

writeToCSV <- function(output_df, sbj_params_set, task_params_set) {
  
  # 保存先のディレクトリの作成
  current_time <- format(Sys.time(), "%Y%m%d%H%M%S")
  sps <- sbj_params_set
  tps <- task_params_set
  
  # task parameterとsbj parameterを繋げたディレクトリ名を生成する
  sim_output_dir <- paste0(
    "DummyData_RL_trialN", 
    tps$trial_N, "_1Op", tps$Option1_p_reward, "_2Op", tps$Option2_p_reward, 
    "_alpha", sps$alpha[1], "-", sps$alpha[length(sps$alpha)], 
    "_beta", sps$beta[1], "-", sps$beta[length(sps$beta)], "_", current_time)
  
  # パスの作成
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

Option1_p_reward <- 0.8
Option2_p_reward <- 0.2

### 個体のパラメータ

alpha <- c(0.1, 0.3, 0.5, 0.7, 0.9)
beta <- c(0.5, 1.0, 1.5, 2.0, 2.5)

sbj_params_set <- # パラメータの全ての組み合わせをdfにする
  tidyr::crossing(
    alpha = alpha,
    beta = beta
  ) %>% 
  dplyr::mutate(
    ID = 1:nrow(.)
  )

Prob_Choices <- matrix(0, nrow = nrow(sbj_params_set), ncol = trial_N)

Choices <- matrix(0, nrow = nrow(sbj_params_set), ncol = trial_N)

Qvalues <- array(0, dim = c(nrow(sbj_params_set), trial_N + 1, 2)) 
# Qvalues[, t, 1] がoption 1, Qvalues[, t, 1]がoption 2

Rewards <- matrix(0, nrow = nrow(sbj_params_set), ncol = trial_N)


## ------ シミュレーションの実行 -------

## Note: 行列で全ての個体をまとめて処理した方が速いけど、
##  わかりやすさ重視で、forループで、ひとり一人実行していく

for (agent_i in 1:nrow(sbj_params_set)) {
  
  alpha_i <- sbj_params_set %>% dplyr::slice(agent_i) %>% dplyr::pull(alpha) 
  beta_i <- sbj_params_set %>% dplyr::slice(agent_i) %>% dplyr::pull(beta) 
  
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

task_params_set <-
  list(
    trial_N = trial_N,
    Option1_p_reward = Option1_p_reward,
    Option2_p_reward = Option2_p_reward
  )

output_df <-
  sbj_params_set %>% 
  tidyr::crossing(., trial = 1:trial_N) %>% 
  dplyr::mutate(
    Q1 = t(Qvalues[, , 1]) %>% as.vector(.),
    Q2 = t(Qvalues[, , 2]) %>% as.vector(.),
    Prob = t(Prob_Choices) %>% as.vector(.),
    Choice = t(Choices) %>% as.vector(.),
    Reward = t(Rewards) %>% as.vector(.),
    Op1_p = Option1_p_reward,
    Op2_p = Option2_p_reward
  ) %>% 
  dplyr::select(ID, everything())

writeToCSV(output_df, sbj_params_set, task_params_set)



