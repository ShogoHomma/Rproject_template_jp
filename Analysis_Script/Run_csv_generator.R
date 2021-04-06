# stanをコンパイルし、mcmcを実行するファイル

library(tidyverse)
library(rstan)
library(here) 

# 関数の読み込み
model_functions_path <- here("Analysis_Script", "_functions_Model-BasedAnalysis")
model_functions <- here(model_functions_path, dir(model_functions_path))
purrr::walk(model_functions, ~source(.x))

common_functions_path <- here("Analysis_Script", "_functions")
common_functions <- here(common_functions_path, dir(common_functions_path))
purrr::walk(common_functions, ~source(.x))

# 結果の出力先
output_path <- here("Data", "Models_Results")


# ------ basic_RL model ----------

# * fit01 -------

stan_name <- "basic_RL"
fit_number <- "fit01"
stanfit_pattern <- "stanfit.obj"
output_csv_name <- "est_parameter.csv"

# ファイルの保存先を作成 & 取得
save_path <- output_setup(output_path, stan_name, "estimated_parameter", fit_number) 

# stan.objのパスを取得
target_stanfit <- make_DataPath(output_path, "basic_RL", "fit01", stanfit_pattern)

# csvの作成
save_params_csv_basicRL(target_stanfit, save_path, output_csv_name)



