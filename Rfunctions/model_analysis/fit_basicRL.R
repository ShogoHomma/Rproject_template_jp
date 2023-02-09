# 単純なQ学習モデルをフィッティングする

#library(tidyverse)
#library(cmdstanr)
#library(here) 

fit_basicRL <- function(data_path, mod, save_path, stan_set) {
  
  # ---- データの読み込み & 整形 ---- #
  
  if (length(data_path) > 1) {
    
    data_df <- purrr::map_dfr(data_path, get_data_basicRL) # get_data_basicRLはデータの形に合わせて適宜変更
    
  } else {
    
    data_df <- get_data_basicRL(data_path)
    
  }
  
  # stanが読み取れるように、データを行列やリストに変換する
  # Memo: basicRL.stan
  # int Choice[N, T];
  # matrix[T, N] Reward;
  
  # Choice matrix
  ## row: ID, column: trial # arrayは行優先
  data_df %>% 
    tidyr::pivot_wider(id_cols = ID, names_from = Trial, values_from = Choice) %>% 
    dplyr::select(-ID) %>% 
    as.matrix(.) -> 
    Choice_m 
  
  # Reward matrix
  ## row: trial, column: ID # matrixは列優先なので、転置する
  data_df %>% 
    tidyr::pivot_wider(id_cols = ID, names_from = Trial, values_from = Reward) %>% 
    dplyr::select(-ID) %>% 
    as.matrix(.) %>% 
    t(.) ->
    Reward_m
  
  # データをリストで渡す
  N <- nrow(Choice_m)
  T <- ncol(Choice_m)
  
  dat <- list(
    N = N,
    T = T,
    Choice = Choice_m,
    Reward = Reward_m
  )
  
  # ---- サンプリング ---- #
  
  start_time <- proc.time() # 開始時間
  
  st <- stan_set # 引数をstan_setで外部から指定
  
  # サンプリング
  fit <- mod$sample(
    data = dat,
    seed = st$seed,
    init = st$init,
    chains = st$chains,
    parallel_chains = st$parallel_chains,
    iter_sampling = st$iter_sampling,
    iter_warmup = st$iter_warmup,
    adapt_delta = st$adapt_delta,
    thin = st$thin,
    cores = st$cores
  )
  
  # 経過時間の表示
  end_time <- proc.time()
  print(paste0("elapsed time sampling: ", end_time - start_time))
  
  
  # ---- stan objectの保存 ---- #
  
  # 保存ファイル名を作成
  save_fit_path <- paste0(save_path, "/", "stanfit.RDS")
  
  # stan object を保存
  fit$save_object(file = save_fit_path)
  
}
