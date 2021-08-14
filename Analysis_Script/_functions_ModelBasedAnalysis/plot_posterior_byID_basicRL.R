# 参加者ひとり一人について、posteriorの画像を作成する

#library(tidyverse)
#library(here)
#library(rstan)

plot_posterior_byID_basicRL <- function(ID_i, stan_fit, save_path, target_params) {
  
  fig_h <- 6
  fig_w <- 8
  save_img_path <- paste0(save_path, "/", "sbj", ID_i, ".png")
  para_vec <- paste0(target_params, "[", ID_i, "]")
  
  # set counter
  cat("---- save posterior figure: sbj:", ID_i, "\n")
  
  rstan::stan_dens(stan_fit, separate_chains = TRUE, ncol = 2, pars = para_vec) + theme_minimal(base_size = 20) +  
    theme(strip.text = element_text(size = rel(1.5))) + 
    ggtitle(paste0("sbj: ", ID_i)) + ggsave(save_img_path, height = fig_h, width = fig_w)
  
}
