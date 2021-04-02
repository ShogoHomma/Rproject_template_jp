# stan.objを読み込んで、dfとして出力する

#library(tidyverse)
#library(here)
source(here("Analysis_Script", "_functions", "map_value.R"))

stan_to_df <- function(file) {
  
  fit <- readRDS(file)
  fit_summary <- summary(fit)$summary %>% 
    as.data.frame() %>% 
    tibble::rownames_to_column(var = "para") 
  
  # パラメータの名前を取り出す
  para_name <- fit_summary %>% 
    dplyr::pull(para)
  
  # map_value()で各パラメータについてのposterior samplesを取り出し、MAP値を格納したベクトルを作成
  mode <- purrr::map_dbl(
    para_name, ~{rstan::extract(fit, .x) %>% purrr::flatten_dbl(.) %>% map_value(.)}
  ) 
  
  fit_summary <- 
    fit_summary %>% 
    dplyr::mutate(`mode` = mode) %>% 
    dplyr::mutate_if(is_numeric, round, 4) %>%  # 数値を全て下4桁になるように丸める
    dplyr::select(para, mean, se_mean, sd, `mode`, everything()) %>% 
    tidyr::separate(col = para, into = c("para", "p_index"), sep="\\[|\\]") 
  　　# パラメータのインデックス[]を列p_indexにする
  
  return(fit_summary)
  
}
