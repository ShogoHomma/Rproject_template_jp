# 横軸：試行、縦軸：Q値
## 1人分の画像なので、purrr::map()で各課題、各参加者分の画像をまとめて生成すること

library(tidyverse)

plot_TrialQvalue <- function(df) {
  
  g <- df %>% 
    ggplot(aes(x = trial, y = value, color = as.factor(Q))) + 
    geom_line(size = 1.5) + 
    my_theme2 + 
    theme(
      axis.text.x = element_text(size = 18), 
      axis.text.y = element_text(size = 15), 
      strip.text.x = element_text(size = 15),
      strip.text.y = element_text(size = 15)) +
    scale_x_continuous(breaks = c(0, unique(df$trial)[length(unique(df$trial))]/2, unique(df$trial)[length(unique(df$trial))])) + 
    coord_cartesian(ylim = c(0, 1.0)) + 
    labs(x = "trial", y = "Q value", color = "Q") 
  
  return(g)
}
