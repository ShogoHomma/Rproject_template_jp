# stan.objを読み込んで、traceplotの画像を.pngとして出力し、保存する

#library(tidyverse)
#library(here)

save_traceplot_basicRL <- function(target_stanfit, save_path) {
  
  fit <- readRDS(target_stanfit) # stan.objの読み込み
  
  # 参加者（ID）ごとに.pngを出力する
  ## そのため、参加者の人数を指定する
  sbj_N <- fit@par_dims %>% .$alpha
  
  ## 参加者ごとに保存するパラメータを指定する
  target_params <- c("alpha", "beta")
  
  ## 事後分布の画像を保存
  purrr::walk(1:sbj_N, ~plot_traceplot_byID_basicRL(.x, fit, save_path, target_params))
  
}
