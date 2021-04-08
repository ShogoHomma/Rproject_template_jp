# stan.objを読み込んで、1つのcsvとして出力する

#library(tidyverse)
#library(here)

params_csv_basicRL <- function(target_stanfit, save_path, output_csv_name) {
  
  stan_df <- stan_to_df(target_stanfit) %>% 
    as_tibble() # 一応tibble化しておく
  
  save_csv_path <- paste0(save_path, "/", output_csv_name)
  
  stan_df %>% 
    readr::write_csv(file = save_csv_path)
  
}
