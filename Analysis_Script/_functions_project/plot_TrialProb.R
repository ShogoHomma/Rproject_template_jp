# 横軸：試行、縦軸：選択確率と選択
## 1人分の画像なので、purrr::map()で各課題、各参加者分の画像をまとめて生成すること

library(tidyverse)

plot_TrialProb <- function(df) {
  
  g <- df %>% 
    dplyr::mutate(
      Choice = if_else(Choice == 2, 0, 1) # choice 2 -> 0
    ) %>% 
    ggplot() + 
    geom_point(aes(x = trial, y = Choice, shape = as.factor(Reward))) + 
    geom_line(aes(x = trial, y = Prob), size = 1.5) + 
    my_theme2 + 
    theme(
      axis.text.x = element_text(size = 18), 
      axis.text.y = element_text(size = 15), 
      strip.text.x = element_text(size = 15),
      strip.text.y = element_text(size = 15)) +
    scale_x_continuous(breaks = c(0, unique(df$trial)[length(unique(df$trial))]/2, unique(df$trial)[length(unique(df$trial))])) + 
    coord_cartesian(ylim = c(0, 1.0)) + 
    labs(x = "trial", y = "Probability of choosing 1", shape = "Reward") 
  
  return(g)
  
}
