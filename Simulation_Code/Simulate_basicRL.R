# 単純な強化学習のシミュレーション

library(tidyverse)
library(here)

# 関数の読み込み
common_functions_path <- here("Rfunctions", "common")
common_functions <- here(common_functions_path, dir(common_functions_path))
purrr::walk(common_functions, ~source(.x))

model_functions_path <- here("Rfunctions", "model_analysis")
model_functions <- here(model_functions_path, dir(model_functions_path))
purrr::walk(model_functions, ~source(.x))

project_functions_path <- here("Rfunctions", "project")
project_functions <- here(project_functions_path, dir(project_functions_path))
purrr::walk(project_functions, ~source(.x))

# 結果の出力先
save_sim_dir <- here("Model_Simulation_Recovery")


## ------- シミュレーション関数 -------

simulate_basicRL <- function(df_agent_params, task_params) {
  
  # 課題のパラメータ
  trialN <- task_params$trialN
  p1_reward <- task_params$p1_reward
  p2_reward <- task_params$p2_reward
  
  # 個体のパラメータ
  agentN <- nrow(df_agent_params)
  
  alpha <- df_agent_params$alpha
  beta <- df_agent_params$beta
  
  # 保存用のリスト, 試行ごとに結果を結合する
  simulated_list <- NULL
  
  for (trial_i in 1:trialN) {
    
    # 空のベクトルを作成
    vec_reward <- rep(3, times = agentN) # later filled by 0 or 1
    #next_qvalues <- matrix(1e+8, nrow = agentN, ncol = 2) # later filled by small value
    
    if (trial_i == 1) {
      
      current_qvalues <- matrix(0, nrow = agentN, ncol = 2)
      next_qvalues <- matrix(1e+3, nrow = agentN, ncol = 2) # later filled by small value
      
    } else {
      
      current_qvalues <- next_qvalues
      next_qvalues <- matrix(1e+3, nrow = agentN, ncol = 2) # later filled by small value
      
    }
    
    #print("-----------")
    #print(current_qvalues)
    
    
    # === choice ===
    vec_pchoice1 <- 1.0 / (1.0 + exp(-beta*( current_qvalues[,1] - current_qvalues[,2] )))
    
    vec_choice <- rbinom(n = agentN, size = 1, prob = vec_pchoice1)
    
    vec_choice[vec_choice == 0] <- 2 # convert choice 0 -> choice 2
    
    # === get reward ===
    if (sum(vec_choice == 1) > 0) { # if at least one agent chose option 1
      
      vec_reward[vec_choice == 1] <- rbinom(n = sum(vec_choice == 1), size = 1, prob = p1_reward)
      
    } 
      
    if (sum(vec_choice == 2) > 0) { # if at least one agent chose option 2
      
      vec_reward[vec_choice == 2] <- rbinom(n = sum(vec_choice == 2), size = 1, prob = p2_reward)
      
    }
    
    if (3 %in% vec_reward == TRUE) {
      
      stop("Error. Some reward values were not replaced and 3 remained left. See vec_reward.")
      
    }
    
    # === update Qvalue ===
    
    if (sum(vec_choice == 1) > 0) { # if at least one agent chose option 1
      
      next_qvalues[vec_choice == 1, 1] <- current_qvalues[vec_choice == 1, 1] + alpha[vec_choice == 1] * (vec_reward[vec_choice == 1] - current_qvalues[vec_choice == 1, 1])
      next_qvalues[vec_choice == 1, 2] <- current_qvalues[vec_choice == 1, 2]

    } 
    
    if (sum(vec_choice == 2) > 0) { # if at least one agent chose option 2
      
      next_qvalues[vec_choice == 2, 2] <- current_qvalues[vec_choice == 2, 2] + alpha[vec_choice == 2] * (vec_reward[vec_choice == 2] - current_qvalues[vec_choice == 2, 2])
      next_qvalues[vec_choice == 2, 1] <- current_qvalues[vec_choice == 2, 1]
      
    }
    
    if (1e+8 %in% next_qvalues == TRUE) {
      
      stop("Error. Some q values were not replaced and 1e+8 remained left. See next_qvalues.")
      
    }
    
    tmp_output <- 
      df_agent_params %>% 
      dplyr::mutate(
        trial = trial_i,
        Q1 = current_qvalues[, 1],
        Q2 = current_qvalues[, 2],
        pchoice1 = vec_pchoice1,
        choice = vec_choice,
        reward = vec_reward
      )
    
    # 試行ごとに結果を結合する
    simulated_list <- c(simulated_list, list(tmp_output))
    
  }
  
  return(simulated_list)
  
}


simulate_basicRL_IND <- function(df_agent_params, task_params) {
  
  ## simulate_basicRLと同じ
  ## ベクトルで全ての個体をまとめて一度に処理した方が速いけど、
  ## わかりやすさ重視で、forループで、ひとり一人実行していく
  
  # 課題のパラメータ
  trialN <- task_params$trialN
  p1_reward <- task_params$p1_reward
  p2_reward <- task_params$p2_reward
  
  agentN <- nrow(df_agent_params)
  
  # 保存用のリスト, 試行ごとに結果を結合する
  simulated_list <- NULL

  for (agent_i in 1:agentN) {
    
    alpha_i <- df_agent_params %>% dplyr::slice(agent_i) %>% dplyr::pull(alpha) 
    beta_i <- df_agent_params %>% dplyr::slice(agent_i) %>% dplyr::pull(beta) 
    
    # 保存用のベクトル
    vec_pchoice1 <- rep(3.0, times = trialN) 
    vec_choice <- rep(3, times = trialN) # later filled by 0 or 1
    mat_qvalues <- matrix(1e+8, nrow = trialN+1, ncol = 2) 
    mat_qvalues[1, ] <- 0 # 第1試行は0で初期化
    vec_reward <- rep(3, times = trialN) # later filled by 0 or 1
    
    for (trial_i in 1:trialN) {
      
      # === choice ===
      vec_pchoice1[trial_i] <- 1 / (1 + exp(-beta_i*( mat_qvalues[trial_i, 1] -  mat_qvalues[trial_i, 2] )))
      
      vec_choice[trial_i] <- rbinom(n = 1, size = 1, prob = vec_pchoice1[trial_i])
      
      if (vec_choice[trial_i] == 0) {
        vec_choice[trial_i] <- 2 # convert choice 0 -> choice 2
      }
      
      # === get reward ===
      if (vec_choice[trial_i] == 1) {
        
        vec_reward[trial_i] <- rbinom(n = 1, size = 1, prob = p1_reward)
        
      } else if (vec_choice[trial_i] == 2) {
        
        vec_reward[trial_i] <- rbinom(n = 1, size = 1, prob = p2_reward)
        
      } else {
        
        stop("Error. See mat_choice.")
        
      }
      
      # === update Qvalue ===
      
      ## update Qvalue of the chosen option
      mat_qvalues[ trial_i+1, vec_choice[trial_i] ] <- 
        mat_qvalues[ trial_i, vec_choice[trial_i] ] + 
        alpha_i * (vec_reward[trial_i] - mat_qvalues[ trial_i, vec_choice[trial_i] ])
      
      ## keep Qvalue of the unchosen option
      mat_qvalues[ trial_i+1, 3-vec_choice[trial_i] ] <- 
        mat_qvalues[ trial_i, 3-vec_choice[trial_i] ]
      
    }
    
    mat_qvalues <- mat_qvalues[-(trialN+1), ] # delete last column
    
    tmp_output <- 
      tibble(
        ID = agent_i,
        alpha = alpha_i,
        beta = beta_i,
        trial = 1:trialN,
        Q1 = mat_qvalues[, 1],
        Q2 = mat_qvalues[, 2],
        pchoice1 = vec_pchoice1,
        choice = vec_choice,
        reward = vec_reward
      )
    
    # 試行ごとに結果を結合する
    simulated_list <- c(simulated_list, list(tmp_output))
    
  }
  
  return(simulated_list)
  
}


## ------- basicRL ---------


# ---- * 課題のパラメータ -----

## Binary：選択肢1を選ぶと、p1_rewardで1、(1 - p1_reward) で0

trialN <- 100
p1_reward <- 0.7
p2_reward <- 0.3

task_params <- list(
  trialN = trialN,
  p1_reward = p1_reward,
  p2_reward = p2_reward
)


# ---- * 個体のパラメータ

## prior: 確率分布からランダムに生成
## sequence: 等間隔の数列

## priorの場合

agentN <- 100
alpha <- runif(n = agentN, min = 0, max = 1)
beta <- rexp(n = agentN, rate = 1)

df_agent_params <-
  tibble(
    ID = 1:agentN,
    alpha = alpha,
    beta = beta
  )


## sequenceの場合

alpha <- seq(from = 0.1, to = 1.0, length.out = 10)
beta <- seq(from = 0.1, to = 2.0, length.out = 10)

df_agent_params <- # パラメータの全ての組み合わせをdfにする
  tidyr::crossing(
    alpha = alpha,
    beta = beta
  ) %>% 
  dplyr::mutate(
    ID = 1:nrow(.)
  ) %>% 
  dplyr::select(ID, alpha, beta)


# ---- * シミュレーションのパラメータ -----

params_init <- "prior"
siminfo_list <- c(task_params, params_init = list(params_init))


# ---- * 実行 -----


simulated_dat <- simulate_basicRL(df_agent_params, task_params)

df_simulated_dat <- 
  dplyr::bind_rows(simulated_dat)


# ---- * データの保存 -----

stan_name <- "basicRL.stan"
sub_index <- "prior01_N100_T0100_1p07_2p03"
save_path <- setup_savepath(save_sim_dir, stan_name, sub_index, fit_sim = "sim")

df_simulated_dat %>% 
  readr::write_csv(file = paste0(save_path, "/simulated_data.csv"))

# このシミュレーションコードのコピー

this_file <- here("Simulation_Code", "Simulate_basicRL.R")
file.copy(from = this_file, to = here(save_path, "Simulate_basicRL.R"))

# シミュレーション情報の出力

save_siminfo(siminfo_list, save_path)



# -------- IND version -------


## Note: 行列で全ての個体をまとめて処理した方が速いけど、
##  わかりやすさ重視で、forループで、ひとり一人実行していく

res <- simulate_basicRL_IND(df_agent_params, task_params)

simulated_res <- 
  dplyr::bind_rows(res)


## データの保存

stan_name <- "basicRL.stan"
sub_index <- "seq01_test2"
save_path <- setup_savepath(save_sim_dir, stan_name, sub_index)

df_simulated_dat %>% 
  readr::write_csv(file = paste0(save_path, "/simulated_data.csv"))

# このシミュレーションコードのコピー

this_file <- here("Simulation_Code", "Simulate_basicRL.R")
file.copy(from = this_file, to = here(save_path, "Simulate_basicRL.R"))

# シミュレーション情報の出力

save_siminfo(siminfo_list, save_path)


