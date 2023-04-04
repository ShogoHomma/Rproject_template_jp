# 単純なQ学習モデルをフィッティングする

#library(tidyverse)
#library(cmdstanr)
#library(here) 

fit_basicRL <- function(data_path, mod, stan_set, save_path, save_var_list) {
  
  # ---- データの読み込み & 整形 ---- #
  
  if (length(data_path) > 1) {
    
    data_df <- 
      purrr::map_dfr(data_path, readr::read_csv(.x, show_col_types = FALSE)) %>% 
      dplyr::select(ID, trial, choice, reward)
      
  } else {
    
    data_df <- 
      readr::read_csv(data_path, show_col_types = FALSE) %>% 
      dplyr::select(ID, trial, choice, reward)
    
  }
  
  # stanが読み取れるように、データを行列やリストに変換する
  
  # Memo: basicRL.stan
  # array[N, T] int choice;
  # array[T, N] real reward;
  
  # choice matrix
  ## row: ID, column: trial # arrayは行優先
  choice_matrix <-
    data_df %>% 
    tidyr::pivot_wider(id_cols = ID, names_from = trial, values_from = choice) %>% 
    dplyr::select(-ID) %>% 
    as.matrix(.) 
  
  # reward matrix
  ## row: trial, column: ID # matrixは列優先なので、転置する
  reward_matrix <-
    data_df %>% 
    tidyr::pivot_wider(id_cols = ID, names_from = trial, values_from = reward) %>% 
    dplyr::select(-ID) %>% 
    as.matrix(.) %>% 
    t(.)
  
  # データをリストで渡す
  N <- nrow(choice_matrix)
  T <- ncol(choice_matrix)
  
  dat <- list(
    N = N,
    T = T,
    choice = choice_matrix,
    reward = reward_matrix
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
    thin = st$thin
  )
  
  # 経過時間の表示
  end_time <- proc.time()
  print(paste0("elapsed time sampling: ", end_time - start_time))
  
  
  # ---- stan objectの保存 ---- # → 重いのでやめる
  
  # 保存ファイル名を作成
  #save_fit_path <- paste0(save_path, "/", "fit_basicRL.RDS")
  
  # stan object を保存 
  #fit$save_object(file = save_fit_path)
  
  
  # ---- 変数ごとにRDSファイルとして保存 ---- #
  
  for (var_i in 1:length(save_var_list)) {
    
    target_vars <- save_var_list[[var_i]]
    print(paste0("save variables: ", paste(target_vars, collapse = ", ")))
    
    save_array <-
      fit$draws(target_vars)
    
    save_fit_path <- paste0(save_path, "/", "fit_basicRL_", names(save_var_list)[var_i], ".RDS")
    
    #readr::write_csv(save_df, file = save_fit_path)
    saveRDS(save_array, file = save_fit_path)
    
  }
  
  # ---- Rhatとeffective sample sizeを図とデータとして保存 ---- #
  
  print("save rhat graph and data ...")
  
  g_rhat <- bayesplot::mcmc_rhat(bayesplot::rhat(fit))
  
  save_grhat_path <- paste0(save_path, "/", "rhat_basicRL.png")
  
  ggsave(filename = save_grhat_path, plot = g_rhat)
  
  
  rhat_data <- bayesplot::mcmc_rhat_data(bayesplot::rhat(fit))
  
  save_rhatdata_path <- paste0(save_path, "/", "rhatdata_basicRL.csv")
  
  readr::write_csv(x = rhat_data, file = save_rhatdata_path)
  
  
  print("save neff graph and data ...")
  
  g_neff <- bayesplot::mcmc_neff(bayesplot::neff_ratio(fit))
  
  save_neff_path <- paste0(save_path, "/", "neff_basicRL.png")
  
  ggsave(filename = save_neff_path, plot = g_neff)
  
  
  neff_data <- bayesplot::mcmc_neff_data(bayesplot::neff_ratio(fit))
  
  save_neffdata_path <- paste0(save_path, "/", "neffdata_basicRL.csv")
  
  readr::write_csv(x = neff_data, file = save_neffdata_path)
  
  
}
