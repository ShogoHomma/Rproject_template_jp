# フィッティング結果の保存先を作成する

library(tidyverse)
library(here)

output_setup <- function(output_path, stan_name, fit_number) {
  
  model_name <- stan_name %>% str_split(pattern = "\\.stan")
  
  save_path <- here(output_path, model_name[[1]][1], fit_number, "stanfit")
  dir.create(save_path, recursive = TRUE)
  
  return(save_path)
  
}
