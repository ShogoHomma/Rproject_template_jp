# パラメータの推定結果から、予測分布を作成する

library(tidyverse)
library(rstan)
library(here) 
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# 関数の読み込み
model_functions_path <- here("Analysis_Script", "_functions_ModelBasedAnalysis")
model_functions <- here(model_functions_path, dir(model_functions_path))
purrr::walk(model_functions, ~source(.x))

common_functions_path <- here("Analysis_Script", "_functions_common")
common_functions <- here(common_functions_path, dir(common_functions_path))
purrr::walk(common_functions, ~source(.x))

# フィッティング結果の出力先
output_path <- here("Data", "Models_Results")


# ------ basic_RL model ----------

## * fit01 -------

stan_name <- "basic_RL"
fit_number <- "fit01"

# 出力の保存先を作成 & 取得
save_path <- output_setup(output_path, stan_name, fit_number, "model_prediction") 

# データパスの取得
target_data <- make_DataPath("Data", "DummyData_RL", "_20210322151628", ".csv")

# パラメータcsvのパスを取得
target_params <- make_DataPath(output_path, stan_name, fit_number, "estimated_parameter")

# シミュレーションの実行
model_pred_basicRL(target_data, target_params, save_path)

# 結果の図示&保存
save_model_pred_basicRL("mean", save_path)

