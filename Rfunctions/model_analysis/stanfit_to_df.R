# stan.objを読み込んで、dfとして出力する

#library(tidyverse)
#library(here)

stanfit_to_df <- function(fit) {
  
  #fit <- readRDS(file)
  
  tmp_summary <- fit$summary()
  
  map_fit <- fit$summary(NULL, map = calc_map) # map値を計算する
  
  fit_summary <- 
    tmp_summary %>% 
    dplyr::full_join(map_fit, by = "variable") 
  
  return(fit_summary)
  
}
