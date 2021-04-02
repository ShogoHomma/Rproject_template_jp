# stan.objを読み込んで、1つのcsvとして出力する

#library(tidyverse)
#library(here)

params_csv_basicRL <- function(target_stanfit, save_path, output_csv_name) {
  
  # stan.objが複数ある可能性も考えて、purrr::map_dfr()で1つに結合しながら読み込む
  stan_df <- purrr::map_dfr(target_stanfit, stan_to_df) %>% 
    as_tibble() # 一応tibble化しておく
  
  save_csv_path <- paste0(save_path, "/", output_csv_name)
  
  stan_df %>% 
    readr::write_csv(file = save_csv_path)
  
}
