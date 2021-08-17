# basicRLモデルで推定したパラメータから、予測分布のシミュレーションを行い、結果を保存する関数
## Q値の変化と選択確率の変化を保存する

model_pred_basicRL <- function(target_data, target_params, save_path) {
  
  options(readr.num_columns = 0) # readrのメッセージを消す
  
  data_df <- readr::read_csv(target_data) # 行動データのcsv
  params_df <- readr::read_csv(target_params) # 推定したパラメータのcsv
  
  # ----- 以下、ID（参加者）ごとにシミュレーションを実行する
  
  ## data_dfはID列が、params_dfはp_index列が、特定の参加者に対応する
  
  # 念のため、同じ人数かをチェック
  IDs_data <- data_df %>% dplyr::pull(ID) %>% unique(.)
  IDs_para <- params_df %>% dplyr::filter(para != 'lp__') %>% dplyr::pull(p_index) %>% unique(.)
  if (length(IDs_data) !=  length(IDs_para)) {
    stop("Error in ID length. See sim_model_pred_basicRL(). ")
  }
  
  # IDごとにQlearningをシミュレーション
  # -> listとして result_sim に保存される
  result_sim <- purrr::map(IDs_data, ~sim_model_pred_byID_basicRL(.x, data_df, params_df))
  
  # ----- データフレームに成形する
  
  # Q値
  Q_df <- 
    IDs_data %>% 
    purrr::map(~{result_sim[[.x]] %>% purrr::map("Q")}) %>% 
    purrr::set_names(IDs_data) %>% 
    tibble::as_tibble() %>% 
    dplyr::mutate(rep_value = c("mean", "mode", "median")) %>% 
    tidyr::pivot_longer(cols = -rep_value, names_to = "ID", values_to = "Q") %>% 
    # see:https://stackoverflow.com/questions/59535880/subsetting-a-list-column-of-integer-matrices
    dplyr::mutate(
      Q1 = map(Q, ~.[, 1]),
      Q2 = map(Q, ~.[, 2])) %>% 
    tidyr::unnest(c(Q1, Q2)) %>% 
    dplyr::group_by(rep_value, ID) %>% 
    dplyr::mutate(
      trial = 1:50
    ) %>% 
    dplyr::ungroup() %>% 
    dplyr::transmute(
      ID = as.integer(ID),
      rep_value = rep_value,
      trial = trial,
      Q1 = Q1,
      Q2 = Q2
    )
    
  # 選択確率
  Prob_df <- 
    IDs_data %>% 
    purrr::map(~{result_sim[[.x]] %>% purrr::map("p")}) %>% 
    purrr::set_names(IDs_data) %>% 
    tibble::as_tibble() %>% 
    dplyr::mutate(rep_value = c("mean", "mode", "median")) %>% 
    tidyr::pivot_longer(cols = -rep_value, names_to = "ID", values_to = "Prob") %>% 
    tidyr::unnest(Prob) %>% 
    dplyr::group_by(rep_value, ID) %>% 
    dplyr::mutate(
      trial = 1:50
    ) %>% 
    dplyr::ungroup() %>% 
    dplyr::transmute(
      ID = as.integer(ID),
      rep_value = rep_value,
      trial = trial,
      Prob = Prob
    )
  
  # パラメータ
  s_params_df <- 
    params_df %>% 
    dplyr::filter(para != 'lp__') %>% 
    dplyr::transmute(
      ID = p_index,
      para = para,
      mean = mean, 
      mode = mode, 
      median = `50%`
    ) %>% 
    tidyr::pivot_longer(cols = c(mean, mode, median), names_to = "rep_value", values_to = "para_value")
  
  # 実際の行動データ
  s_data_df <-
    data_df %>% 
    dplyr::select(ID, trial, Choice, Reward)
  
  # ------ 3つのdfを結合して、.RDataで出力しておく (csvでもよい、特に意味はない)
  
  res_model_pred <- 
    Q_df %>% 
    dplyr::full_join(Prob_df) %>% 
    dplyr::full_join(s_params_df) %>% 
    dplyr::full_join(s_data_df) %>% 
    tidyr::pivot_wider(names_from = "para", values_from = "para_value")  
  
  # 保存先のファイル名
  save_res_path <- paste0(save_path, "/", "res_model_pred.RData")
  
  # 保存
  save(res_model_pred, file = save_res_path)
  
  #return(res_model_pred)
  
}
