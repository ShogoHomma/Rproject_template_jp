# basicRLの予測分布を.pngとして出力し、保存する関数

save_model_pred_basicRL <- function(rep_type, save_path) {
  # rep_typeには、"mean", "mode", "median" のどれかをいれる
  
  # 予測シミュレーションの結果 res_model_pred の読み込み 
  load(paste0(save_path, "/", "res_model_pred.RData")) 
  
  # 参加者（ID）ごとに.pngを出力する
  ## そのため、参加者の人数を指定する
  sbj_N <- res_model_pred %>% dplyr::pull(ID) %>% unique(.) %>% length(.)
  
  # 一人ひとりについて予測分布を作成し、予測分布の画像を保存する
  purrr::walk(1:sbj_N, ~plot_model_pred_byID_basicRL(.x, res_model_pred, rep_type, save_path))
  
}
