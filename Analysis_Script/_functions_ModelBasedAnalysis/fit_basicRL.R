# 単純なQ学習モデルをフィッティングする

#library(tidyverse)
#library(rstan)
#library(here) 

fit_basicRL <- function(data_path, stan_model, save_path, stan_set) {
  
  data_dfs <- purrr::map_dfr(data_path, get_data_basicRL) # get_data_basicRLはデータの形に合わせて適宜変更
  
  # stanが読み取れるように、データを行列やリストに変換する
  # Memo: basic_RL.stan
  # int Choice[N, T];
  # matrix[T, N] Reward;
  
  # Choice matrix
  ## row: ID, column: trial # 
  data_dfs %>% 
    tidyr::pivot_wider(id_cols = ID, names_from = Trial, values_from = Choice) %>% 
    dplyr::select(-ID) %>% 
    as.matrix(.) -> 
    Choice_m 
  
  # Reward matrix
  ## row: trial, column: ID # matrixは列優先なので、転置する
  data_dfs %>% 
    tidyr::pivot_wider(id_cols = ID, names_from = Trial, values_from = Reward) %>% 
    dplyr::select(-ID) %>% 
    as.matrix(.) %>% 
    t(.) ->
    Reward_m
  
  start_time <- proc.time() # 開始時間
  
  # 保存ファイル名を作成
  save_fit_path <- paste0(save_path, "/", "stanfit.obj")
  
  # データをリストで渡す
  N <- nrow(Choice_m)
  T <- ncol(Choice_m)
  dat <- list(
    N = N,
    T = T,
    Choice = Choice_m,
    Reward = Reward_m
  )
  
  # サンプリング
  st <- stan_set # 引数stan_setで外部から指定
  fit <- rstan::sampling(
    stan_model, data=dat, 
    seed=st$seed, chains=st$chains, iter=st$iter, warmup=st$warmup, 
    thin=st$thin, cores=st$cores)
    
  # stan.objを保存
  saveRDS(fit, file = save_fit_path)
  
  # 経過時間の表示
  end_time <- proc.time()
  print(end_time - start_time)
  
}
