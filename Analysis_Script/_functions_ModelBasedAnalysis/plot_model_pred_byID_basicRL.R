# 参加者ひとり一人について、予測分布の画像を作成する

library(patchwork)

plot_model_pred_byID_basicRL <- function(ID_i, res_model_pred, rep_type, save_path) {
  
  fig_h <- 9
  fig_w <- 7
  save_img_path <- paste0(save_path, "/", "sbj", ID_i, ".png")
  
  # set counter
  cat("---- save prediction figure: sbj:", ID_i, "\n")
  
  res_ID_i <- 
    res_model_pred %>% 
    dplyr::filter(ID == ID_i) %>% 
    dplyr::filter(rep_value == rep_type) %>% 
    dplyr::mutate(
      Choice_rev = if_else(Choice == 2, 0, Choice) # Choice 2 -> 0 へ変換
    )
  
  alpha_i <- res_ID_i %>% dplyr::pull(alpha) %>% unique(.)
  beta_i <- res_ID_i %>% dplyr::pull(beta) %>% unique(.)
  
  g_Prob <- 
    res_ID_i %>% 
    ggplot(aes(x = trial, y = Prob)) + geom_line() + 
    geom_point(aes(x = trial, y = Choice_rev, fill = as.factor(Reward)), shape = 21, stroke = 0.3) + 
    coord_cartesian(ylim = c(0,1)) + 
    scale_fill_viridis_d() + 
    labs(x = "Trial", y = "Prob(Op 1)", fill = "Reward") + 
    ggtitle(label = paste0("sbj: ", ID_i), 
            subtitle = paste0("value: ", rep_type, ", alpha = ", alpha_i, ", beta = ", beta_i))
  
  g_Qvalue <- 
    res_ID_i %>% 
    tidyr::pivot_longer(cols = c(Q1, Q2), names_to = c("Q"), values_to = "value") %>% 
    
    ggplot(aes(x = trial, y = value, color = Q)) + 
    geom_line() + 
    labs(x = "Trial", y = "Q value")
  
  g_full <- g_Prob/g_Qvalue # patchworkで縦に並べて1つの図に
  
  ggsave(filename = save_img_path, plot = g_full, dpi = 500, width = fig_w, height = fig_h)
  
}
