# 強化学習のフィッティング関数に渡せるように、データを整形する。

#library(tidyverse)
#library(here)

get_data_basicRL <- function(data_path_i) {
  
  options(readr.num_columns = 0) # readrのメッセージを消す
  
  df <- readr::read_csv(data_path_i, na = "None") %>% 
    dplyr::transmute(
      ID = ID,
      Trial = trial,
      Reward = Reward,
      Choice = Choice
    )
  
  return(df)
  
}
