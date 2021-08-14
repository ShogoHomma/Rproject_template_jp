# モデルフィッティングの結果の保存先を作成する

#library(tidyverse)
#library(here)

output_setup <- function(output_path, stan_name, fit_number, dir_name) {
  
  if (str_detect(stan_name, pattern = "\\.stan") == TRUE) { # .stanが含まれている場合
    model_name <- stan_name %>% str_split(pattern = "\\.stan") %>% .[[1]] %>% .[1]
  } else {
    model_name <- stan_name
  }
  
  save_path <- here(output_path, model_name, fit_number, dir_name)
  dir.create(save_path, recursive = TRUE)
  
  return(save_path)
  
}
