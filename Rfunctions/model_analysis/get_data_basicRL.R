# 強化学習のフィッティング関数に渡せるように、データを整形する。

#library(tidyverse)
#library(here)

get_data_basicRL <- function(data_path_i) {
  
  df <- readr::read_csv(data_path_i, show_col_types = FALSE) %>% 
    dplyr::transmute(
      ID = ID,
      Trial = trial,
      Reward = Reward,
      Choice = Choice
    )
  
  return(df)
  
}
