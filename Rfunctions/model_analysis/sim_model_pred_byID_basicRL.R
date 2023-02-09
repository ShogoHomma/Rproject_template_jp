# 参加者一人ひとりについて、basicRLの予測分布をシミュレーションする関数

sim_model_pred_byID_basicRL <- function(id_i, data_df, params_df) {
  
  # parameters
  alpha_set <- 
    params_df %>% 
    dplyr::filter(p_index == id_i) %>% 
    dplyr::filter(para == "alpha") %>% 
    dplyr::transmute(
      mean = mean, 
      mode = mode, 
      median = `50%`)
  
  beta_set <- 
    params_df %>% 
    dplyr::filter(p_index == id_i) %>% 
    dplyr::filter(para == "beta") %>% 
    dplyr::transmute(
      mean = mean, 
      mode = mode, 
      median = `50%`)
  
  # data
  trial_N <- 
    data_df %>% 
    dplyr::filter(ID == id_i) %>% 
    dplyr::pull(trial) %>% 
    unique(.) %>% length(.)
  
  Choice <- 
    data_df %>% 
    dplyr::filter(ID == id_i) %>% 
    dplyr::pull(Choice)
  
  Reward <- 
    data_df %>% 
    dplyr::filter(ID == id_i) %>% 
    dplyr::pull(Reward)
  
  # 3つの代表値、それぞれについて計算する
  for (value_i in c("mean", "mode", "median")) {
    
    # set parameters for specific representative value
    alpha <- alpha_set %>% dplyr::pull(value_i)
    beta <- beta_set %>% dplyr::pull(value_i)
    
    # initialize matrix for save
    p <- rep(0, times = trial_N) 
    Q <- matrix(0, nrow = trial_N + 1, ncol = 2) 
    LL <- 0
    
    # simulate Q learning
    for (t in 1:trial_N) {
      
      # prob of chooseing Q1 (high risk option)
      p[t] <- 1 / (1 + exp(-beta*( Q[t, 1] - Q[t, 2] )))
      
      # log likelihood
      LL <- LL + (Choice[t]==1)*log(p[t]) + (Choice[t]==2)*log(1-p[t])
      
      # update Q value (Q1:high risk, Q2: low risk)
      
      delta <- Reward[t] - Q[t, Choice[t]] # RPE
      Q[t+1, Choice[t]] <- Q[t, Choice[t]] + alpha * delta # update for chosen option
      Q[t+1, 3-Choice[t]] <- Q[t, 3-Choice[t]] # update for non-chosen option
      
    }
    
    Q <- Q[-(trial_N + 1), ] # delete last column
    
    if (value_i == "mean") {
      mean <- list(negLL = -LL, Q = Q, p = p)
    } else if (value_i == "mode") {
      mode <- list(negLL = -LL, Q = Q, p = p)
    } else if (value_i == "median") {
      median <- list(negLL = -LL, Q = Q, p = p)
    } else {
      stop("error. check the representative values.")
    }
    
  }
  
  # mean, mode, medianをまとめて返す
  res_sim <- 
    list(
      mean = mean, 
      mode = mode, 
      median = median
    )
  
  return(res_sim) 
  
}
