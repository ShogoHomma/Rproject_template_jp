# Rhatが1.1以上のパラメータをチェックし、csvに書き出す
## 1.1という基準は、馬場(2019)や松浦(2016)に基づく
## McElearth (2020) では1以下という基準が述べられているので、基準については要検討

#library(tidyverse)
#library(here)

check_Rhat <- function(target_stanfit, save_path) {
  
  stan_df <- stan_to_df(target_stanfit) %>% 
    as_tibble() # 一応tibble化しておく
  
  save_rhat_path <- paste0(save_path, "/", "check_rhat.csv")
  
  stan_df %>% 
    dplyr::filter(Rhat > 1.1) %>%  # Rhat > 1.1のものを抜き出す
    readr::write_csv(file = save_rhat_path)
    
}
