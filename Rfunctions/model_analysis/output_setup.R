# モデルフィッティングの結果の保存先を作成する

#library(tidyverse)
#library(here)

output_setup <- function(output_path, stan_name, fit_index) {
  
  if (str_detect(stan_name, pattern = "\\.stan") == TRUE) { # .stanが含まれている場合
    model_name <- stan_name %>% str_split(pattern = "\\.stan") %>% .[[1]] %>% .[1]
  } else {
    model_name <- stan_name
  }
  
  cur_time <- format(Sys.time(), "%Y%m%d%H%M%S") # get current time
  
  #model_name_indexed <- paste0(model_name, "_", fit_index, "_", cur_time)
  
  fit_index_time <- paste0(fit_index, "_", cur_time)
  
  save_path <- here(output_path, model_name, fit_index_time)
  dir.create(save_path, recursive = TRUE)
  
  return(save_path)
  
}
